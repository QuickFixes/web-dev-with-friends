# Full-stack Web Development—with Friends

Learn to build and share a ready-to-rock GNU/Linux virtual machine image with
your team, including a complete graphical development environment, all
necessary packages, and a preloaded, running "starter" web application,
accessible from a browser in the host OS.

For technical details on the VM provisioning setup, please see
[`vm/TECHNICAL.md`](vm/TECHNICAL.md).

## Installation

Every OS is going to require at a minimum:

* a [UC GitHub Enterprise][ucgh] or [GitHub.com][gh] account
* [VirtualBox] - a way to run "virtual machines"
* [Vagrant] - a way to automate the creation/setup of VMs

### Quick start

If you already know how to clone a repository from GitHub, then clone this
repository (`web-dev-with-friends`) to your computer and follow these steps:

On **Windows**:

1. Open a command prompt in the `web-dev-with-friends` directory (in Explorer,
   you can Shift+right click on the directory and pick "Open command window
   here"; [screenshot][cmdhere])
2. type in `setup.cmd` and press ENTER

On **Unix-like operating systems** (macOS / Linux):

macOS (née OS X) and most GNU/Linux distros will already have the tools you
need installed. If you get an error on Linux when you type `git` at the
command line, then install `git` (possibly `git-core`) from the distro's
package manager.

Then, paste these commands into a terminal (replacing the
`/path/to/your/dev/stuff` as applicable):

    cd ~/path/to/your/dev/stuff
    git clone git@github.com:QuickFixes/web-dev-with-friends.git
    cd web-dev-with-friends
    ./setup.sh

Replace `git@github.com` with `git@github.uc.edu` if you are a UC student and
don't have a GitHub(.com) account.

### Detailed instructions for Windows

In order to work productively with the VM image created by this
repository, you'll want a "genuine" [Unix shell][shell] that provides the
OpenSSH `ssh` binary.

_Learning how to use the Unix shell (e.g., Bash) is beyond the scope of this
workshop, but you can find some resources [here][artofcmdline]._

The easiest way to get started is by by installing the
[GitHub GUI][ghguiwin], which can be easily configured to provide a Bash
shell you can use to connect to the running VM.

Once installed, change the GitHub GUI settings as shown below:

![Switching to "Git Bash" shell in GUI settings](img/windows_github_gui_shell_settings.png)

Then browse to this repository (`web-dev-with-friends`)
[on github.com][thisrepogh] or [on github.uc.edu][thisrepouc] and click the
"Clone or download" button, followed by "Open in Desktop":

![Cloning a repository from the web with the GitHub GUI](img/github_open_in_desktop.png)

### Detailed instructions for macOS (née OS X)

With the Mac operating system (formerly known as OS X or Mac OS X), you
already have all the software you need to clone the repository from the
command line. Search using Spotlight (⌘ + space) for "terminal" if you
don't know where Terminal.app is found.

Vagrant and VirtualBox are, however, still required on a Mac; see above.

You might still prefer starting with the [GitHub GUI for Mac][ghguimac], and
that's fine. If you use the GitHub GUI on Mac, you can follow the same basic
steps as for Windows, above, to clone the `web-dev-with-friends` repo from the
web. You don't need to configure the "Git Bash" shell, because macOS is a Unix
operating system, and already comes with the Bash shell.

### Detailed instructions for GNU/Linux

On GNU/Linux, you'll want to _at a minimum_ install the `git-core` or `git`
[package] from your OS's package manager. [`git-cola`][gitcola] or `gitg`
would be good choices if you'd like a GUI.

## Connecting to the running VM

### Authentication

You will connect to the running virtual machine over SSH as the user
`vagrant`. This user is in the `sudoers` file (by way of being a
member of the group `sudo`), which means it can become the superuser (`root`)
with no password.

The Vagrant user's default password is `vagrant`.

If you have any problems with authentication, please refer to 
[`vm/TECHNICAL.md`](vm/TECHNICAL.md).

### Connecting to the VM over SSH

In order to connect with the VM over SSH, normally you would just type
`vagrant ssh` inside the `vm` subdirectory of this repository, wherever you
originally cloned this repository.

An error message to the effect of "Run \`vagrant init\` to create a new
Vagrant environment"

![You forgot to `cd vm` first.][vagrantwrong]

means that you forgot to `cd vm` before running `vagrant up` or `vagrant ssh`.
The `vagrant` command expects to be run in the same working directory as where
the [`Vagrantfile`](vm/Vagrantfile) lives.

![That's better.][vagrantright]

On Windows, you need to run this command inside of a Bash (or [Cygwin][])
shell, which the GitHub GUI for Windows provides, as long as you correctly
followed the instructions above.

You'll find additional advice about connecting over SSH (including using SFTP
programs like [Cyberduck][]) in [`vm/TECHNICAL.md`](vm/TECHNICAL.md).

### Forwarded ports

The [`Vagrantfile`](vm/Vagrantfile) will automatically create the following
forwarded ports for you. 

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

## Frequently-asked Questions

### What about Windows? ###

> Yes, what about Windows, indeed.

> That's part of the reason why this repository exists: to give your team
> a consistent working environment, independent of their "preferred" OS.

> However, since Windows lacks a sensible built-in command line and most of
> the tools necessary to do "full-stack" web development using open source
> technologies, you need a mishmash of software to fill in the gaps.

> Graphical Git clients such as the official GitHub GUI and [SourceTree][]
> help alleviate some of the pain of setting this all up, by bundling a
> functional Unix shell. The virtual machine you'll get after running the
> setup script in this repository is designed to provide everything you need
> to get _started_ with PHP or Python web development on the Apache HTTP
> server.

### What is this "Vagrant" thing and why is it necessary? ###

> It's not.
>
> But it saves you from having to distribute a potentially very large VM image
> to your team, which you have spent hours of your life custom crafting for
> _one_ GNU/Linux distribution's release, with _one_ specific purpose in mind.
>
> By putting these instructions in configuration files (which can be
> version-controlled with Git), you can build similar virtual machines
> for different projects with slightly different requirements **without
> duplicating all that effort**.

### What is this "Ansible" thing and why is it necessary? ###

> It's not.
>
> But it saves you from having to manually install a dozen different software
> packages, copy default configuration files, deployment SSH keys, or whatever
> else, over and over and over again, for each new project.
>
> Using [Ansible][] allows you to record these steps in a
> mostly-human-readable [YAML][] configuration file, which you can just clone
> and modify for your next project.

> These configuration files are like having _really_ comprehensive,
> version-controlled notes on everything you did to set up your development /
> hosting environment, and they can even be lightly modified to apply the same
> steps to a cloud-based host (Amazon AWS or a similar competitor).

### What is this "veewee" thing and why is it necessary? ###

> It's not.
>
> But it provides you with a complete blueprint of how to set up a virtual
> machine development environment for your team—beginning from the distro's
> installation ISO.
>
> This could come in handy if the Vagrant `.box` image became corrupted, or
> was otherwise lost through some data storage disaster.
>
> There is no requirement for anyone on your team to perform the steps
> discussed in [`vm/TECHNICAL.md`](vm/TECHNICAL.md) to rebuild the base box,
> but it saves *you* time when you make a clone of this repository for your
> _next_ project.
>
> Keep in mind, too, that this repository is a few hundred kilobytes. If your
> team is patient and doesn't mind downloading a 4.7 GB installation ISO, you
> actually don't even have to host the [Vagrant "base box"][basebox] anywhere
> on the 'net.

## References

1. Incorporates the ["VanillaJS" example][todovanilla] from the
   [TodoMVC project][todomvc] at revision [635fd9f][todomvcrev]  

[thisrepouc]: https://github.uc.edu/QuickFixes/web-dev-with-friends
[thisrepogh]: https://github.com/QuickFixes/web-dev-with-friends
[ucgh]: http://github.uc.edu
[gh]: https://github.com/login
[ghguiwin]: https://windows.github.com
[ghguimac]: https://mac.github.com
[virtualbox]: https://virtualbox.org
[vagrant]: https://vagrantup.com
[todovanilla]: http://todomvc.com/examples/vanillajs/
[todomvc]: https://github.com/tastejs/todomvc  
[todomvcrev]: https://github.com/tastejs/todomvc/commit/635fd9f79d9c12d731a968cd35a535e25c2f4e71
[cmdhere]: http://mingersoft.com/blog/2011/02/open-a-command-prompt-quickly-in-windows-7/
[shell]: https://en.m.wikipedia.org/wiki/Unix_shell
[artofcmdline]: https://github.com/jlevy/the-art-of-command-line
[ghfork]: https://help.github.com/articles/fork-a-repo/
[gitcola]: https://git-cola.github.io/index.html
[yaml]: https://en.m.wikipedia.org/wiki/YAML
[ansible]: https://docs.ansible.com/
[basebox]: https://www.vagrantup.com/docs/boxes/base.html
[cygwin]: http://cygwin.org/
[cyberduck]: https://cyberduck.io/
[vagrantwrong]: img/vagrant_up_in_wrong_directory.png
[vagrantright]: img/vagrant_up_in_right_directory.png
[sourcetree]: https://www.sourcetreeapp.com/
