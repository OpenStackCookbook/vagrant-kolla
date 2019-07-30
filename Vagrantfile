# -*- mode: ruby -*-
# vi: set ft=ruby :

# Nodes:
#  controller-01    192.168.100.10
#  compute-01       192.168.100.13
#  openstack-client 192.168.100.99

# Interfaces
# eth0 - nat (used by VMware/VirtualBox)
# eth1 - br-mgmt (Container) 172.29.236.0/24
# eth2 - br-vlan (Neutron VLAN network) 0.0.0.0/0
# eth3 - host / API 192.168.100.0/24
# eth4 - br-vxlan (Neutron VXLAN Tunnel network) 172.29.240.0/24

nodes = {
    'kolla'  => [1, 20],
}

Vagrant.configure("2") do |config|

  if Vagrant.has_plugin?("vagrant-hostmanager")
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
    config.hostmanager.manage_guest = true
  else
    raise "[-] ERROR: Please add vagrant-hostmanager plugin:  vagrant plugin install vagrant-hostmanager"
  end

  # Defaults (VirtualBox)
  config.vm.box = "velocity42/xenial64"
  config.vm.synced_folder ".", "/vagrant", type: "nfs"

  if config.vm.provider :vmware_workstation
    # If we're running VMware Workstation (i.e. Linux)
      config.trigger.before :up do |trigger|
        trigger.info "[+] INFO: Ensuring /dev/vmnet* are correct to allow promiscuous mode."
        trigger.info "[+]       Needed for access to containers on different VMs."
        trigger.run "./fix_vmnet.sh"
      end
  end

  # VMware Fusion / Workstation
  config.vm.provider :vmware_fusion or config.vm.provider :vmware_workstation do |vmware, override|
    override.vm.box = "velocity42/xenial64"
    override.vm.synced_folder ".", "/vagrant", type: "nfs"

    # Fusion Performance Hacks
    vmware.vmx["logging"] = "FALSE"
    vmware.vmx["MemTrimRate"] = "0"
    vmware.vmx["MemAllowAutoScaleDown"] = "FALSE"
    vmware.vmx["mainMem.backing"] = "swap"
    vmware.vmx["sched.mem.pshare.enable"] = "FALSE"
    vmware.vmx["snapshot.disabled"] = "TRUE"
    vmware.vmx["isolation.tools.unity.disable"] = "TRUE"
    vmware.vmx["unity.allowCompostingInGuest"] = "FALSE"
    vmware.vmx["unity.enableLaunchMenu"] = "FALSE"
    vmware.vmx["unity.showBadges"] = "FALSE"
    vmware.vmx["unity.showBorders"] = "FALSE"
    vmware.vmx["unity.wasCapable"] = "FALSE"
    vmware.vmx["vhv.enable"] = "TRUE"
  end

  #Default is 2200..something, but port 2200 is used by forescout NAC agent.
  config.vm.usable_port_range = 2800..2900

  config.vm.graceful_halt_timeout = 120

  nodes.each do |prefix, (count, ip_start)|
    count.times do |i|
      if prefix == "compute" or prefix == "controller"
        hostname = "%s-%02d" % [prefix, (i+1)]
      else
        hostname = "%s" % [prefix, (i+1)]
      end

      config.ssh.insert_key = false

      config.vm.define "#{hostname}" do |box|
        box.vm.hostname = "#{hostname}.cook.book"
        box.vm.network :private_network, ip: "172.29.236.#{ip_start+i}", :netmask => "255.255.255.0"
        box.vm.network :private_network, ip: "10.10.0.#{ip_start+i}", :netmask => "255.255.255.0"
      	box.vm.network :private_network, ip: "192.168.100.#{ip_start+i}", :netmask => "255.255.255.0"
      	box.vm.network :private_network, ip: "172.29.240.#{ip_start+i}", :netmask => "255.255.255.0"

        box.vm.provision :shell, :path => "#{prefix}.sh"

        # Otherwise using VirtualBox
        box.vm.provider :virtualbox do |vbox|
          vbox.name = "#{hostname}"
          # Defaults
          vbox.linked_clone = true if Vagrant::VERSION =~ /^1.8/
          vbox.customize ["modifyvm", :id, "--memory", 4096]
          vbox.customize ["modifyvm", :id, "--cpus", 1]
          vbox.customize ["modifyvm", :id, "--nicpromisc1", "allow-all"]
          vbox.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
          vbox.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]
          vbox.customize ["modifyvm", :id, "--nicpromisc4", "allow-all"]
          vbox.customize ["modifyvm", :id, "--nicpromisc5", "allow-all"]
        end
      end
    end
  end
end
