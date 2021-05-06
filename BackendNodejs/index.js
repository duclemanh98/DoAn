
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
/*
 *  This function will check if the array has duplicate value, which is used when creating paper (adding product step)
 *  @param:     array: array that need to be checked
 *  @retval:    true if there are duplicate products
 *              false if no duplicate product
 */

function check_duplicate(array) {
    return new Set(array).size !== array.length;
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
    //console.log(req);
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
 *  @brief: API to create new in paper
 *  request: json file include supplier and created_date
 * 
 *  @retval: ID of paper
 */
app.post('/inPaperCreate', function(req, res){
    let created_at = new Date(req.body.year, req.body.month - 1, req.body.date);
    //let created_at = new Date(2021, 00, 31);
    console.log(created_at);
    pool.query("CALL create_in_paper_with_date(?, ?)", [req.body.store, created_at], function(err, results){
        if(err) return res.json(0);
        pool.query("SELECT MAX(id) AS paper_id FROM InPaperTable", function(err, result) {
            if(err) throw err;
            return res.json(result[0].paper_id);
        })
    })
})

/*
 *  @brief: API when add 1 product to specific in paper
 *  request: json file include:
 *      + paper_id
 *      + cur_name (product name)
 *      + box_amount
 * 
 *  @retval: ID of paper
 */
app.post('/addInProduct', async(req, res) => {
    console.log(req.body.paper_id);
    console.log(req.body.cur_name);
    console.log(req.body.box_amount);
    var duplicate_check = await check_duplicate(req.body.curname);
    if(duplicate_check == true) return res.json(false);         //The array has duplicate products
    else {
        console.log("No duplicate product");
        pool.query('CALL add_product_in_paper(?,?,?)',[req.body.paper_id, req.body.cur_name, req.body.box_amount], function(err, results){
            if(err) return res.json(false);
            return res.json(true);
        })
    }
})




/*
 *  @brief: API to add products after user select all product for current in paper
 *  request: json file include supplier and created_date
 * 
 *  @retval: ID of paper
 */


/*
 *  Note: getting product name and product/box
 */

app.post('/getProductType', function(req, res) {
    console.log("Get product type");
    pool.query('SELECT no_id, cur_name, max_amount FROM ProductTypeTable', function(err, result){
        if(err) throw err;
        //console.log(result);
        res.send(JSON.parse(JSON.stringify(result)));
    });
})

/*
 *  Note: getting product/box from product name
 *  req: json object containe product_name
 */
app.post('/getProdPerBox', function(req, res){
    console.log(req.body.product_name);
    pool.query('SELECT max_amount FROM ProductTypeTable WHERE cur_name = ?',[req.body.product_name], function(err, results){
        if(err) return res.json(0);
        return res.json(results[0].max_amount);
    })
})

/*
 *******************************************************************
 *******************************************************************
 */
app.listen(port, () => {
    console.log(`App listening at http://localhost:${port}`);
});
