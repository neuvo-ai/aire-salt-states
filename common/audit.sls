install_hubblestack:
  pkg.installed:
    - unless: hubble --version
    - sources:
      - hubblestack: https://github.com/hubblestack/hubble/releases/download/v4.5.0/hubblestack-4.5.0-2.deb10.amd64.deb

# Disable Unwanted SUID Binaries
audit_suid:
  cmd.run:
    - name: find / -perm /+4000 2> /dev/null | sort | diff <(echo -e $PREDEFINED_FILES | sort) -
    - shell: /bin/bash
    - env:
      - PREDEFINED_FILES: {{ pillar['audit']['suid_files']|join('\\n') }}

# Make Sure No Non-Root Accounts Have UID Set To 0
audit_uid_0:
  cmd.run:
    - name: '! awk -F: ''($3 == "0") {print}'' /etc/passwd | egrep -v "^root:"'
