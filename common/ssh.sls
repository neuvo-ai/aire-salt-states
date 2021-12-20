# Only run this block if file "/etc/ssh/sshd_config.d/sshd_config.conf" is not existing
{% if not salt['file.file_exists' ]('/etc/ssh/sshd_config.d/sshd_config.conf') %}
ssh_directory:
  file.directory:
    - name: /etc/ssh

# Set ssh config, custom port, password login = false, etc
sshd_config:
  file.managed:
    - name: /etc/ssh/sshd_config.d/sshd_config.conf
    - source: salt://common/files/sshd_config.conf
    - user: root
    - group: root
    - mode: 600
    - template: jinja
    - require:
      - file: ssh_directory

# Start ssh service and restart when changes in sshd_config file
sshd:
  service.running:
    - enable: true
    - require:
      - sshd_config
    - watch:
      - sshd_config
{% endif %}

# Get ssh-keys from source and set ssh-keys to /root/.ssh/authorized_keys file
# The source must contain keys in the format <enc> <key> <comment>
sshkeys:
  ssh_auth.present:
    - user: root
    - source: {{ pillar['ssh']['authorized_keys'] }}
    - config: '%h/.ssh/authorized_keys'