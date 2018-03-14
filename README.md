# Vagrant for running WordPress on AWS

This Vagrantfile and provisioning script set up an AWS EC2 instance as a web server running a current version of WordPress.  
The use-case is that you will replace the site with one that you develop locally (e.g. using Wordmove).

Instructions
============

**AWS:**  
AWS have an "AWS Educate Starter Account" that does not require a credit card. Or you can use a standard account and apply for a student deal: https://aws.amazon.com/education/awseducate  

(Full details are outside the scope of these instructions)  
You will need to setup and know your (appropriate) AWS security credentials:  


* Create a local *key pair* "pemfile" (EC2 / Key Pairs - Create Key Pair) and save this locally. Set its permissions to 400 (user readable only): `chmod 400 /path/pemfile`
* Create an *Access Key ID* and *Secret access key* (IAM / Users / Security Credentials - Create access key) and enter these values into the private YAML file (see below).
* Set your EC2 default security group (EC2 / Security Groups) so that it allows inbound traffic (All traffic, 0.0.0.0/0)
* You might want to make sure you can connect to AWS in the shell (command line) before continuing...

**Local (Terminal):**
* Install AWS Vagrant plugin: `vagrant plugin install aws-vagrant plugin`
* Download the dummy box: `vagrant box add dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box`
* **Windows:** There may be some other setup required for Windows, including making sure `rsync` is available
* Copy or rename the file `private-sample.yml` to `private.yml`
* Replace the values in that file with your AWS security credentials (see above) & what you want to call the instance in AWS
* Edit the `config.sh` file, replacing any values you want to change (defaults here work, but passwords are weak)
* Run `vagrant up` in the directory for this project. This should connect to your AWS account, install a Ubuntu 14.04 image, run the provisioning script (bootstrap.sh) to install web server software including nginx, MariaDB (MySql) and PHP, create MySql database and user, download and install WordPress (unless you changed that in the config), and show you the IP address (public URL) of the new AWS instance!
* Load that IP address in your browser to see your new WordPress site on AWS (add the directory name if you opted for a subdirectory in your config) :)
* You can run `vagrant ssh` to SSH into your new instance
* Use the AWS EC2 console to see your instance details and do AWS stuff (it's also fun to watch and see the instance getting made/initialised/destroyed)
* If you don't get quite what you want, just run `vagrant destroy -f` to shut down and remove the instance, then modify the config files and run `vagrant up` again.  This is one of the neat things about running VMs this way; it's quick and easy to make changes and start again

Passwordless SSH
----------------

You will want to be able to SSH into your new AWS EC2 instance from your local VM (e.g. VVV), so we're going to copy a public key from local to remote. (There are other ways to do this using `ssh-copy-id` but this way seems easiest.)

* `vagrant ssh` into your local VM
* Run `ssh-keygen` to create a new public/private key pair (accept the defaults and leave a blank passphrase)
* Run `cat ~/.ssh/id_rsa.pub` to display your public key on the screen. Select and copy this, making sure you don't get any extra whitespace or text.
* In your remote VM (awswordpress) folder, run `vagrant ssh` (so you're connected to your AWS machine)
* Edit the file `~/.ssh/authorized_keys` and carefully paste the key you copied (each key is a single line)
* Now try to connect from your local VM (i.e. from VVV, not your main host OS) with the command `ssh ubuntu@1.2.3.4` (where 1.2.3.4 is the public IP of your AWS machine). If this works, then Wordmove will be able to do its magic... If it doesn't work, the most likely cause is that your key was not copied-and-pasted perfectly (e.g. you have a line break that isn't in the original).

Wordmove
--------

Wordmove is a very nice (Ruby gem) tool for copying WordPress sites between different environments:  https://github.com/welaika/wordmove  
You install Wordmove in your _local_ environment, not the remote (or your main host OS), so this Vagrant setup does not need to install it in your remote AWS site, but it does provide a starter `movefile.yaml`, with values that are nearly ready to go.  
The values assume you're using VVV locally.  
Once you have installed Wordmove in your local environment, and setup your AWS site, copy this movefile.yaml into the root folder of the WordPress install (e.g. `/vagrant/www/wordpress-default` for VVV) that you want to push/pull, then update the values to suit your environments.

Note: if you are using VVV (with ruby 2.4), you need to run (in VVV after `vagrant ssh`) `sudo chmod -R 777 /usr/local/rvm/gems/ruby-2.4.1` then `gem install wordmove`.  
If you get an error something like "sql_adapter.rb:44:in 'gsub!': invalid byte sequence in US-ASCII", edit your .profile file as described in the Wordmove wiki: https://github.com/welaika/wordmove/wiki/invalid-byte-sequence-in-UTF-8-while-pushing---pulling-db

Extending
=========

This is meant to be a fairly simple but complete way to setup WordPress hosting on AWS, but you can customise and extend it as you like.  

* Edit the `bootstrap.sh` file to add any packages you want installed to the `apt_package_install_list` list, as well as any other shell commands you want to run
* See how the `.inputrc` file is copied to the new instance using the command near the end of the Vagrantfile?  You can do that with any other custom preference files (e.g. .vimrc or .profile) you want in your new system.

Acknowledgements
================

* I have created this based on various tutorials and samples on the web, as mentioned in the files. Thank you to those who have explained their work for us to benefit from :)
* Feel free to fork this and do what you want with it. Send me a pull request if you can improve/fi something. If you do publish your own version online be sure that you don't include your private AWS/WordPress credentials.
