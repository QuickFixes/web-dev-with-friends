# VM development environment for Bioreactor

This directory contains configuration files which may be used to build
a development / test server environment for the [Bioreactor][] analysis
application.

The VM image is based on Debian 8.5.0 (codename "jessie"), using the "netinst"
ISO found here:

    http://cdimage.debian.org/debian-cd/8.5.0/arm64/iso-cd/

## Requirements

1. [Vagrant][] - to automatically configure and provision the VM
2. [PuTTY][] - on Windows, to connect to the VM over Secure Shell
3. [veewee][] - if and _only_ if you want to re-build the base box from scratch

## Installation

**Quick start**: run [`./setup.sh`][setupsh] in the base directory of this
repository

...which basically just performs these two steps for you:

```bash
BASEBOX=https://tf.cchmc.org/external/ern6xv/bioreactor-jessie.box
vagrant box add bioreactor $BASEBOX
vagrant up
```

As a backup, if for whatever reason the link to the `.box` file above becomes
unavailable, you might try this Google shared link as an alternative.

    https://FIXME

Failing that, you can see the
"[Re-building the base box](#re-building-the-base-box)" section below for
guidance on how to create the base VM image from the original Debian ISO.

### Authentication

The `vagrant` user on the VM is in the `sudoers` file (by way of being a
member of the group `sudo`), with no password.

Its default password is `vagrant` if you are prompted for authentication by
any programs on the VM that don't understand `sudoers`, or if you haven't set
up your [`~/.ssh/config`][mansshcfg] as described below, and you want to SSH or
SFTP into the VM using a different program (say, perhaps, [Cyberduck][]).

### Connecting to the VM over SSH

In order to connect with the VM over SSH, normally you would just type
`vagrant ssh` inside the directory where you originally cloned this
repository. However, you _can_ add an entry to your `~/.ssh/config`, allowing
you to also type `ssh vagrant` (or something even shorter) basically anywhere
in your path:

    # The 'Host' line in the ssh config can list multiple "aliases" for the same host
    Host vagrant vm v
        Host localhost
        Port 9922
        IdentityFile "/path/to/this/repo/.vagrant/machines/debian_jessie/virtualbox/private_key"

You can also use Vagrant's built in `vagrant ssh-config` as a (considerably
more complex) template for creating these SSH `config` entries for other
boxes, too.

```bash
cd /path/to/this/repo
vagrant ssh-config >> ~/.ssh/config
# ...then modify it to your liking
vim -c% ~/.ssh/config
```

The advantage of allowing `vagrant ssh` to handle the SSH connection is just
so: it will automatically know where to find the right public / private
keypair for passwordless authentication.

### Forwarded ports

The `Vagrantfile` will automatically create the following forwarded ports for
you. 

| Guest (VM) port forwards to...  | Host port #      | Notes                    |
| ------------------------------- | ---------------- | ------------------------ |
| 22                              | 9922             | Secure Shell (see below) |
| 80                              | [9980][lh9980]   | Apache HTTP server       |
| 5000                            | [55000][lh55000] | Python / Flask app       |

It was after some deliberation that I decided to stick with 55000 for the
Flask server, so that it wouldn't interfere with the default configuration of
a local Flask server you might be experimenting with. Just make a bookmark to
<http://localhost:55000> and remember that it goes with the Flask app running
on the VM.

## Installing Slurm on the VM

[Slurm][] is an open source workload manager (sometimes called a
"[job scheduler][jobschedwiki]," "batch scheduler," "job manager," or
something along those lines) which is similar to the Platform LSF scheduler
used in the Children's research division.

The process is not yet automatic (_i.e._, it is not performed as part of the
initial `vagrant up` provisioning), but there exists an Ansible playbook
in this repository with which you can easily install the necessary services.
This gives you a "mini-cluster" on the VM to which you can send batch jobs.

After the initial provisioning process is complete, SSH into the VM and run
the playbook like this:

```bash
# these steps performed while ssh'd into the VM as the 'vagrant' user
cd ~/devel/bioreactor-vm
bin/play.sh provisioning/set_up_slurm.yml
```

and hopefully, on a good day, that's it!

**SECURITY NOTE**: This will set up a MySQL server and a `slurm` database user
where both passwords can easily be read from the Ansible `group_vars/all`
config file in this repository. If deploying to a "production" server with
this same playbook, you'll need to choose real passwords. The process for
MySQL 5.5 is documented [here][mysqlpass].

### Testing to make sure it worked

You can test that the queue manager works like this (as a non-privileged
user):

```bash
cd # make sure you're in a writable directory like $HOME
sbatch <<<'#!/bin/bash
#SBATCH -J "First test job"
ls -lR'

# then, to make sure it worked
sacct -c
```

and the results should look something like this:
```
       JobID    UID    JobName  Partition   NNodes        NodeList      State                 End
------------ ------ ---------- ---------- -------- --------------- ---------- -------------------
2              1000 First tes+      debug        1        bioreactor  COMPLETED 2016-07-13T21:57:53
```

### See also

* "[Installing Slurm for testing][slurmwiki]" article on the
  [Bioreactor wiki][bioreactorwiki] - _for the manual steps necessary to accomplish
  what the playbook already does for you_

## Re-synchronizing with upstream changes

The `vagrant up` step above will run a Vagrant "shell provisioner" (basically
an inline shell script within the `Vagrantfile`) that will perform roughly
these steps:

