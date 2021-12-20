# Extract Botfront dist direcotry to /opt/botfront
extract_botfront:
  archive.extracted:
    - name: /opt/botfront
    - source: salt://botfront/files/botfront_dist.tar.gz
    - user: root
    - group: root
    - if_missing: /opt/botfront

{% if not salt['file.directory_exists' ]('/opt/botfront/bundle/programs/server/node_modules') %}

# Copy Botfront database dump to /opt/botfront
/opt/botfront/botfront.db.gz:
  file.managed:
    - source: salt://botfront/files/botfront.db.gz
    - user: root
    - group: root
    - mode: 600
    - require:
      - archive: extract_botfront

# Import Botfront database dump to botfront database
import_botfront_database_dump:
  cmd.run:
    - name: mongorestore --uri 'mongodb://botfront:{{ pillar['mongodb']['server']['databases'][0]['users']['botfront']['password'] }}@localhost:27017/botfront' --gzip --archive=botfront.db.gz
    - shell: /bin/bash
    - cwd: /opt/botfront
    - require:
      - file: /opt/botfront/botfront.db.gz

# Add update_botfront_database.js file to tmp
/var/tmp/update_botfront_database.js:
  file.managed:
  - source: salt://botfront/files/update_botfront_database.js
  - template: jinja
  - mode: 600
  - user: root
  - context:
      botfront: {{ pillar.botfront }}
      admin: {{ pillar.mongodb.server.admin }}
  - require:
    - cmd: import_botfront_database_dump

# Run Botfront database update
botfront_database_update:
  cmd.run:
  - name: 'mongo /var/tmp/update_botfront_database.js'
  - require:
    - file: /var/tmp/update_botfront_database.js

# Install Botfront node modules
install_botfront_node_modules:
  cmd.run:
    - name: npm install
    - shell: /bin/bash
    - cwd: /opt/botfront/bundle/programs/server
    - require:
      - cmd: botfront_database_update

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

# Add hosts 'rasa' 'botfront' 'actions' point to localhost in /etc/hosts file, to make sure botfront works properly
set_botfront_used_hosts_to_hosts_file:
  cmd.run:
    - name: sed -i 's/127.0.1.1 {{ grains['id'] }}/127.0.1.1 {{ grains['id'] }} rasa botfront actions/g' /etc/hosts
    - require:
      - file: botfront_init_bash

# Copy botfront.service file to systemd
botfront_service_to_systemd:
  file.managed:
    - name: /etc/systemd/system/botfront.service
    - source: salt://botfront/files/botfront.service
    - user: root
    - group: root
    - mode: 600
    - template: jinja
    - require:
      - cmd: set_botfront_used_hosts_to_hosts_file

# Start botfront service
botfront_service_start:
  service.running:
  - name: botfront
  - enable: true
  - require:
    - file: botfront_service_to_systemd
{% endif %}