# Install common packages
common_packages:
  pkg.installed:
    - pkgs:
      - htop
      - nano

# Remove unnecessary packages to minimize potential security issues
common_removed_packages:
  pkg.purged:
    - pkgs:
      - rpcbind
      - xinetd
      - nis
      - yp-tools
      - tftpd
      - atftpd
      - tftpd-hpa
      - telnetd
      - rsh-server
      - rsh-redone-server

# Make sure system is up to date
update_packages:
  pkg.uptodate:
    - refresh: True
    - dist_upgrade: True

# Autoremove dependcies that are no longer needed
autoremove_packages:
  module.run:
    - name: pkg.autoremove
    - m_purge: True
    - require:
      - update_packages
