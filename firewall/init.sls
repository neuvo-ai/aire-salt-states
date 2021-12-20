# Install firewalld
firewalld_pkg:
  pkg.installed:
    - pkgs:
      - firewalld

# Make sure firewalld is installed and start firewalld service
firewalld_service:
  service.running:
    - name: firewalld
    - enable: True
    - require:
      - firewalld_pkg

# Set allowed ports to public zone, block ping
public:
  firewalld.present:
    - require:
      - firewalld_service
    - name: public
    - block_icmp:
      - echo-reply
      - echo-request
    - default: False
    - masquerade: True
    - prune_ports: True
    - ports:
      - 80/tcp
      - 443/tcp
      - {{ pillar['ssh']['port'] }}/tcp

# Set allowed sources to trusted zone
# trusted:
#   firewalld.present:
#     - require:
#     - firewalld_service
#     - name: trusted
#     - sources:
#     - 10.0.2.15
#     - 10.0.2.5

# Verify all firewalld manually run commands to permament
firewalld_runtime_to_permanent:
  cmd.run:
    - name: firewall-cmd --runtime-to-permanent