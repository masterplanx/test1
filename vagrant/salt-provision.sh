#!/bin/bash

ROLE=$1

if [ ! -f /usr/bin/salt-minion ]; then
        if [ -n "$(which yum)" ]; then
		yum -y install epel-release

 		sed -i -e '/^mirror/d' -e 's/#baseurl/baseurl/' \
			/etc/yum.repos.d/CentOS-Vault.repo \
			/etc/yum.repos.d/CentOS-Base.repo \
			/etc/yum.repos.d/epel.repo \
			/etc/yum.repos.d/epel-testing.repo \
			/etc/yum.repos.d/CentOS-Debuginfo.repo \
			/etc/yum.repos.d/CentOS-Media.repo
		
		yum upgrade ca-certificates --disablerepo=epel
		#yum clean all && yum makecache
                yum -y install git
	else
		apt-get install -y git
	fi

        if [ ! -f /vagrant/vagrant/install_salt.sh ]; then
                curl -L http://bootstrap.saltstack.org -o install_salt.sh
                sh install_salt.sh -U git v2014.7.0rc7
        else
                sh /vagrant/vagrant/install_salt.sh -U git v2014.7.0rc7
        fi
fi

cat > /tmp/git-ssh.sh << EOF
#!/bin/bash
exec ssh -o StrictHostKeyChecking=no -o PasswordAuthentication=no \
	-o KbdInteractiveAuthentication=no \
	-o ChallengeResponseAuthentication=no \
	-i /vagrant/vagrant/vagrant.pem \$*
EOF
chmod +x /tmp/git-ssh.sh

#Local roots, for recipes developers
if [ ! -f /srv/salt/top.sls ]; then

cat > /etc/salt/minion.d/99-file-roots.conf << EOF

file_roots:
  base:
    - /opt/dws-ops/saltstack/file_roots

pillar_roots:
  base:
    - /opt/dws-ops/saltstack/pillar_roots

EOF

export GIT_SSH=/tmp/git-ssh.sh

if [ -d /opt/dws-ops ]; then
	cd /opt/dws-ops
	git pull
else
	cd /opt
	git clone git@github.com:startupdevs/dws-ops.git
fi

else

	rm -f /etc/salt/minion.d/99-file-roots.conf

fi

/etc/init.d/salt-minion restart
salt-call --local grains.setval environment vagrant
salt-call --local grains.setval branch dev
salt-call --local grains.setval roles "[ \"${ROLE}\" ]"
salt-call --local state.highstate

