Vagrant.configure("2") do |config|
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true

  config.vm.box = "local/debian-bullseye"

  config.vm.provider "parallels" do |pa|
    pa.memory = "2048"
    pa.cpus = "2"
  end

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "playbook.yaml"
    ansible.raw_arguments = ['-e pipelining=True']
  end

  config.vm.define "kube-control-plane" do |node|
    node.vm.network :private_network, ip: '10.10.0.10'
    node.vm.hostname = "kube-control-plane"
  end

  config.vm.define "kube-node" do |node|
    node.vm.network :private_network, ip: '10.10.0.11'
    node.vm.hostname = "kube-node"
  end

end
