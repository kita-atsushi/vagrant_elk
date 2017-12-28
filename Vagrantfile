# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # If you are using vagrant-vbguest plugin, remove below '#'.
  # config.vbguest.auto_update = false
  config.vm.box_check_update = false

  config.vm.define "master" do |s_01|
    s_01.vm.box = "bento/ubuntu-17.04"

    s_01.vm.network "private_network", ip: "192.168.33.101", virtualbox__intnet: "intnet"
    s_01.vm.network "forwarded_port", guest: 5601, host: 15601
    s_01.vm.network "forwarded_port", guest: 80, host: 10080
    s_01.vm.network "forwarded_port", guest: 8888, host: 18888

    s_01.vm.provider "virtualbox" do |s_01_vb|
      s_01_vb.cpus = 1
      s_01_vb.memory = "3072"
    end

    s_01.vm.provision "shell" do |s|
      s.env   = {
        "http_proxy" => ENV['http_proxy'],
        "https_proxy" => ENV['https_proxy']
      }
      s.inline = <<-SHELL
        bash /vagrant/tools/install/install_docker.sh
        bash /vagrant/tools/install/install_docker_compose.sh
        bash /vagrant/tools/elk/setup.sh
        bash /vagrant/tools/install/install_logstash.sh
      SHELL
    end
  end
end

