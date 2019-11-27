# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|

  config.vm.define "version-control" do |subconfig|
    subconfig.vm.box = "ubuntu/bionic64"
    subconfig.vm.hostname = "version-control"
    subconfig.vm.network "private_network", ip: "10.0.0.2"
    subconfig.vm.synced_folder "version-control/src/", "/home/vagrant/src"
  end


  config.vm.define "broker" do |subconfig|
    subconfig.vm.box = "ubuntu/bionic64"
    subconfig.vm.hostname = "broker"
    subconfig.vm.network "private_network", ip: "10.0.0.3"
    subconfig.vm.network "forwarded_port", guest: 5672, host: 5672
    subconfig.vm.network "forwarded_port", guest: 15672, host: 15672
    subconfig.vm.provision "shell", path: "broker/provision-broker.sh", env: {
      RABBITMQ_LOG_USER: "${RABBITMQ_LOG_USER:-log}",
      RABBITMQ_LOG_PASS: "${RABBITMQ_LOG_PASS:-logpass}",
      RABBITMQ_WEB_USER: "${RABBITMQ_WEB_USER:-web}",
      RABBITMQ_WEB_PASS: "${RABBITMQ_WEB_PASS:-webpass}",
      RABBITMQ_DMZ_USER: "${RABBITMQ_DMZ_USER:-dmz}",
      RABBITMQ_DMZ_PASS: "${RABBITMQ_DMZ_PASS:-dmzpass}",
      RABBITMQ_ADMIN_USER: "${RABBITMQ_ADMIN_USER:-admin}",
      RABBITMQ_ADMIN_PASS: "${RABBITMQ_ADMIN_PASS:-adminpass}",
    }
  end


  config.vm.define "dmz" do |subconfig|
    subconfig.vm.box = "ubuntu/bionic64"
    subconfig.vm.hostname = "dmz"
    subconfig.vm.network "private_network", ip: "10.0.0.4"
    subconfig.vm.synced_folder "packages/", "/opt/packages"
    subconfig.vm.provision "shell", path: "dmz/provision-dmz.sh"
  end


  config.vm.define "web" do |subconfig|
    subconfig.vm.box = "ubuntu/bionic64"
    subconfig.vm.hostname = "web"
    subconfig.vm.network "private_network", ip: "10.0.0.5"
    subconfig.vm.network "forwarded_port", guest: 5000, host: 5000
    subconfig.vm.synced_folder "packages/", "/opt/packages"
    subconfig.vm.provision "file", source: "web/motd", destination: "/tmp/motd"
    subconfig.vm.provision "shell", path: "web/provision-web.sh"
  end


  config.vm.define "db" do |subconfig|
    subconfig.vm.box = "ubuntu/bionic64"
    subconfig.vm.hostname = "db"
    subconfig.vm.network "private_network", ip: "10.0.0.6"
    subconfig.vm.network "forwarded_port", guest: 80, host: 3380
    #subconfig.vm.synced_folder "db/data/", "/var/lib/mysql"
    subconfig.vm.synced_folder "packages/", "/opt/packages"
    subconfig.vm.provision "file", source: "db/motd", destination: "/tmp/motd"
    subconfig.vm.provision "shell", path: "db/provision-db.sh", env: {
      MYSQL_DB: "${MYSQL_DB:-carcalendar}",
      MYSQL_USER: "${MYSQL_USER:-db}",
      MYSQL_PASS: "${MYSQL_PASS:-dbpass}",
    }
  end

end
