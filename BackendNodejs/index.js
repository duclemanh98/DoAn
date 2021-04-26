
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
    // if(check_login(req) == false) return res.json(false);
    // else return res.json(true);
    // pool.query("CALL check_login(?, ?, @checking_val);SELECT @checking_val AS retval",[req.body.username, req.body.password], function(err, result){
    //     if(err) throw err;
    //     if(result[1][0].retval == 0) {
    //         console.log("No account");
    //         return(res.json(false));
    //         //return res.json(false);
    //     }
    //     else {
    //         console.log("Correct Account");
    //         return(res.json(true));
    //         //return res.json()
    //     }
    // });
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
app.post('/userAdd', function(req, res){
    pool.query('CALL add_user(?,?,?)',[req.body.username, req.body.password, req.body.auth], function(err, results){
        if(err) {
            return res.json(err);
            throw err;
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
app.post('/userDelete', function(req, res){
    pool.query('CALL check_login(?, ?, @val);SELECT @val AS retval',[req.body.username, req.body.password], function(err, results){
        if(err) return res.json(err);
        if(result[1][0].retval == 0) {
            return res.json("Wrong username or password");
        }
        else {
            pool.query('CALL delete_user(?,?)',[req.body.username, req.body.password], function(err, results){
                if(err) return res.json(err);
                return res.json("Delete Success");
            })
        }
    })
})



app.listen(port, () => {
    console.log(`App listening at http://localhost:${port}`);
});
