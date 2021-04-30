const util = require('util');
const mysql = require('mysql');
/**
 * Connection to the database.
 *  */
const pool = mysql.createPool({
    host: 'localhost',
    user: 'test_connect', // use your mysql username.
    password: 'Tuananh92!', // user your mysql password.
    database: 'wms_db',
    multipleStatements: true
});

pool.getConnection((err, connection) => {
    if(err) 
        console.error("Something went wrong connecting to the database ...");
    
    if(connection)
        console.log("Connected");
        connection.release();
    return;
});

pool.query = util.promisify(pool.query);

module.exports = pool;