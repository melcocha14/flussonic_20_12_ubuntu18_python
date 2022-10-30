#!/bin/bash
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Not running as root. Switch to root or use sudo."
    exit
fi
echo "====================================================================================="
echo "This is a Flussonic Watcher Installation Script."

if [ ! -d "/etc/flussonic" ]; then
	echo "Flussonic isn't installed, folder /etc/flussonic is missing! Please install Flussonic 20.12 first."
	exit 1
elif [ ! -d "/opt/flussonic" ]; then
	echo "Flussonic isn't installed, folder /opt/flussonic is missing! Please install Flussonic 20.12 first."
	exit 1
fi


if [ -f /etc/redhat-release ]; then
  [ ! -d "./RPM" ] && echo "Directory ./RPM - DOES NOT exists. Keep this script next to the RPM folder!"
  [ ! -d "./DATA" ] && echo "DATA folder is missing, keep this script next to DATA folder!"
  distro_cmd="systemctl stop flussonic; systemctl stop postgresql; rm -rf /var/lib/postgresql; rm -rf /var/log/postgresql; rm -rf /etc/postgresql; rm -rf /usr/share/postgresql; rm -rf /var/lib/pgsql; yum remove postgresql\* -y; yum install postgresql -y; rpm -Uvh ./RPM/flussonic-watcher-20.12-1.x86_64.rpm"
fi

if [ -f /etc/debian_version ]; then
  [ ! -d "./DEB" ] && echo "Directory ./DEB - DOES NOT exists. Keep this script next to the DEB folder!"
  [ ! -d "./DATA" ] && echo "DATA folder is missing, keep this script next to DATA folder!"
  distro_cmd="echo \"deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main\" > /etc/apt/sources.list.d/pgdg.list; wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -; apt-get update; systemctl stop postgresql; rm -rf /var/lib/postgresql; rm -rf /usr/share/postgresql; rm -rf /var/log/postgresql/; rm -rf /etc/postgresql; rm -rf /var/lib/pgsql; rm -rf /etc/systemd/system/postgresql*; apt-get -y remove --purge postgresql\*; add-apt-repository universe -y; apt-get update; apt-get install -y sudo postgresql postgresql-11; dpkg -i ./bin/flussonic-watcher_20.12_amd64.deb"
fi

#### DEFINE FUNC
install_watcher () {
systemctl enable postgresql
echo "Modifying postgresql.conf"
find /etc/postgresql -type f -name "postgresql.conf" -exec sed -i "/listen/s/.*/listen_addresses\ =\ \'192.168.56.1\'/" "{}" \;
find /etc/postgresql -type f -name "pg_hba.conf" -exec sh -c 'echo "host    all             all             192.168.56.0/24         md5" >> "{}"' \;
systemctl restart postgresql

echo "Installing watcher DB..."
if ! sudo -i -u postgres bash -c "psql -c \"CREATE USER watcher WITH PASSWORD 'Hacked';\"" ; then
        echo "FAILED to create DB user! Check if postgresql is running:"
        netstat -tuapn | grep -i LISTEN | grep postgre
        exit 1
else
        #sudo -u postgres -i createdb -O watcher -e -E UTF8 -T template0 vsaas_production
        sudo -u postgres -i createdb -O watcher -e -T template0 vsaas_production
fi
echo "Restarting flussonic..."
systemctl stop flussonic
sleep 2
systemctl start flussonic

### INSERT POSTGRESQL SYSTEMD IN VETH SCRIPTS
if [ -f /veth.bash ]; then
	echo "systemctl start postgresql" >> /veth.bash

else
	echo "WARNING! /veth.bash was not found. Watcher may fail to start after reboot. Is this Official Flussonic installation or your hacked Flussonic install is corrupted?"
fi
if [ -f /veth_stop.bash ]; then
	echo "systemctl stop postgresql" >> /veth_stop.bash

else
	echo "WARNING! /veth_stop.bash was not found. Watcher may fail to start after reboot. Is this Official Flussonic installation or your hacked Flussonic install is corrupted?"
fi
echo "====================================================================================="
extip=$(wget -q http://ifconfig.co -4 -O -)
aport=$(cat /etc/flussonic/flussonic.conf | grep -o "80\|8080")
echo "DONE! GO TO FLUSSONIC PANEL AT http://$extip:$aport/admin AND INSERT CONFIG LINE AS FOLLOW:"
echo "postgresql://watcher:Hacked@192.168.56.1/vsaas_production"
echo "FLUSSONIC WATCHER PANEL WILL BE AT: http://$extip:$aport/vsaas WAIT A FEW MINUTES BEFORE OPENING THE PANEL!"
echo "====================================================================================="
}
#### END DEFINE FUNC

#### INIT FUNC
echo "BEWARE! Running this script at any time will COMPLETELY WIPE your PostgreSQL database. Make sure you made a DB backup!!! This script can be used with either Official Flussonic or with a Hacked one Select 1 for YES or 2 for NO."
echo "Would you like to continue?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) eval $distro_cmd; install_watcher "$distro_cmd"; break;;
        No ) echo "SCRIPT ABORTED!"; exit; break;;
    esac
done
#### END INIT FUNC
