db = connect('mongodb://localhost/uploaded-files')

db.createUser({
    user: 'wizUser',
    pwd: 'wizUser3547',
    roles: [
        { role: 'readWrite', db: 'uploaded-files' },
        { role: 'dbAdmin', db: 'uploaded-files' }
    ]
});

// Create a sample collection to ensure database exists
db.test.insertOne({ message: 'Database created successfully', timestamp: new Date() });
printjson('Database and user created successfully');

printjson(db.getUsers());
printjson(db.getCollectionNames())