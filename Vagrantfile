# -*- mode: ruby -*-
# vi: set ft=ruby :

# based on https://www.yobyot.com/aws/a-primer-on-using-vagrant-with-aws-to-launch-ec2-instances/2015/12/04/, http://blog-osshive.rhcloud.com/2014/02/05/provisioning-aws-instances-with-vagrant/ and others

require 'yaml'

# Load private AWS credentials from external file
if File.exist?("private.yml")
  aws_config  = YAML.load_file("private.yml")["aws"]
end

require "vagrant-aws"
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # base box is just a 'dummy' for AWS, then the AMI
  config.vm.box = "dummy"

  config.vm.provider 'aws' do |aws, override|
    override.nfs.functional = false
    # Use private AWS variables loaded from YAML file
    aws.access_key_id = aws_config["access_key_id"]
    aws.secret_access_key = aws_config["secret_access_key"]
    aws.keypair_name = aws_config["keypair_name"]
    override.ssh.private_key_path = aws_config["pemfile"]

    # AWS configuration details, in the order that Vagrant lists them in its output
    # Use whatever instance type, ami, and region you like, just make sure they can all work together
    aws.instance_type = 't2.micro'
    aws.ami = 'ami-cdcdcfae'
    # trusty (Ubuntu 14.04) hvm:ebs type suitable for free tier
    # (found using http://cloud-images.ubuntu.com/locator/ec2/)
    aws.region = 'ap-southeast-2'
    # Specify security group(s), by name here because using the default VPC
    # Brackets are not strictly required if you have only one value, but they show that
    # technically this is an array that could hold multiple values.
    aws.security_groups = ['default']
    # Specify username on remote machine (here, the default for the AMI)
    override.ssh.username = 'ubuntu'
    aws.tags = {
      'Name' => aws_config["instance_name"],
      'Description' => aws_config["instance_desc"]
    }
  end

  # Share an additional folder to the guest VM. The first argument is the path on the host to the actual folder.
  # The second argument is the path on the guest to mount the folder.
  # NOTE: this folder is hard-coded here, and a variable in config... change it in both places if you change it
  config.vm.synced_folder "./html", "/var/www/html"
  # the following, might work for rsync issues on Windows (http://stackoverflow.com/questions/34176041/vagrant-with-virtualbox-on-windows10-rsync-could-not-be-found-on-your-path)
  # config.vm.synced_folder ".", "/vagrant", type: "virtualbox"

  # Enable provisioning with a shell script that runs after first setup of your box
  config.vm.provision :shell, path: "bootstrap.sh"
  # copy user preferences files to the system
  # add whatever other files you want here
  config.vm.provision "file", source: "./.inputrc", destination: "/home/ubuntu/.inputrc"
end
