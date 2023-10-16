{ config, pkgs, lib, ... }:
{
  boot.kernelPackages = pkgs.zfs.latestCompatibleLinuxPackages;
  services.zfs.autoScrub.enable = true; 
  boot.zfs.forceImportRoot = false; # If you set this option to false and NixOS subsequently fails to boot because it cannot import the root pool, you should boot with the zfs_force=1 option as a kernel parameter 
  boot.kernelParams = [ "nohibernate" ];
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
 
  # Prevent replacing the running kernel w/o reboot
  security.protectKernelImage = true;

  # Same thing with the kernal modules, NOTE: sudo nixos-rebuild switch has problems with this option
  #security.lockKernelModules = true;

  security.virtualisation.flushL1DataCache = "always";
  security.sudo.execWheelOnly = true;  
  security.forcePageTableIsolation = true;

  boot.kernelParams = [
    # Slab/slub sanity checks, redzoning, and poisoning
    "slub_debug=FZP"

    # Overwrite free'd memory
    "page_poison=1"

    # Enable page allocator randomization
    "page_alloc.shuffle=1"

    "zfs_force=1"
  ];

  boot.blacklistedKernelModules = [
    # Obscure network protocols
    "ax25"
    "netrom"
    "rose"
  ];
  boot.kernel.sysctl = {
    # Prevent boot console kernel log information leaks
    "kernel.printk" = "3 3 3 3";

    # These parameters prevent information leaks during boot and must be used
    # in combination with the kernel.printk
    "quiet" "loglevel=0"

    # Restrict loading TTY line disciplines to the CAP_SYS_MODULE capability to
    # prevent unprivileged attackers from loading vulnerable line disciplines with
    # the TIOCSETD ioctl
    "dev.tty.ldisc_autoload" = "0";

    # The SysRq key exposes a lot of potentially dangerous debugging functionality to unprivileged users
    # It is a key combo that allows users connected to the system console of a Linux kernel to perform some low-level commands.
    # It exposes a lot of potentially dangerous debugging functionality to unprivileged users.
    # If you need it, at least do  "kernel.sysrq" = "4"; then it will allow the privileged.
    "kernel.sysrq" = 0;

    # Incomplete protection again TIME-WAIT assassination
    # It does this by dropping RST packets for sockets in the time-wait state.
    # Not enabled by default because of hypothetical loss of backwards compatibility.
    # See this discussion for details: https://serverfault.com/questions/787624/why-isnt-net-ipv4-tcp-rfc1337-enabled-by-default/
    "net.ipv4.tcp_rfc1337" = "1";

    # Disable TCP SACK. SACK is commonly exploited and unnecessary for many
    # circumstances so it should be disabled if you don't require it
    "net.ipv4.tcp_sack" = "0";
    "net.ipv4.tcp_dsack" = "0";

    # Restrict usage of ptrace to only processes with the CAP_SYS_PTRACE
    # capability
    "kernel.yama.ptrace_scope" = "2";

    # Prevent creating files in potentially attacker-controlled environments such
    # as world-writable directories to make data spoofing attacks more difficult   
    # Disables POSIX corner cases with creating files and fifos unless the directory owner matches. Check your workloads!
    "fs.protected_fifos" = "2";
    "fs.protected_regular" = "2";

    # Disable POSIX symlink and hardlink corner cases that lead to lots of filesystem confusion attacks.
    fs.protected_symlinks = 1
    fs.protected_hardlinks = 1

    # Disable core dumps
    "syskernel.core_pattern" = "|/bin/false";

    # Make sure the default process dumpability is set (processes that changed privileges aren't dumpable).
    "fs.suid_dumpable" = "0";

    # Disable slab merging which significantly increases the difficulty of heap
    # exploitation by preventing overwriting objects from merged caches and by
    # making it harder to influence slab cache layout
    "slab_nomerge"

    # Disable vsyscalls as they are obsolete and have been replaced with vDSO.
    # vsyscalls are also at fixed addresses in memory, making them a potential
    # target for ROP attacks
    "vsyscall=none"

    # Disable debugfs which exposes a lot of sensitive information about the
    # kernel
    "debugfs=off"

    # Sometimes certain kernel exploits will cause what is known as an "oops".
    # This parameter will cause the kernel to panic on such oopses, thereby
    # preventing those exploits
    "oops=panic"

    # Only allow kernel modules that have been signed with a valid key to be
    # loaded, which increases security by making it much harder to load a
    # malicious kernel module
    "module.sig_enforce=1"

    # The kernel lockdown LSM can eliminate many methods that user space code
    # could abuse to escalate to kernel privileges and extract sensitive
    # information. This LSM is necessary to implement a clear security boundary
    # between user space and the kernel
    "lockdown=confidentiality"

    # Incomplete protection again TIME-WAIT assassination
    # It does this by dropping RST packets for sockets in the time-wait state.
    # Not enabled by default because of hypothetical loss of backwards compatibility.
    # See this discussion for details: https://serverfault.com/questions/787624/why-isnt-net-ipv4-tcp-rfc1337-enabled-by-default/
    "net.ipv4.tcp_rfc1337" = "1";

    # Disable TCP SACK. SACK is commonly exploited and unnecessary for many
    # circumstances so it should be disabled if you don't require it
    "net.ipv4.tcp_sack" = "0";
    "net.ipv4.tcp_dsack" = "0";
  
    # Prevent bogus ICMP errors from filling up logs.
    "net.ipv4.icmp_ignore_bogus_error_responses" = 1;

    # Reverse path filtering causes the kernel to do source validation of
    # packets received from all interfaces. This can mitigate IP spoofing.
    "net.ipv4.conf.default.rp_filter" = 1;
    "net.ipv4.conf.all.rp_filter" = 1;

    # Do not accept IP source route packets (we're not a router)
    "net.ipv4.conf.all.accept_source_route" = 0;
    "net.ipv6.conf.all.accept_source_route" = 0;

    # Don't send ICMP redirects (again, we're on a router)
    "net.ipv4.conf.all.send_redirects" = 0;    
    "net.ipv4.conf.default.send_redirects" = 0;

    # Refuse ICMP redirects (MITM mitigations) 
    "net.ipv4.conf.all.accept_redirects" = 0;    
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.all.secure_redirects" = 0;    
    "net.ipv4.conf.default.secure_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;    
    "net.ipv6.conf.default.accept_redirects" = 0;

    # Protects against SYN flood attacks
    # https://en.wikipedia.org/wiki/SYN_cookies
    "net.ipv4.tcp_syncookies" = 1;
    "net.ipv4.tcp_synack_retries = 5"

    # TCP Fast Open is a TCP extension that reduces network latency by packing
    # data in the sender’s initial TCP SYN. Setting 3 = enable TCP Fast Open for
    # both incoming and outgoing connections:
    "net.ipv4.tcp_fastopen" = 3;

    # Bufferbloat mitigations + slight improvement in throughput & latency
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "cake";

     #oid leaking system time with TCP timestamps
    "net.ipv4.tcp_timestamps" = "0";

    "kernel.yama.ptrace_scope" = 2;

   # Try to keep kernel address exposures out of various /proc files (kallsyms, modules, etc). (There is no CONFIG for the changing the initial value.) If root absolutely needs values from /proc, use value "1".
    "kernel.kptr_restrict" = 2;

  # Avoid kernel memory address exposures via dmesg (this value can also be set by CONFIG_SECURITY_DMESG_RESTRICT).
    kernel.dmesg_restrict = 1

# Block non-uid-0 profiling (needs distro patch, otherwise this is the same as "= 2")
kernel.perf_event_paranoid = 3



# Make sure the expected default is enabled to enable full ASLR in userpsace.
kernel.randomize_va_space = 2

# Block all PTRACE_ATTACH. If you need ptrace to work, then avoid non-ancestor ptrace access to running processes and their credentials, and use value "1".
kernel.yama.ptrace_scope = 3

# Disable User Namespaces, as it opens up a large attack surface to unprivileged users.
user.max_user_namespaces = 0

# Disable tty line discipline autoloading (see CONFIG_LDISC_AUTOLOAD).
dev.tty.ldisc_autoload = 0

# Turn off unprivileged eBPF access.
kernel.unprivileged_bpf_disabled = 1

# Turn on BPF JIT hardening, if the JIT is enabled.
net.core.bpf_jit_harden = 2

# Disable userfaultfd for unprivileged processes.
vm.unprivileged_userfaultfd = 0



  };
  boot.kernelModules = ["tcp_bbr"];
}
