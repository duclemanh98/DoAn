
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
const { getConnection, query } = require('./pool');


/*
 *  Function Prototype used
 */
function check_login(req) {
    return new Promise(resolve => {
        pool.query("CALL check_login(?, ?, @checking_val);SELECT @checking_val AS retval",[req.body.username, req.body.password], function(err, results){
            if(err) throw err;
            if(results[1][0].retval == 0) resolve(false);
            else resolve(true);
        });
    })
}

//----------------------------------------------------------------------------------------//
/*
                        API for backend
*/

/*
 *  @brief: API to check user login, request contain json included username and password
 */
app.post('/userLogin', async(req, res) => {
    console.log(req.body.username, req.body.password);
    try {
        var query_result = await check_login(req);
        //console.log(query_result);
        return res.json(query_result); 
    }
    catch(error) {
        console.log(error);
    }
});


/*
 *  @brief: API to add user into database
 *  request: json include: username, password, auth
 */
app.post('/addUser', function(req, res){
    console.log(req);
    pool.query('CALL add_user(?,?,?)',[req.body.username, req.body.password, req.body.role], function(err, results){
        if(err) {
            return res.json(false);
        }
        console.log("Add successfully");
        return (res.json(true));
    });
});

/*
 *  @brief: API to delete user from database
 *  request: json include: username, password
 * 
 *  Note: change return value according to display
 */
app.post('/userDelete', async(req, res) => {
    var query_result = await check_login(req);
    if(query_result == false) {
        return res.json("No account");
    }
    else {
        pool.query('CALL delete_user(?,?)',[req.body.username, req.body.password], function(err){
            if(err) throw err;
            return res.json("Success");
        });
    }
})

/*
 *******************************************************
 *******************************************************
 */

/*
 *  Note: getting product name and product/box
 */

app.post('/getProductType', function(req, res) {
    console.log("Get product type");
    pool.query('SELECT no_id, cur_name, max_amount FROM ProductTypeTable LIMIT 5', function(err, result){
        if(err) throw err;
        //console.log(result);
        res.send(JSON.parse(JSON.stringify(result)));
    });
})



/*
 *******************************************************************
 *******************************************************************
 */
app.listen(port, () => {
    console.log(`App listening at http://localhost:${port}`);
});
