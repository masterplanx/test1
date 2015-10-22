# -*- mode: ruby -*-
# vi: set ft=ruby :

project = "hyperleap"

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |baseconfig|

  baseconfig.vm.define project do |config|
    
    config.vm.provider "virtualbox" do |v|
      v.customize ["modifyvm", :id, "--memory", 512]
      v.customize ["modifyvm", :id, "--cpus", 2]
    end

    config.vm.box = "bento/ubuntu-14.04"
    config.vm.network "forwarded_port", guest: 80, host: 6080
    config.vm.hostname = project

    #Use local file_roots for salt for developing purposes
    if ENV['LOCAL_ROOTS']
      config.vm.synced_folder ENV['LOCAL_ROOTS'] + "/file_roots/", "/srv/salt"
      config.vm.synced_folder ENV['LOCAL_ROOTS'] + "/pillar_roots/", "/srv/pillar"
    end

    #This provisioner doesn't support --local in salt-call. We use shell
    #provisioning and we do salt steps by hand.
    config.vm.provision "shell", path: "vagrant/salt-provision.sh", args: project

  end

end
