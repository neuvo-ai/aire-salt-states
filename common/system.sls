# Set server timezone, to get logs date/time with selected timezone
set_timezone:
  timezone.system:
    - utc: True
    - name: {{ pillar['timezone'] }}

# Mount /tmp in ram and add some security options
# tmp_tmpfs:
#   mount.mounted:
#     - name: /tmp
#     - device: tmpfs
#     - fstype: tmpfs
#     - opts: nodev,nosuid,noexec,size={{ pillar['tmpfs_size'] }}

# Set swapping to minimum
vm.swappiness:
  sysctl.present:
    - value: 1
# Turn on kernel memory protection and randomize stack, vdso page and mmap
kernel.randomize_va_space:
  sysctl.present:
    - value: 1
# Enable IP spoofing protection
net.ipv4.conf.all.rp_filter:
  sysctl.present:
    - value: 1
# Disable IP source routing
net.ipv4.conf.all.accept_source_route:
  sysctl.present:
    - value: 0
# Ignoring broadcasts request
net.ipv4.icmp_echo_ignore_broadcasts:
  sysctl.present:
    - value: 1
# Make sure spoofed packets get logged
net.ipv4.conf.all.log_martians:
  sysctl.present:
    - value: 1