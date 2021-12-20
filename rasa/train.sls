# Trains rasa assiatant (Generates models file /opt/rasa/models)
rasa_train:
  cmd.run:
    - name: 'PATH="/root/venv/bin/:$PATH"; rasa train'
    - cwd: /opt/rasa/