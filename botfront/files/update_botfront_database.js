// Get context variables from botfront init.sls
const botfront = {{ botfront }}
const admin = {{ admin }}

db = connect("localhost:27017/admin");
db.auth('admin', admin.password);
db = db.getSiblingDB('botfront');

// Update user email, password, firstname, lastname
db.users.updateOne(
  { _id: "793EYjZMX2ccePi3y" },
  {
    $set: {
      "emails.0.address": botfront.username,
      "services.password.bcrypt": botfront.password ,
      "profile.firstName": botfront.firstname,
      "profile.lastName": botfront.lastname 
    }
  }
)

const credentials = `rasa_addons.core.channels.webchat.WebchatInput:\n  session_persistence: true\n  base_url: '${botfront.root_url}'\n  socket_path: /socket.io/\nrasa_addons.core.channels.bot_regression_test.BotRegressionTestInput: {}`

// Update admin settings credentials
db.admin_settings.updateOne(
  {},
  {
    $set: {
      "settings.private.defaultCredentials": credentials
    }
  }
)

// Update project settings credentials
db.credentials.updateMany(
  { projectId: "pW2WEr9JJoWauvFge" },
  {
    $set: {
      "credentials": credentials
    }
  }
)

// Update instance
db.nlu_instances.updateOne(
  { projectId: "pW2WEr9JJoWauvFge" },
  {
    $set: {
      "host": "http://localhost:5005"
    }
  }
)