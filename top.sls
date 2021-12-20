base:
  '*':
    # Remove unnecessary packages to minimize potential security issues 
    # Make sure system is up to date, update packages
    # Autoremove dependcies that are no longer needed
    - system-update
      # Total run time: 103.395 s

    # Install Hubblestack, audit settings
    # Install oh-my-zsh (settings from pillar data)
    # Set server timezone
    # Set SSH config, SSH authorized_keys
    - common
      # Total run time:   37.020 s

  'roles:*-api':
    - match: grain

    # Install Node.js 14.x, Nginx
    - api
      # Total run time:  15.951 s

    # Make sure firewalld is installed and start firewalld service
    # Set allowed ports to public zone, block ping
    - firewall
      # Total run time:   2.987 s

  'roles:botfront':
    - match: grain

    # Install MongoDB and MongoDB Tools
    # Create databases and users, Create admin user, Set auth enabled
    - mongodb
      # Total run time:   33.158 s

    # Install Rasa for botfront in virtualenv
    - rasa-for-botfront
      # Total run time:   94.469 s

    # Install Botfront
    # Import Botfront database dump to botfront database
    # Update Botfront database by running script update_botfront_database.js
    - botfront
      # Total run time:  32.042 s

    - set-ssh-port