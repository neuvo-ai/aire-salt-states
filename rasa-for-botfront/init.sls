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

# Upgrade pip in virtual environment /root/venv
pip_upgrade:
  pip.installed:
    - name: pip
    - bin_env: /root/venv
    - upgrade: true
    - require:
      - virtualenv: /root/venv

# Install poetry
install_poetry:
  cmd.run:
    - name: curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3
    - unless: poetry --version
    - shell: /bin/bash

{% if not salt['file.directory_exists' ]('/opt/rasa-for-botfront') %}
# Clone rasa_for_botfront to /opt/rasa-for-botfront
git_clone_rasa_for_botfront:
  git.latest:
    - name: https://github.com/botfront/rasa-for-botfront.git
    - rev: v2.3.3-bf.3
    - depth: 1
    - target: /opt/rasa-for-botfront
    - user: root

# Extract rasa-for-botfront venv direcotry to /root/venv
# We run this to save time when running (source $HOME/.poetry/env && source /root/venv/bin/activate && poetry install)
extract_rasa_for_botfront_venv:
  archive.extracted:
    - name: /root/venv
    - source: salt://rasa-for-botfront/files/rasa-for-botfront-venv.tar.gz
    - enforce_toplevel: False
    - user: root
    - group: root
    - require:
      - git: git_clone_rasa_for_botfront

# Install rasa_for_botfront in virtual environment /root/venv
install_rasa_for_botfront:
  cmd.run:
    - name: source $HOME/.poetry/env && source /root/venv/bin/activate && poetry install
    - shell: /bin/bash
    - cwd: /opt/rasa-for-botfront
    - require:
      - archive: extract_rasa_for_botfront_venv
{% endif %}

{% if not salt['file.directory_exists' ]('/opt/rasa-init-for-botfront') %}
# Copy rasa init files
/opt/rasa-init-for-botfront:
  file.recurse:
    - source: salt://rasa-for-botfront/files/rasa-init-botfront
    - user: root
    - group: root
    - require:
      - cmd: install_rasa_for_botfront

# Copy rasa init bash script (populated with pillar data)
rasa_init_bash:
  file.managed:
    - name: /opt/rasa-init-for-botfront/init_rasa_api.sh
    - source: salt://rasa-for-botfront/files/init_rasa_api.sh
    - user: root
    - group: root
    - mode: 700
    - template: jinja
    - require:
      - file: /opt/rasa-init-for-botfront

# Copy rasa-api.service file to systemd
rasa_api_service_to_systemd:
  file.managed:
    - name: /etc/systemd/system/rasa-api.service
    - source: salt://rasa-for-botfront/files/rasa-api.service
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
{% endif %}
