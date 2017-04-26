Vagrant for running WordPress on AWS

This Vagrantfile and provisioning script sets up a web server running a current version of WordPress on AWS.  
The assumption is that you'll replace the site with one that you develop locally (e.g. using wordmove).

Instructions
============

* (Outside the scope of these instructions) Get your AWS account setup with appropriate security credentials including a local key pair "pemfile" and secret access key/id...  Make sure you can connect to AWS in the shell (command line) before continuing... AWS have an "AWS Educate Starter Account" that does not require a credit card, or use a standard account and apply for a student deal: https://aws.amazon.com/education/awseducate
* **AWS:** You need to set up your default security group (or another one if you change that in the Vagrantfile) so that it allows inbound traffic
* Install AWS Vagrant plugin: `vagrant plugin install aws-vagrant plugin`
* Download the dummy box: `vagrant box add dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box`
* **Windows:** There may be some other setup required for Windows, including making sure `rsync` is available
* Copy or rename the `private-sample.yml` file to `private.yml`
* Replace the values in that file with your AWS security credentials & what you want to call the instance in AWS
* Edit the `config.sh` file, replacing any values you want to change (defaults here work, but passwords are not strong)
* Run `vagrant up` in the directory for this project. This should connect to your AWS account, install a Ubuntu 14.04 image, run the provisioning script (bootstrap.sh) to install web server software including nginx, MariaDB (MySql) and php, create MySql database and user, download and install WordPress (if you opted for it in the config), and show you the IP address (public URL) of the new AWS instance
* Load that IP address in your browser to see your new WordPress site (add the directory name if you opted for a subdirectory in your config) :)
* You can run `vagrant ssh` to ssh into your new instance
* Use the AWS EC2 console to see your instance details and do AWS stuff (it's also fun to watch and see the instance getting made/initialised/destroyed)
* If you don't get quite what you want, just run `vagrant destroy -f` to shut down and remove the instance, then modify the options files and run `vagrant up` again.  This is one of the neat things about running VMs this way; it's quick and easy to make changes and start again

Wordmove
========

Wordmove is a very nice (Ruby gem) tool for copying WordPress sites between different environments:  https://github.com/welaika/wordmove  
You install Wordmove in your _local_ environment, not the remote, so this Vagrant setup does not need to install it in your remote AWS site, but it does provide a starter `Movefile`, with values that are nearly ready to go.  
The values assume you're using VVV locally.  
Once you have installed Wordmove in your local environment, and setup your AWS site, copy this Movefile into the root folder of the WordPress install you want to push/pull, then update the values.

Note: if you are using VVV (with ruby 2.4), you need to run `rvm group add rvm "$USER"` in VVV (after `vagrant ssh`) then log out of the shell session and back in again _before_ installing Wordmove.  
If you get an error something like "sql_adapter.rb:44:in 'gsub!': invalid byte sequence in US-ASCII", edit your .profile file as described in the Wordmove wiki: https://github.com/welaika/wordmove/wiki/invalid-byte-sequence-in-UTF-8-while-pushing---pulling-db

Extending
=========

This is meant to be a fairly simple but complete way to setup WordPress hosting on AWS, but you can customise and extend it as you like.  

* Edit the `bootstrap.sh` file to add any packages you want installed to the `apt_package_install_list` list, as well as any other shell commands you want to run
* See how the `.inputrc` file is copied to the new instance using the command near the end of the Vagrantfile?  You can do that with any other custom preference files (e.g. .vimrc or .profile) you want in your new system.

Acknowledgements
================

* I have created this based on various tutorials and samples on the web, as mentioned in the files. Thank you to those who have explained their work for us to benefit from :)
* Feel free to fork this and do what you want with it. If you publish your own version online be sure that you don't include your private AWS credentials.
