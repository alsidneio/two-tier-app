db = connect('mongodb://localhost/admin')

db.createUser({
    user: 'wizAdmin',
    pwd: 'wizAdmin3547',
    roles: [
        { role: 'userAdminAnyDatabase', db: 'admin' },
        { role: 'readWriteAnyDatabase', db: 'admin' },
        { role: 'dbAdminAnyDatabase', db: 'admin' },
        { role: 'clusterAdmin', db: 'admin' }
    ]
});

printjson(db.getUsers());