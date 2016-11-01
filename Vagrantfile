# -*- mode: ruby -*-
# vi: set ft=ruby :

required_plugins = %w( vagrant-hostsupdater )
required_plugins.each do |plugin|
  unless Vagrant.has_plugin? plugin
    raise "vagrant plugin '#{plugin}' is missing, install with 'vagrant plugin install #{plugin}'"
  end
end

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "ubuntu/xenial64"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: "192.168.23.42"
  config.vm.hostname = "media.ccc.vm"
  config.hostsupdater.remove_on_suspend = true

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
     # Customize the amount of memory on the VM:
     vb.memory = "4096"
     vb.cpus = 4
  end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "shell", inline: <<-SHELL
    echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
    export DEBIAN_FRONTEND="noninteractive"
    apt-get update
    apt-get install -y redis-server elasticsearch ruby2.3 ruby2.3-dev postgresql-9.5 nodejs libssl-dev build-essential libpq-dev libsqlite3-dev

    # postgresql
    echo "create role voctoweb with createdb login password 'voctoweb';" | sudo -u postgres psql

    # elasticsearch
    sed -i -e 's/#START_DAEMON/START_DAEMON/' /etc/default/elasticsearch
    systemctl restart elasticsearch
    cd /vagrant
    sudo gem install bundler
    sudo -u ubuntu -H bin/setup

    # Puma
    tee /etc/systemd/system/voctoweb-puma.service <<UNIT
[Unit]
Description=Puma application server for voctoweb
After=network.target vagrant.mount
Depends=vagrant.mount

[Service]
WorkingDirectory=/vagrant
Environment=RAILS_ENV=development
User=ubuntu
PIDFile=/vagrant/tmp/pids/puma.pid
ExecStart=/usr/local/bin/bundle exec rails s -b 0.0.0.0
Restart=always
SyslogIdentifier=voctoweb-puma
RestartSec=5s
StartLimitInterval=0

[Install]
WantedBy=default.target
Depends=vagrant.mount
UNIT
  systemctl enable voctoweb-puma
  systemctl start voctoweb-puma

  SHELL
end
