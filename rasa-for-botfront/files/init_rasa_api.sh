#!/bin/bash

# Activate virtual environment for rasa
source /root/venv/bin/activate

# Cd to rasa init directory
cd /opt/rasa-init-for-botfront

# Start the Rasa web server API
rasa run --enable-api -p {{ pillar['rasa']['api_port'] }} --debug --cors "*" 

# In Botfront auth-token not working returns undefined, if that get fixed, here is rasa run command with auth-token
#rasa run --enable-api -p {{ pillar['rasa']['api_port'] }} --debug --cors "*" --auth-token {{ pillar['rasa']['authtoken'] }}