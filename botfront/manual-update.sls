# Extract Botfront dist direcotry to /opt/botfront
extract_botfront:
  archive.extracted:
    - name: /opt/botfront
    - source: salt://botfront/files/botfront_dist.tar.gz
    - user: root
    - group: root
    - overwrite: True
    - clean: True

# Install Botfront node modules
install_botfront_node_modules:
  cmd.run:
    - name: npm install
    - shell: /bin/bash
    - cwd: /opt/botfront/bundle/programs/server
    - require:
      - archive: extract_botfront

# Copy Botfront init bash script (populated with pillar data)
botfront_init_bash:
  file.managed:
    - name: /opt/botfront/bundle/init_botfront.sh
    - source: salt://botfront/files/init_botfront.sh
    - user: root
    - group: root
    - mode: 700
    - template: jinja
    - require:
      - cmd: install_botfront_node_modules

# Restart Botfront service
restart_botfront_service:
  service.running:
    - name: botfront
    - enable: True
    - watch:
      - extract_botfront
    - require:
      - file: botfront_init_bash