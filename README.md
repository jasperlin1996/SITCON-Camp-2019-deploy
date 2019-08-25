# Ansible deploy script for SITCON Camp 2019

https://github.com/jasperlin1996/SITCON-Camp-2019-deploy

This is a solution for those PC classrooms which only support hardware screen mirroring.
This solution provides a real-time screen mirroring with **high video quality**, **high frame rate** and **low latency** between 1~2 seconds (according to our experience).

這裡為只有硬體廣播的電腦教室提供一個可行的軟體螢幕廣播的解決方案。根據我們實際使用的經驗，此解決方案能夠提供一個高畫質、高幀數並且**延遲介於一到兩秒**之間的實時螢幕廣播。

我們使用 SRS(https://github.com/ossrs/srs) 作為 RTMP server，以 OBS 串流螢幕畫面至該 server 之後，客戶端使用 VLC 收看。

P.S. 這個系統會對區域網路造成每秒 30 MiB 左右（60 台 Client）的流量壓力，SITCON Camp 2019 的主線課程約有 18 小時，在這 18 小時中，該 RTMP server 對內網發送了 2.3 TiB 的流量，你各位就自行評估一下XD。

## Stream flow
* Using ansible to automatically start all PC's VLC client
```flow
st=>start: OBS
op1=>operation: RTMP server
ed=>end: Every VLC Client

st(right)->op1(right)->ed
```

## System requirement

Actually, I don't know :p

We can only offer you which OS we've been used.

* RTMP server
    - Fedora 30
* OBS
    - Fedora 30
    - macOS Mojave 10.14.5
    - Windows 10
* Ansible 2.8.3
    - Fedora 30
    - macOS Mojave 10.14.5
* VLC
    - Fedora 30

## How to?
### SRS

https://github.com/ossrs/srs#Usage
#### 安裝過程
```bash=
# 下載原始碼
git clone https://github.com/ossrs/srs
# 切換正確資料夾
cd srs/trunk
# 設定並編譯
./configure && make
# 執行與指定使用的設定檔
./objs/srs -c conf/custom.conf
```

#### 優化過的設定檔
conf/custom.conf
```
listen              1935;
max_connections     1000;
daemon              off;
srs_log_tank        console;
vhost __defaultVhost__ {
    gop_cache       off;
    queue_length    10;
    min_latency     off;
    mr {
        enabled     off;
    }
    mw_latency      100;
    tcp_nodelay     on;
}
```

### OBS

* Stream
    * Service: Custom...
    * Server: `rtmp://srs.server.ip.addr/live` (e.g. 192.168.x.xxx)
    * Steam key: `livestream`
![](https://i.imgur.com/7wFDZ42.png)

### Ansible

https://github.com/ansible/ansible

Ansible 是一款開源的 ssh 應用部署工具，可以讓你快樂的：
* 幫大家裝好 VLC
* 幫大家開好 VLC
* 幫大家關好 VLC
* 幫大家關好電腦
* 幫大家打開瀏覽器
* ...

預設是使用金鑰登入，但老實說我不太會用 OuO
好像有看到 private key 的設定，但我傾向把 public key 丟給所有人。
> 本來就只能丟 public key 啊~~~~~

使用金鑰的好處：
* 不用把大家的密碼存在某個檔案裡
* 如果 remote 端改密碼的話不會連不進去


#### Install

* Fedora
```bash
sudo dnf install ansible
```

* macOS
```bash
brew install ansible
```

開個資料夾 `ansible-SITCON` 裡面放：
* ansible.cfg
* hosts
* xxx.yml

#### ansible.cfg
* `inventory` 指向 `hosts` 檔案，`hosts` 可以讓 ansible 知道到底要部署到哪裡，以及部署目標的資訊 (user_id, user_pass etc.)
* `host_key_checking = False`第一次 ssh 的時候會有個 key 的檢查，要記得 disable
```yaml
[defaults]
inventory = ./hosts
host_key_checking = False
```
#### hosts
:::info
hosts ip list 跟帳號的對應要怎麼快速生出來，這需要一點巧思(?)
我們這次的做法是 passwd 都是 `SITCON2019`，但 account 意外的有兩種 `sitcon2019`、`SITCON2019`。
我們的做法是先用 ansible 以 `sitcon2019` 對該網段 ping 過一輪然後再分析 log：
* SUCC $\rightarrow$ `sitcon2019`
* UNREACHABLE 且 Permission denied $\rightarrow$ `SITCON2019`

再用 shell script 切一下就完成了！

請依照各個電腦教室的環境狀況自行解決這個部分。
:::
##### Example
* `sitcon` & `SITCON` 是兩個不同的群組，為 `sitcon-camp` 的子群組
* `group:vars` 內的設定可以應用在 `group` 內的所有 hosts
* `all:vars` 內的設定可以應用在所有群組內的所有 hosts
* `ansible_ssh_user` 設定 ssh 登入用的 account name
* [option]`ansible_ssh_pass` 設定 ssh 登入用的 password（若使用 ssh key 登入則不需此項）
* [option]`ansible_sudo_pass` 設定 sudo 的密碼（若非必要則不需此項）
```yaml
[sitcon-camp:children]
sitcon
SITCON

[sitcon]
192.168.3.40
192.168.3.43

[SITCON]
192.168.3.38
192.168.3.44

[sitcon:vars]
ansible_ssh_user=sitcon2019

[SITCON:vars]
ansible_ssh_user=SITCON2019

[all:vars]
ansible_connection=ssh
ansible_ssh_pass=SITCON2019
ansible_sudo_pass=SITCON2019
```

### vlc.yml
:::info
如果有內建模組的話，更推薦直接使用該模組，盡量先不要用 command 或是 shell 模組，這樣會比較安全一點。
:::

* Usage: `ansible-playbook xxx.yml`
* `hosts` 指定 group
* `tasks` 列出任務們
    * `name` 部署執行時會顯示的任務名稱，填你看得懂的就好了
    * [option]`sudo: yes` 可以用 sudo 執行該指令
    * 之後放 ansible 的模組 `module: command`，例如
        * `command`
        * `shell`
        * `copy`
        * `yum`
        * ...
        * https://docs.ansible.com/ansible/latest/modules/modules_by_category.html

* Install vlc
```
- hosts: sitcon-camp
  tasks:
    - name: Install vlc
      sudo: yes
      shell: dnf install -y vlc
```
* Run vlc 
```
- hosts: sitcon-camp
  tasks:
    - name: Run vlc
      shell: nohup cvlc --x11-display :0 "rtmp://192.168.3.122/live/livestream" &
```
* Stop vlc
```
ansible sitcon-camp -a "killall vlc"
```
or
```
- hosts: sitcon-camp
  tasks:
    - name: Stop vlc
      shell: killall vlc
```

## Script usage (for SITCON Camp 2019 only)
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
