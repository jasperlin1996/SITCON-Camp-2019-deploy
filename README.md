# Ansible deploy script for SITCON Camp 2019

## Usage:
* Scan ip & run vlc client
```shell
bash auto_deploy.sh
```
* Run vlc client ONLY (make sure u have a `sitcon2019_ip_0.txt` & `SITCON2019\_ip\_1.txt`)
```shell
ansible-playbook vlc.yml
```

* Killall vlc
```
ansible sitcon-camp -a "killall vlc"
```

