// Get context variables from mongo init.sls
const databases = {{ databases }}
const admin = {{ admin }}

// Loop databases
databases.forEach(database => {
  const databaseName = database.name
  // Switch to {databaseName} database
  db = db.getSiblingDB(databaseName);
  // Loop and create database users
  Object.keys(database.users).forEach(key =>{
    const username = key
    const password = database.users[key].password
    // Check if username already exist for the database
    if(!db.runCommand({ usersInfo: { user: username, db: databaseName } }).users.length == 1) {
      db.createUser(
        {
          user: username,
          pwd: password,
          roles: [
            { role: "readWrite", db: databaseName }
          ]
        }
      );
    }
  });
  // Add test document to saltstack collection
  db.saltstack.insertOne({test: "This is salt generated test document."});
  print 
});

// Switch to admin database
db = db.getSiblingDB("admin");
// Create admin user if not exist
if(!db.runCommand({ usersInfo: { user: "admin", db: "admin" } }).users.length == 1) {
  db.createUser(
    {
      user: "admin",
      pwd: admin.password,
      roles: [ "userAdminAnyDatabase", "readWriteAnyDatabase", "dbAdminAnyDatabase" ]
    }
  );
}