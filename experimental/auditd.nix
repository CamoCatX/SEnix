{ pkgs, config, lib, ... }:
{
  security.auditd.enable = true;
  security.audit.enable = true;
  security.audit.rules = [
    
# /etc/audit/audit.rules
#
# Thanks to Florian Roth

# Buffer Size
## Feel free to increase this if the machine panics
"-b 8192"

# Failure Mode
## Possible values: 0 (silent), 1 (printk, print a failure message), 2 (panic, halt the system)
"-f 1"

# Ignore errors
## e.g. caused by users or files not found in the local environment
"-i"

# Self Auditing ---------------------------------------------------------------

## Audit the audit logs
### Successful and unsuccessful attempts to read information from the audit records
"-w /var/log/audit/ -p wra -k auditlog"
"-w /var/audit/ -p wra -k auditlog"

## Auditd configuration
### Modifications to audit configuration that occur while the audit collection functions are operating
"-w /etc/audit/ -p wa -k auditconfig"
"-w /etc/libaudit.conf -p wa -k auditconfig"
"-w /etc/audisp/ -p wa -k audispconfig"

## Monitor for use of audit management tools
"-w /sbin/auditctl -p x -k audittools"
"-w /sbin/auditd -p x -k audittools"
"-w /usr/sbin/auditd -p x -k audittools"
"-w /usr/sbin/augenrules -p x -k audittools"

## Access to all audit trails

"-a always,exit -F path=/usr/sbin/ausearch -F perm=x -k audittools"
"-a always,exit -F path=/usr/sbin/aureport -F perm=x -k audittools"
"-a always,exit -F path=/usr/sbin/aulast -F perm=x -k audittools"
"-a always,exit -F path=/usr/sbin/aulastlogin -F perm=x -k audittools"
"-a always,exit -F path=/usr/sbin/auvirt -F perm=x -k audittools"

# Filters ---------------------------------------------------------------------

### We put these early because audit is a first match wins system.

## Ignore SELinux AVC records
"-a always,exclude -F msgtype=AVC"

## Ignore current working directory records
"-a always,exclude -F msgtype=CWD"

## Cron jobs fill the logs with stuff we normally don't want (works with SELinux)
"-a never,user -F subj_type=crond_t"
"-a never,exit -F subj_type=crond_t"

## This prevents chrony from overwhelming the logs
"-a never,exit -F arch=b64 -S adjtimex -F auid=-1 -F uid=chrony -F subj_type=chronyd_t"

## This is not very interesting and wastes a lot of space if the server is public facing
"-a always,exclude -F msgtype=CRYPTO_KEY_USER"

## Open VM Tools
"-a exit,never -F arch=b64 -S all -F exe=/usr/bin/vmtoolsd"

## High Volume Event Filter (especially on Linux Workstations)
"-a never,exit -F arch=b64 -F dir=/dev/shm -k sharedmemaccess"
"-a never,exit -F arch=b64 -F dir=/var/lock/lvm -k locklvm"

## FileBeat
"-a never,exit -F arch=b64 -F path=/opt/filebeat -k filebeat"

## More information on how to filter events
### https://access.redhat.com/solutions/2482221

# Rules -----------------------------------------------------------------------

## Kernel parameters
"-w /etc/sysctl.conf -p wa -k sysctl"
"-w /etc/sysctl.d -p wa -k sysctl"

## Kernel module loading and unloading
-a always,exit -F perm=x -F auid!=-1 -F path=/sbin/insmod -k modules
-a always,exit -F perm=x -F auid!=-1 -F path=/sbin/modprobe -k modules
-a always,exit -F perm=x -F auid!=-1 -F path=/sbin/rmmod -k modules
-a always,exit -F arch=b64 -S finit_module -S init_module -S delete_module -F auid!=-1 -k modules

## Modprobe configuration
-w /etc/modprobe.conf -p wa -k modprobe
-w /etc/modprobe.d -p wa -k modprobe

## KExec usage (all actions)
-a always,exit -F arch=b64 -S kexec_load -k KEXEC

## Special files
-a always,exit -F arch=b64 -S mknod -S mknodat -k specialfiles

## Mount operations (only attributable)
-a always,exit -F arch=b64 -S mount -S umount2 -F auid!=-1 -k mount

### NFS mount
-a always,exit -F path=/sbin/mount.nfs -F perm=x -F auid>=500 -F auid!=4294967295 -k T1078_Valid_Accounts
-a always,exit -F path=/usr/sbin/mount.nfs -F perm=x -F auid>=500 -F auid!=4294967295 -k T1078_Valid_Accounts

## Change swap (only attributable)
-a always,exit -F arch=b64 -S swapon -S swapoff -F auid!=-1 -k swap

## Time
-a always,exit -F arch=b64 -F uid!=ntp -S adjtimex -S settimeofday -S clock_settime -k time
### Local time zone
-w /etc/localtime -p wa -k localtime

## Stunnel
-w /usr/sbin/stunnel -p x -k stunnel
-w /usr/bin/stunnel -p x -k stunnel

## Cron configuration & scheduled jobs
-w /etc/cron.allow -p wa -k cron
-w /etc/cron.deny -p wa -k cron
-w /etc/cron.d/ -p wa -k cron
-w /etc/cron.daily/ -p wa -k cron
-w /etc/cron.hourly/ -p wa -k cron
-w /etc/cron.monthly/ -p wa -k cron
-w /etc/cron.weekly/ -p wa -k cron
-w /etc/crontab -p wa -k cron
-w /var/spool/cron/ -p wa -k cron

## User, group, password databases
-w /etc/group -p wa -k etcgroup
-w /etc/passwd -p wa -k etcpasswd
-w /etc/gshadow -k etcgroup
-w /etc/shadow -k etcpasswd
-w /etc/security/opasswd -k opasswd

## Sudoers file changes
-w /etc/sudoers -p wa -k actions
-w /etc/sudoers.d/ -p wa -k actions

## Passwd
-w /usr/bin/passwd -p x -k passwd_modification

## Tools to change group identifiers
-w /usr/sbin/groupadd -p x -k group_modification
-w /usr/sbin/groupmod -p x -k group_modification
-w /usr/sbin/addgroup -p x -k group_modification
-w /usr/sbin/useradd -p x -k user_modification
-w /usr/sbin/userdel -p x -k user_modification
-w /usr/sbin/usermod -p x -k user_modification
-w /usr/sbin/adduser -p x -k user_modification

## Login configuration and information
-w /etc/login.defs -p wa -k login
-w /etc/securetty -p wa -k login
-w /var/log/faillog -p wa -k login
-w /var/log/lastlog -p wa -k login
-w /var/log/tallylog -p wa -k login

## Network Environment
### Changes to hostname
-a always,exit -F arch=b64 -S sethostname -S setdomainname -k network_modifications

### Detect Remote Shell Use
-a always,exit -F arch=b64 -F exe=/bin/bash -F success=1 -S connect -k "remote_shell"
-a always,exit -F arch=b64 -F exe=/usr/bin/bash -F success=1 -S connect -k "remote_shell"

### Successful IPv4 Connections
-a always,exit -F arch=b64 -S connect -F a2=16 -F success=1 -F key=network_connect_4

### Successful IPv6 Connections
-a always,exit -F arch=b64 -S connect -F a2=28 -F success=1 -F key=network_connect_6

### Changes to other files
-w /etc/hosts -p wa -k network_modifications
-w /etc/sysconfig/network -p wa -k network_modifications
-w /etc/sysconfig/network-scripts -p w -k network_modifications
-w /etc/network/ -p wa -k network
-a always,exit -F dir=/etc/NetworkManager/ -F perm=wa -k network_modifications

### Changes to issue
-w /etc/issue -p wa -k etcissue
-w /etc/issue.net -p wa -k etcissue

## System startup scripts
-w /etc/inittab -p wa -k init
-w /etc/init.d/ -p wa -k init
-w /etc/init/ -p wa -k init

## Library search paths
-w /etc/ld.so.conf -p wa -k libpath
-w /etc/ld.so.conf.d -p wa -k libpath

## Systemwide library preloads (LD_PRELOAD)
-w /etc/ld.so.preload -p wa -k systemwide_preloads

## Pam configuration
-w /etc/pam.d/ -p wa -k pam
-w /etc/security/limits.conf -p wa  -k pam
-w /etc/security/limits.d -p wa  -k pam
-w /etc/security/pam_env.conf -p wa -k pam
-w /etc/security/namespace.conf -p wa -k pam
-w /etc/security/namespace.d -p wa -k pam
-w /etc/security/namespace.init -p wa -k pam

## Mail configuration
-w /etc/aliases -p wa -k mail
-w /etc/postfix/ -p wa -k mail
-w /etc/exim4/ -p wa -k mail

## SSH configuration
-w /etc/ssh/sshd_config -k sshd
-w /etc/ssh/sshd_config.d -k sshd

## root ssh key tampering
-w /root/.ssh -p wa -k rootkey

# Systemd
-w /bin/systemctl -p x -k systemd
-w /etc/systemd/ -p wa -k systemd
-w /usr/lib/systemd -p wa -k systemd

## https://systemd.network/systemd.generator.html
-w /etc/systemd/system-generators/ -p wa -k systemd_generator
-w /usr/local/lib/systemd/system-generators/ -p wa -k systemd_generator
-w /usr/lib/systemd/system-generators -p wa -k systemd_generator

-w /etc/systemd/user-generators/ -p wa -k systemd_generator
-w /usr/local/lib/systemd/user-generators/ -p wa -k systemd_generator
-w /lib/systemd/system-generators/ -p wa -k systemd_generator

## SELinux events that modify the system's Mandatory Access Controls (MAC)
-w /etc/selinux/ -p wa -k mac_policy

## Critical elements access failures
-a always,exit -F arch=b64 -S open -F dir=/etc -F success=0 -k unauthedfileaccess
-a always,exit -F arch=b64 -S open -F dir=/bin -F success=0 -k unauthedfileaccess
-a always,exit -F arch=b64 -S open -F dir=/sbin -F success=0 -k unauthedfileaccess
-a always,exit -F arch=b64 -S open -F dir=/usr/bin -F success=0 -k unauthedfileaccess
-a always,exit -F arch=b64 -S open -F dir=/usr/sbin -F success=0 -k unauthedfileaccess
-a always,exit -F arch=b64 -S open -F dir=/var -F success=0 -k unauthedfileaccess
-a always,exit -F arch=b64 -S open -F dir=/home -F success=0 -k unauthedfileaccess
-a always,exit -F arch=b64 -S open -F dir=/srv -F success=0 -k unauthedfileaccess

## Process ID change (switching accounts) applications
-w /bin/su -p x -k priv_esc
-w /usr/bin/sudo -p x -k priv_esc

## Power state
-w /sbin/shutdown -p x -k power
-w /sbin/poweroff -p x -k power
-w /sbin/reboot -p x -k power
-w /sbin/halt -p x -k power

## Session initiation information
-w /var/run/utmp -p wa -k session
-w /var/log/btmp -p wa -k session
-w /var/log/wtmp -p wa -k session

## Discretionary Access Control (DAC) modifications
-a always,exit -F arch=b64 -S chmod  -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S chown -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S fchmod -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S fchmodat -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S fchown -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S fchownat -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S fremovexattr -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S fsetxattr -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S lchown -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S lremovexattr -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S lsetxattr -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S removexattr -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S setxattr -F auid>=1000 -F auid!=-1 -k perm_mod

# Special Rules ---------------------------------------------------------------

## Reconnaissance
-w /usr/bin/whoami -p x -k recon
-w /usr/bin/id -p x -k recon
-w /bin/hostname -p x -k recon
-w /bin/uname -p x -k recon
-w /etc/issue -p r -k recon
-w /etc/hostname -p r -k recon

## Suspicious activity
-w /usr/bin/wget -p x -k susp_activity
-w /usr/bin/curl -p x -k susp_activity
-w /usr/bin/base64 -p x -k susp_activity
-w /bin/nc -p x -k susp_activity
-w /bin/netcat -p x -k susp_activity
-w /usr/bin/ncat -p x -k susp_activity
-w /usr/bin/ss -p x -k susp_activity
-w /usr/bin/netstat -p x -k susp_activity
-w /usr/bin/ssh -p x -k susp_activity
-w /usr/bin/scp -p x -k susp_activity
-w /usr/bin/sftp -p x -k susp_activity
-w /usr/bin/ftp -p x -k susp_activity
-w /usr/bin/socat -p x -k susp_activity
-w /usr/bin/wireshark -p x -k susp_activity
-w /usr/bin/tshark -p x -k susp_activity
-w /usr/bin/rawshark -p x -k susp_activity
-w /usr/bin/rdesktop -p x -k susp_activity
-w /usr/local/bin/rdesktop -p x -k susp_activity
-w /usr/bin/wlfreerdp -p x -k susp_activity
-w /usr/bin/xfreerdp -p x -k susp_activity
-w /usr/local/bin/xfreerdp -p x -k susp_activity
-w /usr/bin/nmap -p x -k susp_activity

## sssd
-a always,exit -F path=/usr/libexec/sssd/p11_child -F perm=x -F auid>=500 -F auid!=4294967295 -k T1078_Valid_Accounts
-a always,exit -F path=/usr/libexec/sssd/krb5_child -F perm=x -F auid>=500 -F auid!=4294967295 -k T1078_Valid_Accounts
-a always,exit -F path=/usr/libexec/sssd/ldap_child -F perm=x -F auid>=500 -F auid!=4294967295 -k T1078_Valid_Accounts
-a always,exit -F path=/usr/libexec/sssd/selinux_child -F perm=x -F auid>=500 -F auid!=4294967295 -k T1078_Valid_Accounts
-a always,exit -F path=/usr/libexec/sssd/proxy_child -F perm=x -F auid>=500 -F auid!=4294967295 -k T1078_Valid_Accounts

## T1002 Data Compressed

-w /usr/bin/zip -p x -k Data_Compressed
-w /usr/bin/gzip -p x -k Data_Compressed
-w /usr/bin/tar -p x -k Data_Compressed
-w /usr/bin/bzip2 -p x -k Data_Compressed

-w /usr/bin/lzip -p x -k Data_Compressed
-w /usr/local/bin/lzip -p x -k Data_Compressed

-w /usr/bin/lz4 -p x -k Data_Compressed
-w /usr/local/bin/lz4 -p x -k Data_Compressed

-w /usr/bin/lzop -p x -k Data_Compressed
-w /usr/local/bin/lzop -p x -k Data_Compressed

-w /usr/bin/plzip -p x -k Data_Compressed
-w /usr/local/bin/plzip -p x -k Data_Compressed

-w /usr/bin/pbzip2 -p x -k Data_Compressed
-w /usr/local/bin/pbzip2 -p x -k Data_Compressed

-w /usr/bin/lbzip2 -p x -k Data_Compressed
-w /usr/local/bin/lbzip2 -p x -k Data_Compressed

-w /usr/bin/pixz -p x -k Data_Compressed
-w /usr/local/bin/pixz -p x -k Data_Compressed

-w /usr/bin/pigz -p x -k Data_Compressed
-w /usr/local/bin/pigz -p x -k Data_Compressed
-w /usr/bin/unpigz -p x -k Data_Compressed
-w /usr/local/bin/unpigz -p x -k Data_Compressed

-w /usr/bin/zstd -p x -k Data_Compressed
-w /usr/local/bin/zstd -p x -k Data_Compressed

## Added to catch netcat on Ubuntu
-w /bin/nc.openbsd -p x -k susp_activity
-w /bin/nc.traditional -p x -k susp_activity

## Sbin suspicious activity
-w /sbin/iptables -p x -k sbin_susp
-w /sbin/ip6tables -p x -k sbin_susp
-w /sbin/ifconfig -p x -k sbin_susp
-w /usr/sbin/arptables -p x -k sbin_susp
-w /usr/sbin/ebtables -p x -k sbin_susp
-w /sbin/xtables-nft-multi -p x -k sbin_susp
-w /usr/sbin/nft -p x -k sbin_susp
-w /usr/sbin/tcpdump -p x -k sbin_susp
-w /usr/sbin/traceroute -p x -k sbin_susp
-w /usr/sbin/ufw -p x -k sbin_susp

### kde4
-a always,exit -F path=/usr/libexec/kde4/kpac_dhcp_helper -F perm=x -F auid>=1000 -F auid!=4294967295 -k T1078_Valid_Accounts
-a always,exit -F path=/usr/libexec/kde4/kdesud -F perm=x -F auid>=1000 -F auid!=4294967295 -k T1078_Valid_Accounts

## dbus-send invocation
### may indicate privilege escalation CVE-2021-3560
-w /usr/bin/dbus-send -p x -k dbus_send
-w /usr/bin/gdbus -p x -k gdubs_call

## pkexec invocation
### may indicate privilege escalation CVE-2021-4034
-w /usr/bin/pkexec -p x -k pkexec

## Suspicious shells
-w /bin/ash -p x -k susp_shell
-w /bin/csh -p x -k susp_shell
-w /bin/fish -p x -k susp_shell
-w /bin/tcsh -p x -k susp_shell
-w /bin/tclsh -p x -k susp_shell
-w /bin/xonsh -p x -k susp_shell
-w /usr/local/bin/xonsh -p x -k susp_shell
-w /bin/open -p x -k susp_shell
-w /bin/rbash -p x -k susp_shell

# Web Server Actvity
## Change the number "33" to the ID of your WebServer user. Default: www-data:x:33:33
-a always,exit -F arch=b64 -S execve -F euid=33 -k detect_execve_www

### https://clustershell.readthedocs.io/
-w /bin/clush -p x -k susp_shell
-w /usr/local/bin/clush -p x -k susp_shell
-w /etc/clustershell/clush.conf -p x -k susp_shell

## Shell/profile configurations
-w /etc/profile.d/ -p wa -k shell_profiles
-w /etc/profile -p wa -k shell_profiles
-w /etc/shells -p wa -k shell_profiles
-w /etc/bashrc -p wa -k shell_profiles
-w /etc/csh.cshrc -p wa -k shell_profiles
-w /etc/csh.login -p wa -k shell_profiles
-w /etc/zsh/ -p wa -k shell_profiles

### https://github.com/xxh/xxh
-w /usr/local/bin/xxh.bash -p x -k susp_shell
-w /usr/local/bin/xxh.xsh -p x -k susp_shell
-w /usr/local/bin/xxh.zsh -p x -k susp_shell

## Injection
### These rules watch for code injection by the ptrace facility.
### This could indicate someone trying to do something bad or just debugging
-a always,exit -F arch=b64 -S ptrace -F a0=0x4 -k code_injection
-a always,exit -F arch=b64 -S ptrace -F a0=0x5 -k data_injection
-a always,exit -F arch=b64 -S ptrace -F a0=0x6 -k register_injection
-a always,exit -F arch=b64 -S ptrace -k tracing

## Anonymous File Creation
### These rules watch the use of memfd_create
### "memfd_create" creates anonymous file and returns a file descriptor to access it
### When combined with "fexecve" can be used to stealthily run binaries in memory without touching disk
-a always,exit -F arch=b64 -S memfd_create -F key=anon_file_create

## Privilege Abuse
### The purpose of this rule is to detect when an admin may be abusing power by looking in user's home dir.
-a always,exit -F dir=/home -F uid=0 -F auid>=1000 -F auid!=-1 -C auid!=obj_uid -k power_abuse

# Socket Creations
# will catch both IPv4 and IPv6

-a always,exit -F arch=b32 -S socket -F a0=2  -k network_socket_created
-a always,exit -F arch=b64 -S socket -F a0=2  -k network_socket_created

-a always,exit -F arch=b32 -S socket -F a0=10 -k network_socket_created
-a always,exit -F arch=b64 -S socket -F a0=10 -k network_socket_created

# Software Management ---------------------------------------------------------


# PIP(3) (Python installs)
-w /usr/bin/pip -p x -k third_party_software_mgmt
-w /usr/local/bin/pip -p x -k third_party_software_mgmt
-w /usr/bin/pip3 -p x -k third_party_software_mgmt
-w /usr/local/bin/pip3 -p x -k third_party_software_mgmt
-w /usr/bin/pipx -p x -k third_party_software_mgmt
-w /usr/local/bin/pipx -p x -k third_party_software_mgmt

# npm
## T1072 third party software
## https://www.npmjs.com
## https://docs.npmjs.com/cli/v6/commands/npm-audit
-w /usr/bin/npm -p x -k third_party_software_mgmt

   
# Special Software ------------------------------------------------------------


## T1081 Credentials In Files
-w /usr/bin/grep -p x -k string_search

### https://github.com/BurntSushi/ripgrep
-w /usr/bin/rg -p x -k string_search
### macOS
-w /usr/local/bin/rg -p x -k string_search

## Docker
-w /usr/bin/dockerd -k docker
-w /usr/bin/docker -k docker
-w /usr/bin/docker-containerd -k docker
-w /usr/bin/docker-runc -k docker
-w /var/lib/docker -p wa -k docker
-w /etc/docker -k docker
-w /etc/sysconfig/docker -k docker
-w /etc/sysconfig/docker-storage -k docker
-w /usr/lib/systemd/system/docker.service -k docker
-w /usr/lib/systemd/system/docker.socket -k docker

## Virtualization stuff
-w /usr/bin/qemu-system-x86_64 -p x -k qemu-system-x86_64
-w /usr/bin/qemu-img -p x -k qemu-img
-w /usr/bin/qemu-kvm -p x -k qemu-kvm
-w /usr/bin/qemu -p x -k qemu
-w /usr/bin/virtualbox -p x -k virtualbox
-w /usr/bin/virt-manager -p x -k virt-manager
-w /usr/bin/VBoxManage -p x -k VBoxManage

## Kubelet
-w /usr/bin/kubelet -k kubelet

# ipc system call
# /usr/include/linux/ipc.h

## msgctl
#-a always,exit -S ipc -F a0=14 -k Inter-Process_Communication
## msgget
#-a always,exit -S ipc -F a0=13 -k Inter-Process_Communication
## Use these lines on x86_64, ia64 instead
-a always,exit -F arch=b64 -S msgctl -k Inter-Process_Communication
-a always,exit -F arch=b64 -S msgget -k Inter-Process_Communication

## semctl
#-a always,exit -S ipc -F a0=3 -k Inter-Process_Communication
## semget
#-a always,exit -S ipc -F a0=2 -k Inter-Process_Communication
## semop
#-a always,exit -S ipc -F a0=1 -k Inter-Process_Communication
## semtimedop
#-a always,exit -S ipc -F a0=4 -k Inter-Process_Communication
## Use these lines on x86_64, ia64 instead
-a always,exit -F arch=b64 -S semctl -k Inter-Process_Communication
-a always,exit -F arch=b64 -S semget -k Inter-Process_Communication
-a always,exit -F arch=b64 -S semop -k Inter-Process_Communication
-a always,exit -F arch=b64 -S semtimedop -k Inter-Process_Communication

## shmctl
#-a always,exit -S ipc -F a0=24 -k Inter-Process_Communication
## shmget
#-a always,exit -S ipc -F a0=23 -k Inter-Process_Communication
## Use these lines on x86_64, ia64 instead
-a always,exit -F arch=b64 -S shmctl -k Inter-Process_Communication
-a always,exit -F arch=b64 -S shmget -k Inter-Process_Communication

# High Volume Events ----------------------------------------------------------

## Disable these rules if they create too many events in your environment

## Common Shells
"-w /bin/bash -p x -k susp_shell"
"-w /bin/dash -p x -k susp_shell"
"-w /bin/busybox -p x -k susp_shell"
"-w /bin/zsh -p x -k susp_shell"
"-w /bin/sh -p x -k susp_shell"
"-w /bin/ksh -p x -k susp_shell"

## Root command executions
-a always,exit -F arch=b64 -F euid=0 -F auid>=1000 -F auid!=-1 -S execve -k rootcmd

## File Deletion Events by User
-a always,exit -F arch=b64 -S rmdir -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=-1 -k delete

## File Access
### Unauthorized Access (unsuccessful)
-a always,exit -F arch=b64 -S creat -S open -S openat -S open_by_handle_at -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=-1 -k file_access
-a always,exit -F arch=b64 -S creat -S open -S openat -S open_by_handle_at -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=-1 -k file_access

### Unsuccessful Creation
-a always,exit -F arch=b64 -S mkdir,creat,link,symlink,mknod,mknodat,linkat,symlinkat -F exit=-EACCES -k file_creation
-a always,exit -F arch=b64 -S mkdir,link,symlink,mkdirat -F exit=-EPERM -k file_creation

### Unsuccessful Modification
-a always,exit -F arch=b64 -S rename -S renameat -S truncate -S chmod -S setxattr -S lsetxattr -S removexattr -S lremovexattr -F exit=-EACCES -k file_modification
-a always,exit -F arch=b64 -S rename -S renameat -S truncate -S chmod -S setxattr -S lsetxattr -S removexattr -S lremovexattr -F exit=-EPERM -k file_modification

## 32bit API Exploitation
### If you are on a 64 bit platform, everything _should_ be running
### in 64 bit mode. This rule will detect any use of the 32 bit syscalls
### because this might be a sign of someone exploiting a hole in the 32
### bit API.
"-a always,exit -F arch=b32 -S all -k 32bit_api"

# Make The Configuration Immutable --------------------------------------------

##-e 2
  ];
}
