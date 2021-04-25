
var express = require('express');
var app = express();

port = 3000;

var path = require('path');
var bodyParser = require('body-parser');
app.use(bodyParser.json());


var cors = require('cors');
app.use(cors());

app.use(express.urlencoded( { extended: false}));

var mysql = require('mysql');
const pool = require('./pool');

app.post('/userLogin', function(req, res) {
    // res.header("Access-Control-Allow-Origin", "*");
    // res.header('Access-Control-Allow-Methods: GET, POST, PATCH, PUT, DELETE, OPTIONS'); 
    // res.header('Access-Control-Allow-Headers: Origin, Content-Type, X-Auth-Token');
    console.log(req.body.username, req.body.password);

    pool.query("CALL check_login(?, ?, @checking_val);SELECT @checking_val AS retval",[req.body.username, req.body.password], function(err, result){
        if(err) throw err;
        if(result[1][0].retval == 0) {
            console.log("No account");
            return(res.json(false));
            //return res.json(false);
        }
        else {
            console.log("Correct Account");
            return(res.json(true));
            //return res.json()
        }
    });
});

app.listen(port, () => {
    console.log(`App listening at http://localhost:${port}`);
});