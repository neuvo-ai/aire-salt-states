nginx-install:
  pkg.installed:
    - name: nginx-full

# Only run this code block if file "/etc/nginx/nginx_installed_with_salt" is not existing
# If Nginx already installed we don't want to overwrite config files
{% if not salt['file.file_exists' ]('/etc/nginx/nginx_installed_with_salt') %}
nginx-configs:
  file.managed:
    - name: /etc/nginx/nginx.conf
    - source: salt://api/files/nginx.conf
    - require:
      - nginx-install

nginx-confd:
  file.directory:
    - name: /etc/nginx/conf.d
    - makedirs: true
    - require:
      - file: nginx-configs

remove-default:
  file.absent:
    - name: /etc/nginx/sites-enabled/default
    - require:
      - nginx-confd

add-confd-default:
  file.managed:
    - name: /etc/nginx/conf.d/default.conf
    - source: salt://api/files/default.conf
    - require:
      - nginx-confd

nginx-service:
  service.running:
    - name: nginx
    - enable: True
    - reload: True
    - require:
      - nginx-configs
      - remove-default
      - add-confd-default
    - watch:
      - nginx-configs
      - add-confd-default

# After Nginx installed, configured and service started create blank file to /etc/nginx/nginx_installed_with_salt
# This file is used to check is nginx already installed with salt and to not overwrite config files
set_indicate_nginx_installed_with_salt:
  cmd.run:
  - name: 'touch /etc/nginx/nginx_installed_with_salt'
  - require:
    - service: nginx-service
{% endif %}
