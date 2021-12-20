#!/bin/bash

# Activate virtual environment for rasa
source /root/venv/bin/activate
# Start the Rasa web server API
rasa run --enable-api -p {{ pillar['rasa']['api_port'] }} --auth-token {{ pillar['rasa']['authtoken'] }}
