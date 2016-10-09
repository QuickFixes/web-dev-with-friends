# Add Ansible to the VM

# 'libyaml-dev' might not be strictly required, but it should suppress this
# error from PyYAML:
#
#    [...]check_libyaml.c:2:18: fatal error: yaml.h: No such file or directory
#
# the 'libffi-dev' tip came from: https://stackoverflow.com/a/31508663
apt-get install -y python-pip python-dev libffi-dev libyaml-dev

# *try* to install Ansible; this will likely fail with some weird error about 
pip install ansible

# (Possibly required, under some weird circumstances) workaround
# for 'ImportError: No module named setuptools_ext' error when
# building/installing the 'cryptography' package, courtesy of
# https://github.com/byt3bl33d3r/MITMf/issues/163
pip install --upgrade cffi cryptography markupsafe ansible