* install read-only [deployment keys][ghdeploykeys] into the VM so that the
  `vagrant` user can clone the Bioreactor repositories
* clone the `bioreactor-vm` repository (where this `README` lives) into
  `~vagrant/devel` 
* invoke a shell script on the VM that will run a series of Ansible
  "playbooks", a sequence of tasks to automate sysadmin tasks such as
  installing packages and properly configuring the Apache server

If any upstream changes are made to these "playbooks," you may `git pull`
inside the `~vagrant/devel/bioreactor-vm` directory and then run
`./bin/self-provision.sh` to repeat the provisioning steps. The Ansible
provisioning process is [idempotent][], which means that you can re-run the
playbooks over and over and they shouldn't affect the state of the VM if the
required tasks have already been performed—only required steps that weren't
(successfully) completed before will be executed.

That being said, it wouldn't hurt to make sure that any uncommited changes to
the Bioreactor codebase have been committed and pushed (perhaps to a `dev` tree
in a private fork), just in case.

You can also just run `git pull` followed by `vagrant provision` in the
directory on your _host OS_ where you originally cloned this repository.

## Implementation details

### Where does the Vagrant "base box" comes from, anyhow?
The `bioreactor-jessie.box` file currently used by the setup script is stored
on `tf.cchmc.org` at this location:

    https://tf.cchmc.org/external/ern6xv/bioreactor-jessie.box

As a backup, there's also a copy stored in Google Drive:

    https://FIXME

If for some odd reason, you have already downloaded the base box you can
point the script at the existing `.box` file like so:

```bash
VAGRANT_BOX=~/Downloads/bioreactor-jessie.box ./setup.sh
```

or by altering the value of `VAGRANT_BOX` at the top of the script.

There's almost no reason why you would need to do this unless the production
Weirauch Lab server goes belly-up.

### Re-building the base box

On Mac OS X, you'll probably want to use [`rbenv`][rbenv] to download and
install a "modern" (_e.g._, 2.3.x) release of Ruby, because you're destined to
have problems with the OS version of Ruby (2.0.something) otherwise.

```bash
# MacPorts
sudo port install rbenv ruby-build
# Homebrew (not sure whether 'ruby-build' will come with)
brew install rbenv

# Initialize rbenv (follow the directions given to modify ~/.bash_profile)
rbenv init

# Get a (newer) Ruby interpreter; 'ruby-build' is required for this to work
rbenv install --list  # 2.3.0 is latest available 2.3.x as of this writing
rbenv install 2.3.0

# Switch into the repo base dir and tell 'rbenv' to use this Ruby version
cd ~/path/to/this/repo
rbenv local 2.3.0

# To work around a problem with libxml2 2.9.4, I think; refer to
# https://github.com/sparklemotion/nokogiri/issues/1119#issuecomment-68428866
gem install nokogiri -- --use-system-libraries
# Not properly downloaded as a dependency of 'veewee' for some reason
gem install net-scp
gem install veewee
```

#### Veewee SHA256 checksum verification bug
There's a bug in veewee 0.4.5.1 that causes the verification of a SHA256 sum
to fail, and it might not be fixed when you read this document. You can either
comment out the line that starts with `:iso_sha256` in
`definitions/bioreactor-jessie/definition.rb` or fix the `iso.rb` source file
contained in this inexplicably long path under
`~/.rbenv/versions/<RUBY_VERSION>`

```
lib/ruby/gems/<RUBY_VERSION>/gems/veewee-0.4.5.1/lib/veewee/provider/core/helper/iso.rb
```

Search for `rel_path` around [line 158 of `iso.rb`][veeweeisorb] and replace
it with `full_path`.

Hopefully then the rest of the commands below will work. Try `veewee version`
to make sure it got installed, and that the `rbenv` environment is working
properly.

#### Download Debian "Jessie" (8.x) ISO and create the Vagrant base box

```bash
# run inside the repo's base directory; setup should be fully-automatic
veewee vbox build bioreactor-jessie

# then package the running VM into a Vagrant '.box' file, which you
# can then upload somewhere
veewee vbox export bioreactor-jessie
```

[bioreactor]: https://github.uc.edu/Bioreactor/bioreactor
[veewee]: https://github.com/jedi4ever/veewee
[vagrant]: https://www.vagrantup.com/
[putty]: http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html
[rbenv]: https://github.com/rbenv/rbenv
[veeweeisorb]: https://github.com/jedi4ever/veewee/blob/master/lib/veewee/provider/core/helper/iso.rb#L158
[setupsh]: setup.sh 
[setupshline8]: setup.sh#L8
[ansible]: https://docs.ansible.com/
[ghdeploykeys]: https://developer.github.com/guides/managing-deploy-keys/#deploy-keys
[idempotent]: https://en.wikipedia.org/wiki/Idempotence 
[slurm]: http://slurm.schedmd.com/slurm.html
[slurmacct]: http://slurm.schedmd.com/accounting.html
[jobschedwiki]: https://en.wikipedia.org/wiki/Job_scheduler
[slurmwiki]: https://FIXME/Bioreactor/bioreactor/wiki/Installing-Slurm-for-testing
[bioreactorwiki]: https://github.uc.edu/Bioreactor/bioreactor/wiki
[mysqlpass]: https://dev.mysql.com/doc/refman/5.5/en/set-password.html
[cyberduck]: https://cyberduck.io/
[lh9980]: http://localhost:9980
[lh55000]: http://localhost:55000
[mansshcfg]: http://man.cx/ssh_config(4)
