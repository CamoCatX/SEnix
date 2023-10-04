{ config, pkgs, lib, ... }:
{
  boot.kernelPackages = pkgs.zfs.latestCompatibleLinuxPackages;
  services.zfs.autoScrub.enable = true;                       

  # Prevent replacing the running kernel w/o reboot
  security.protectKernelImage = true;
  # Same thing with the kernal modules, NOTE: sudo nixos-rebuild switch has problems with this option
  security.lockKernelModules = true;
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
   
    # NixOS produces many wakeups per second, which is bad for battery life.
    # This kernel parameter disables the timer tick on the last 4 cores
    "nohz_full=4-7"
  ];

  boot.blacklistedKernelModules = [
    # Obscure network protocols
    "ax25"
    "netrom"
    "rose"
  ];
  boot.kernel.sysctl = {
    # The Magic SysRq key is a key combo that allows users connected to the
    # system console of a Linux kernel to perform some low-level commands.
    # Disable it, since we don't need it, and is a potential security concern.
    "kernel.sysrq" = 0;

    ## TCP hardening
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

    # Incomplete protection again TIME-WAIT assassination
    "net.ipv4.tcp_rfc1337" = 1;

    ## TCP optimization
    # TCP Fast Open is a TCP extension that reduces network latency by packing
    # data in the sender’s initial TCP SYN. Setting 3 = enable TCP Fast Open for
    # both incoming and outgoing connections:
    "net.ipv4.tcp_fastopen" = 3;

    # Bufferbloat mitigations + slight improvement in throughput & latency
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "cake";

    "kernel.yama.ptrace_scope" = 1;
    "kernel.kptr_restrict" = 2;

    "kernel.dmesg_restrict" = 1;

  };

  boot.kernelModules = ["tcp_bbr"];
  boot.kernel.sysctl = { "kernel.dmesg_restrict" = 1; };
}
