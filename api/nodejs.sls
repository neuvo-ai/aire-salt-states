# Install Node.js
api_packages:
  pkg.installed:
    - pkgs:
      - nodejs
    - require:
      - nodejs_repo

# Add the node 14 repository from node source
nodejs_repo:
  pkgrepo.managed:
    - humanname: NodeSource Node.js Repository
    - name: deb https://deb.nodesource.com/node_14.x {{ grains['oscodename'] }} main
    - dist: {{ grains['oscodename'] }}
    - file: /etc/apt/sources.list.d/nodesource.list
    - keyid: "68576280"
    - key_url: https://deb.nodesource.com/gpgkey/nodesource.gpg.key
    - keyserver: keyserver.ubuntu.com