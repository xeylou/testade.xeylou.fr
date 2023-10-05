<!--
https://www.youtube.com/watch?v=jytcJ-pN0JI
https://www.youtube.com/watch?v=3lXc7xO8T9k
-->
en
conf t
hostname GASPARD
ip domain-name rzo.lan
crypto key generate rsa modulus 4096
username xeylou privilege 15 algorithm-type sha256 secret motdepasse
int g0/0
ip add 192.168.0.1 255.255.255.0
no shut
exit

do sh run | b line
<!-- regarder vty -->

line vty 0 15
login local
transport input ssh
exit

ip ssh version 2
<!-- définition des algorithmes -->
ip ssh server algorithm max hmac-sha2-256
ip ssh server algorithm encryption aes256-ctr
ip ssh server algorithm kex diffie-hellman-group14-sha1
<!-- opeen ssh a changé ça, on peut tout retiré car défault -->
ip ssh dh min size 4096

# sur vm ubuntu
rappel: on a mis le meilleur algo possible sur le router, mais openssh le considère déjà comme obsolete (openssh beaucoup plus recent que les version de cisco ios qu'on a)*

nano ~/.ssh/config
Host GASPARD
  hostname=192.168.0.1
  user=xeylou
  KexAlgorithms=diffie-hellman-group14-sha1
  HostKeyAlgorithms=ssh-rsa
<!-- "downgrade" de la connexion, si pas deux paramètres on pourra pas -->
ssh GASPARD

en
conf t
ip access-list standard SSH_ACL
permit 192.168.0.0 0.0.0.255
line vty 0 15
access-class SHH_ACL in
exec timeout 10 0
<!-- 10 minutes, de base timeout rien -->
ip ssh authentication-retries 3
<!-- combien de tentative mdp ssh, anti-bruteforce, sinon te laisse essayer autant que tu veux? -->
service tcp-keepalives-in
service tcp-keepalives-out
<!-- activation SCP, plutot de TFTP notamment pour fichiers de conf -->
ip scp server enable



# deuxième vidéo

<!-- autre utilisateur sans mdp -->
en
conf t
username xeylou2 privilege 15
ip ssh pubkey-chain
username xeylou2
key-string
> coller ici
### sur vm ubuntu
<!-- algorithme rsa uniquement supporté -->
ssh-keygen -b 4096 -t rsa -f "$HOME/.ssh/cisco-ssh" -C "xeylou2@rzo.lan" -N ""
fold -b -w 72 ~/.ssh/cisco-ssh.pub
<!-- NE PAS METTRE ssh-rsa & xeylou2@rzo.lan -->

### retour sur équipement
en conf t
ip ssh pubkey-chain
username xeylou2
key-string
<!-- coller contenu -->
exit
end
<!-- comparaison des fingerprints/hashs des clés -->
sh run | b pubkey

### sur hote vm ubuntu
ssh-keygen -l -E md5 -f ~/.ssh/cisco-ssh.pub
<!-- récupération du hash md5 de cla clé publique -->
<!-- comparaison possible entre les deux -->

<!-- ajout ligne deux dernières lignes -->
nano ~/.ssh/config
Host GASPARD
  hostname=192.168.0.1
  user=xeylou
  KexAlgorithms=diffie-hellman-group14-sha1
  HostKeyAlgorithms=ssh-rsa
  PubKeyAcceptedAlgorithms=ssh-rsa
  IdentityFile "/home/xeylou/.ssh/cisco-ssh"

# à tester 1

en
conf t
hostname GASPARD
ip domain-name rzo.lan
crypto key generate rsa modulus 4096
<!-- username xeylou privilege 15 algorithm-type sha256 secret motdepasse -->
username xeylou privilege 15 
int g0/0
ip add 192.168.0.1 255.255.255.0
no shut
exit
line vty 0 15
login local
transport input ssh
exit
ip ssh version 2
ip ssh dh min size 4096
ip ssh pubkey-chain
username xeylou
key-string
<!-- coller tout ici -->
exit
end

nano ~/.ssh/config
Host GASPARD
  hostname=192.168.0.1
  user=xeylou
  KexAlgorithms=diffie-hellman-group-exchange-sha1
  HostKeyAlgorithms=ssh-rsa
  PubKeyAcceptedAlgorithms=ssh-rsa
  IdentityFile "/home/xeylou/.ssh/cisco-ssh"





chaque manip avec ip ssh si pas crypto key generate rsa modulus 4096
Please create RSA keys to enable SSH (and of atleast 768 bits for SSH v2).

puis 

*Oct  5 06:27:39.566: %SSH-5-ENABLED: SSH 2.0 has been enabled


hostname GASPARD dépéndance de crypto key generate rsa modulus 4096






sur un switch

en
conf t
hostname GASPARD
ip domain-name rzo.lan
crypto key generate rsa modulus 4096
<!-- username xeylou privilege 15 algorithm-type sha256 secret motdepasse -->
username xeylou privilege 15 secret motdepasse
int vlan 1
ip add 192.168.0.1 255.255.255.0
no shut
exit
line vty 0 15
login local
transport input ssh
exit
ip ssh version 2
ip ssh dh min size 4096
ip ssh pubkey-chain
username xeylou
key-string
<!-- coller tout ici -->
exit
end

nano ~/.ssh/config
Host GASPARD
  hostname=192.168.0.1
  user=xeylou
  KexAlgorithms=diffie-hellman-group-exchange-sha1
  HostKeyAlgorithms=ssh-rsa
  PubKeyAcceptedAlgorithms=ssh-rsa
  IdentityFile "/home/xeylou/.ssh/cisco-ssh"
  <!-- Ciphers aes128-cbc,3des-cbc,aes192-cbc,aes256-cbc -->
  Ciphers aes256-cbc


note: je n'ai pas désactivé authentification par mot de passe
mettre des ACL
très importants les timeout & nombre tentative max