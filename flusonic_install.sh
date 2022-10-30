#!/bin/bash
echo " "
jeshile='\e[40;38;5;82m'
jo='\e[0m'
os=$(exec uname -m|grep 64)
if [ "$os" = "" ]
then os="x86"
else os="x64"
fi

DIRE=$(hostname -I)
DIREMODE=$(expr "$DIRE" : '\(.*\).')
TARJETARED=$(route | grep '^default' | grep -o '[^ ]*$')

echo -e "${jeshile} +-----------------------------+ \e[0m"
echo -e "${jeshile} ¦Revisando Version del sistema¦ \e[0m"
echo -e "${jeshile} +-----------------------------+ \e[0m"
sleep "5"

echo -e "${jeshile} +------------------------------+ \e[0m"
echo -e "${jeshile} ¦Sistema de $os Bits Detecatado¦ \e[0m"
echo -e "${jeshile} +------------------------------+ \e[0m"
sleep "5"

echo -e "${jeshile} +--------------------------------+ \e[0m"
echo -e "${jeshile} ¦   Prerequisitos para instalar  ¦ \e[0m"
echo -e "${jeshile} ¦      Flusonic 20.12            ¦ \e[0m"
echo -e "${jeshile} ¦                                ¦ \e[0m"
echo -e "${jeshile} ¦  1 Usuario para Flusonic       ¦ \e[0m"
echo -e "${jeshile} ¦  2 Contraseña para Flusonic    ¦ \e[0m"
echo -e "${jeshile} ¦  3 Puerto de acceso Flusonic   ¦ \e[0m"
echo -e "${jeshile} ¦                                ¦ \e[0m"
echo -e "${jeshile} +--------------------------------+ \e[0m"
echo ""
echo ""
sleep "5"


echo -e "${jeshile} +---------------------------+ \e[0m"
echo -e "${jeshile} ¦    Escribe un usuario     ¦ \e[0m"
echo -e "${jeshile} ¦      para Flusonic        ¦ \e[0m"
echo -e "${jeshile} ¦                           ¦ \e[0m"
echo -e "${jeshile} ¦    ejemplo: admin         ¦ \e[0m"
echo -e "${jeshile} +---------------------------+ \e[0m"
sleep "3"

read USERFLUSO
echo "Tu Usuario de administrador para Flusonic es: $USERFLUSO"
echo ""

echo -e "${jeshile} +---------------------------+ \e[0m"
echo -e "${jeshile} ¦  Escribe la contraseña    ¦ \e[0m"
echo -e "${jeshile} ¦      para Flusonic        ¦ \e[0m"
echo -e "${jeshile} ¦                           ¦ \e[0m"
echo -e "${jeshile} ¦ Usa una contraseña segura ¦ \e[0m"
echo -e "${jeshile} ¦                           ¦ \e[0m"
echo -e "${jeshile} ¦ ejemplo Abc12@9#hX        ¦ \e[0m"
echo -e "${jeshile} ¦                           ¦ \e[0m"
echo -e "${jeshile} +---------------------------+ \e[0m"
sleep "3"

read CONTRAFLUSO
echo "Tu Contraseña de Flusonic es: $CONTRAFLUSO"
echo ""

echo -e "${jeshile} +---------------------------+ \e[0m"
echo -e "${jeshile} ¦    Escribe un numero      ¦ \e[0m"
echo -e "${jeshile} ¦      de puerto para       ¦ \e[0m"
echo -e "${jeshile} ¦        Flusonic           ¦ \e[0m"
echo -e "${jeshile} ¦                           ¦ \e[0m"
echo -e "${jeshile} ¦    ejemplo: 8080          ¦ \e[0m"
echo -e "${jeshile} +---------------------------+ \e[0m"
sleep "3"

read PUERTOFLUSO
echo "Tu Usuario de administrador para Flusonic es: $PUERTOFLUSO"
echo ""




echo -e "${jeshile} +---------------------------+ \e[0m"
echo -e "${jeshile} ¦  Actulizando el sisteama  ¦ \e[0m"
echo -e "${jeshile} +---------------------------+ \e[0m"
sleep "3"

sudo apt update -y


echo -e "${jeshile} +-------------------------------+ \e[0m"
echo -e "${jeshile} ¦     Desinstalando Flusonic    ¦ \e[0m"
echo -e "${jeshile} +-------------------------------+ \e[0m"
sleep "3"

