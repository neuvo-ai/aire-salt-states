# Separate state for ssh port change because port have to set after minion is created by salt-cloud and initial highstate run is completed.

# Overwrite ssh default port with port from pillar data
set_ssh_port:
  cmd.run:
    - name: sed -i 's/#Port 22/Port {{ pillar['ssh']['port'] }}/g' /etc/ssh/sshd_config.d/sshd_config.conf

# Restart ssh service
sshd:
  service.running:
    - enable: true
    - require:
      - set_ssh_port
    - watch:
      - set_ssh_port

# Remove ssh service from firewalld, because defaults to port 22 and we are using custom port
firewalld_remove_service_ssh:
  cmd.run:
    - name: firewall-cmd --remove-service=ssh