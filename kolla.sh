sudo -H apt update
sudo -H apt-get -y install python-dev libffi-dev gcc libssl-dev python-selinux python-setuptools python-pip
sudo -H pip install -U pip
sudo -H apt-get -y install ansible
sudo -H pip install kolla-ansible
sudo -H mkdir -p /etc/kolla
sudo -H chown $USER:$USER /etc/kolla
cp -r /usr/local/share/kolla-ansible/etc_examples/kolla/* /etc/kolla
cp /usr/local/share/kolla-ansible/ansible/inventory/* .
kolla-genpwd 
cp /vagrant/globals.yml /etc/kolla/globals.yml 
sudo -H pip install ansible --upgrade
sudo -H kolla-ansible -i ./all-in-one bootstrap-servers
sudo -H kolla-ansible -i ./all-in-one prechecks
sudo -H kolla-ansible -i ./all-in-one deploy
sudo -H pip install python-novaclient python-neutronclient python-glanceclient python-openstackclient
kolla-ansible post-deploy
. /etc/kolla/admin-openrc.sh 
. /usr/local/share/kolla-ansible/init-runonce 
