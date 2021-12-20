# Install python package manager
required_packages:
  pkg.installed:
    - pkgs:
      - python3-pip

# Install python virtualenvwrapper
virtualenvwrapper:
  pip.installed:
    - require:
      - pkg: required_packages

# Create a new virtual environment to /root/venv
/root/venv:
  virtualenv.managed:
    - python: python3
    - cwd: /root/venv/bin
    - require:
      - pip: virtualenvwrapper

# Install rasa in virtual environment /root/venv
rasa:
  pip.installed:
    - bin_env: /root/venv
    - require:
      - virtualenv: /root/venv

{% if not salt['file.directory_exists' ]('/opt/rasa') %}
# Copy rasa init files (Complete rasa assistant with some example training data)
/opt/rasa:
  file.recurse:
    - source: salt://rasa/files/rasa_init
    - user: root
    - group: root
    - require:
      - pip: rasa

# Copy rasa init bash script (populated with pillar data)
rasa_init_bash:
  file.managed:
    - name: /opt/rasa/init_rasa_api.sh
    - source: salt://rasa/files/init_rasa_api.sh
    - user: root
    - group: root
    - mode: 700
    - template: jinja
    - require:
      - file: /opt/rasa

# Copy rasa-api.service file to systemd
rasa_api_service_to_systemd:
  file.managed:
    - name: /etc/systemd/system/rasa-api.service
    - source: salt://rasa/files/rasa-api.service
    - user: root
    - group: root
    - mode: 600
    - template: jinja
    - require:
      - file: rasa_init_bash

# Start rasa-api service
rasa_api_service_start:
  service.running:
  - name: rasa-api
  - enable: true
  - require:
    - file: rasa_api_service_to_systemd

# TODO Handle rasa-api authentication, right now just using auth-token
{% endif %}
