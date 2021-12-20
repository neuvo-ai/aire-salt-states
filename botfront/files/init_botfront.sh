#!/bin/bash

# Set Botfront env variables
export MONGO_URL='mongodb://botfront:{{ pillar['mongodb']['server']['databases'][0]['users']['botfront']['password'] }}@{{ pillar['mongodb']['server']['bind']['address'] }}:{{ pillar['mongodb']['server']['bind']['port'] }}/botfront'
export ROOT_URL='{{ pillar['botfront']['root_url'] }}'
export PORT='{{ pillar['botfront']['port'] }}'
# export MAIL_URL='{{ pillar['botfront']['mail_url'] }}'

# Cd to botfront bundle directory
cd /opt/botfront/bundle

# Start botfront server
node main.js
