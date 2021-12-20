# Add MongoDB repository from mongodb.org
mongodb_repo:
  pkgrepo.managed:
    - humanname: MongoDB Community Edition Repository 
    - name: deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu DUMMY multiverse
    - dist: {{ grains['oscodename'] }}/mongodb-org/5.0
    - file: /etc/apt/sources.list.d/mongodb-org-5.0.list
    - key_url: https://www.mongodb.org/static/pgp/server-5.0.asc

# Install mongodb packages
mongodb_packages:
  pkg.installed:
    - pkgs:
      - mongodb-org-database
      - mongodb-org-tools
    - refresh: True
    - require:
      - mongodb_repo

# Run this only if MongoDB is not already installed by salt to prevent overwriting configs
{% if not salt['file.file_exists' ]('/var/lib/mongodb/mongodb_installed_with_salt') %}

# Add MongoDB databases & users config file
/var/tmp/mongodb_user.js:
  file.managed:
  - source: salt://mongodb/files/databases_and_users.js
  - template: jinja
  - mode: 600
  - user: root
  - context:
      admin: {{ pillar.mongodb.server.admin }}
      databases: {{ pillar.mongodb.server.databases }}

# Add MongoDB config file
/etc/mongod.conf:
  file.managed:
  - source: salt://mongodb/files/mongod.conf
  - template: jinja
  - require:
    - pkg: mongodb_packages
    - /var/tmp/mongodb_user.js

# Start MongoDB service after packages are installed and lock directory created
mongodb_service:
  service.running:
  - name: mongod
  - enable: true
  - require:
    - pkg: mongodb_packages

# Check if MongoDB is up and running (service name 'mongod' and port number from pillar data)
check_if_mongo_ready:
  cmd.run:
   - name: 'while true; do lsof -i -P -n | grep mongod | grep ":$MONGO_PORT " 1>/dev/null 2>&1; code=$?; if [ $code -ne 0 ]; then sleep 2; else break; fi; done'
   - require:
     - service: mongodb_service
   - env:
     - MONGO_PORT: {{ pillar['mongodb']['server']['bind']['port'] }}

# Run MongoDB databases and users config file and set root password
mongodb_change_root_password:
  cmd.run:
  - name: 'mongo localhost:27017/admin /var/tmp/mongodb_user.js && touch /var/lib/mongodb/mongodb_installed_with_salt'
  - require:
    - file: /var/tmp/mongodb_user.js
    - cmd: check_if_mongo_ready

# Stop MongoDB service, before setting mongod.conf authorization to enabled
mongodb_service_stop:
  service.dead:
  - name: mongod
  - enable: false
  - require:
      - cmd: mongodb_change_root_password

# Set authorization to enabled in mongod.conf 
enable_mongodb_auth:
  cmd.run:
  - name: "sed -i 's/authorization: disabled/authorization: enabled/g' /etc/mongod.conf"
  - require:
      - service: mongodb_service_stop

# Start MongoDB service after authorization enabled in config
mongodb_service_restart:
  service.running:
  - name: mongod
  - enable: true
  - require:
    - cmd: enable_mongodb_auth
  - watch:
    - file: /etc/mongod.conf
{% endif %}