sudo rm -f /etc/apt/sources.list.d/flussonic.list
sudo rm -f /etc/apt/sources.list.d/erlyvideo.list
sudo rm -rf /flussonic*
sudo rm -rf /usr/lib/systemd/system/flussonic
sudo rm -rf /etc/systemd/system/flnc.service
sudo rm -rf /etc/systemd/system/fldns.service
sudo rm -rf /etc/systemd/system/flussonic.service
sudo rm -rf /etc/flussonic/*
sudo rm -rf /opt/flussonic/*
sudo rm -rf /veth*
sudo rm -rf /flussonic_*



echo -e "${jeshile} +---------------------------+ \e[0m"
echo -e "${jeshile} ¦    Instalando Flusonic    ¦ \e[0m"
echo -e "${jeshile} +---------------------------+ \e[0m"
sleep "3"

sudo apt install ./bin/flussonic-erlang_22.3.7_all.deb
sudo apt install ./bin/flussonic-transcoder-base_20.05_all.deb
sudo apt install ./bin/flussonic_20.12_amd64.deb
sudo apt install ./bin/flussonic-transcoder_20.05_all.deb
sudo apt install ./bin/flussonic-python_20.07.3_amd64.deb



echo -e "${jeshile} +-----------------------------+ \e[0m"
echo -e "${jeshile} ¦    Configurando acceso      ¦ \e[0m"
echo -e "${jeshile} ¦    para el panel Flusonic   ¦ \e[0m"
echo -e "${jeshile} +-----------------------------+ \e[0m"
sleep "3"

sudo echo "# Global settings:" >> /etc/flussonic/flussonic.conf
sudo echo "http $PUERTOFLUSO;" >> /etc/flussonic/flussonic.conf
sudo echo "pulsedb /var/lib/flussonic;" >> /etc/flussonic/flussonic.conf
sudo echo "session_log /var/lib/flussonic;" >> /etc/flussonic/flussonic.conf
sudo echo "edit_auth $USERFLUSO $CONTRAFLUSO;" >> /etc/flussonic/flussonic.conf
sudo echo " " >> /etc/flussonic/flussonic.conf
sudo echo "# DVRs:" >> /etc/flussonic/flussonic.conf
sudo echo " " >> /etc/flussonic/flussonic.conf
sudo echo "# Remote sources:" >> /etc/flussonic/flussonic.conf
sudo echo " " >> /etc/flussonic/flussonic.conf
sudo echo "# Ingest streams:" >> /etc/flussonic/flussonic.conf
sudo echo " " >> /etc/flussonic/flussonic.conf
sudo echo "# Dynamic rewrites:" >> /etc/flussonic/flussonic.conf
sudo echo " " >> /etc/flussonic/flussonic.conf
sudo echo "# Publish locations:" >> /etc/flussonic/flussonic.conf
sudo echo " " >> /etc/flussonic/flussonic.conf
sudo echo "# Disk file caches:" >> /etc/flussonic/flussonic.conf
sudo echo " " >> /etc/flussonic/flussonic.conf
sudo echo "# VOD locations:" >> /etc/flussonic/flussonic.conf
sudo echo " " >> /etc/flussonic/flussonic.conf
sudo echo "# DVB cards:" >> /etc/flussonic/flussonic.conf
sudo echo " " >> /etc/flussonic/flussonic.conf
sudo echo "# Plugins:" >> /etc/flussonic/flussonic.conf
sudo echo "plugin iptv {" >> /etc/flussonic/flussonic.conf
sudo echo "  database sqlite:///opt/flussonic/priv/iptv.db;" >> /etc/flussonic/flussonic.conf
sudo echo "}" >> /etc/flussonic/flussonic.conf


echo -e "${jeshile} +--------------------------------+ \e[0m"
echo -e "${jeshile} ¦  Instalando Licencia Flusonic  ¦ \e[0m"
echo -e "${jeshile} +--------------------------------+ \e[0m"
sleep "3"
sudo cp tools/license.txt /etc/flussonic/license.txt
sudo cp tools/priv/* /opt/flussonic/priv/


echo -e "${jeshile} +----------------------------------+ \e[0m"
echo -e "${jeshile} ¦  Instalando Sofware Propietario  ¦ \e[0m"
echo -e "${jeshile} +----------------------------------+ \e[0m"
sleep "3"

sudo apt install software-properties-common -y


echo -e "${jeshile} +---------------------------+ \e[0m"
echo -e "${jeshile} ¦  Actulizando el sisteama  ¦ \e[0m"
echo -e "${jeshile} +---------------------------+ \e[0m"
sleep "3"
sudo apt update -y


echo -e "${jeshile} +------------------------------+ \e[0m"
echo -e "${jeshile} ¦  Instalando Nettools pip     ¦ \e[0m"
echo -e "${jeshile} +------------------------------+ \e[0m"
sleep "3"
sudo apt-get install -y sudo net-tools python3-pip netcat


echo -e "${jeshile} +--------------------------+ \e[0m"
echo -e "${jeshile} ¦  Instalando dnspython    ¦ \e[0m"
echo -e "${jeshile} +--------------------------+ \e[0m"
sleep "3"
sudo pip3 install setuptools dnspython scapy netifaces


echo -e "${jeshile} +--------------------------------+ \e[0m"
echo -e "${jeshile} ¦  Deteniendo servicio Flusonic  ¦ \e[0m"
echo -e "${jeshile} +--------------------------------+ \e[0m"
sleep "3"
sudo systemctl stop flussonic


echo -e "${jeshile} +-------------------------------+ \e[0m"
echo -e "${jeshile} ¦  Configurando Dns de google   ¦ \e[0m"
echo -e "${jeshile} +-------------------------------+ \e[0m"
sleep "3"

sudo rm -rf /etc/resolv.conf
sudo echo "nameserver 8.8.8.8" >> /etc/resolv.conf
sudo echo "nameserver 1.1.1.1" >> /etc/resolv.conf

echo -e "${jeshile} +----------------------------------+ \e[0m"
echo -e "${jeshile} ¦  Deshabilitando actualizaciones  ¦ \e[0m"
echo -e "${jeshile} +----------------------------------+ \e[0m"
sleep "3"

sudo cp tools/veth.bash /veth.bash
sudo cp tools/veth_stop.bash /veth_stop.bash
sudo chmod +x /veth*
sudo cp -rf tools/*.beam /opt/flussonic/lib/manager/ebin/
sudo cp -rf tools/flussonic_listener.sh /
sudo cp -rf tools/flussonic_dns.py /

sudo chmod +x /flussonic*
sudo cp tools/flussonic.service /etc/systemd/system/flussonic.service
sudo cp tools/flnc.service /etc/systemd/system/flnc.service

sed -i "s/eth0 80/eth0 $PUERTOFLUSO/g" /etc/systemd/system/flussonic.service
sed -i "s/eth0/$TARJETARED/g" /etc/systemd/system/flussonic.service

sudo systemctl daemon-reload
sudo systemctl enable flussonic
sudo systemctl disable flnc



echo -e "${jeshile} +-----------------------------+ \e[0m"
echo -e "${jeshile} ¦  Reiniciando Flusonic       ¦ \e[0m"
echo -e "${jeshile} +-----------------------------+ \e[0m"
sleep "3"

sudo systemctl start flussonic


echo " "
echo -e "${jeshile} +----------------------------------------------------------+ \e[0m"
echo -e "${jeshile} ¦      Creditos y soporte melcocha14@gmail.com             ¦ \e[0m"
echo -e "${jeshile} ¦                                                          ¦ \e[0m"
echo -e "${jeshile} ¦                                                          ¦ \e[0m"
echo -e "${jeshile} ¦                                                          ¦ \e[0m"
echo -e "${jeshile} ¦      Link de acceso al Panel de clientes                 ¦ \e[0m"
echo -e "${jeshile} ¦      http://$DIREMODE:$PUERTOFLUSO/admin/#/              ¦ \e[0m"
echo -e "${jeshile} ¦                                                          ¦ \e[0m"
echo -e "${jeshile} ¦     Tus Datos del acceso al Panel son:                   ¦ \e[0m"
echo -e "${jeshile} ¦                                                          ¦ \e[0m"
echo -e "${jeshile} ¦      Usiario:   $USERFLUSO                               ¦ \e[0m"
echo -e "${jeshile} ¦      Password:  $CONTRAFLUSO                             ¦ \e[0m"
echo -e "${jeshile} ¦                                                          ¦ \e[0m"
echo -e "${jeshile} ¦     Guarda tus Datos en un lugar seguro                  ¦ \e[0m"
echo -e "${jeshile} ¦                                                          ¦ \e[0m"
echo -e "${jeshile} +----------------------------------------------------------+ \e[0m"


