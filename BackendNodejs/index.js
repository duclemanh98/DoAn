
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

function check_duplicate(json_obj) {
    return new Promise(resolve => {
        var valueArr = json_obj.map(function(item){
            return item.nameGet;
        })
        var isDuplicate = valueArr.some(function(item, idx){
            return valueArr.indexOf(item) != idx;
        })
        resolve(isDuplicate);
    })
}

/*
 *  This function will convert date string DD/MM/YYYY to date object
 *  @param:     array: array of date
 *  @retval:    date object
 */
function date_convert(date_arr) {
    var dateParts = date_arr.split("/");
    console.log(dateParts);

    var dateObject = new Date(+dateParts[2], dateParts[1] - 1, +dateParts[0]);
    return dateObject;
}

//----------------------------------------------------------------------------------------//
/*
                        API for backend
*/

//------------------API for User----------------------//

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

//------------------API for Creating In Paper----------------------//

/*
 *  @brief: API to create new in paper
 *  request: json file include supplier and created_date
 * 
 *  @retval: ID of paper
 */
app.post('/inPaperCreate', function(req, res){
    //let created_at = new Date(req.body.year, req.body.month - 1, req.body.date);
    //let created_at = new Date(2021, 00, 31);
    //console.log(created_at);
    var dateObject = date_convert(req.body.created_time);
    console.log(req.body);
    pool.query("CALL create_in_paper_with_date(?,?,?)", [req.body.store, dateObject, req.body.description], function(err){
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
 *  @retval: true or false
 */
app.post('/addInProduct', async(req, res) => {
    //console.log(req.body.paper_id);
    // console.log(req.body);
    var prodFile = JSON.parse(JSON.stringify(req.body.product_info));
    //console.log(product_file);
    console.log(prodFile);
    
    var length = Object.keys(req.body.product_info).length;

    var duplicate_check = await check_duplicate(prodFile);
    if(duplicate_check == true) return res.json(false);         //The array has duplicate products
    else {
        console.log("No duplicate product");
        for(var i=0;i<length;i++) {
            pool.query('CALL add_product_in_paper(?,?,?)',[req.body.paper_id, prodFile[i].nameGet, prodFile[i].boxQuantityGet], function(err, results){
                if(err) return res.json(false);
            })
        }
        return res.json(true);
    }
})


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

//------------------API for Display In Paper----------------------//

/*
 *  @brief: API to show all in paper
 *
 * 
 *  @retval: object contain all info about date
 *  id                      --id of paper
 *  supplier                --supplier
 *  created_at              --date that paper is created
 *  cur_status              --status of paper
 */

app.post('/displayAllInPaper', function(req, res){
    console.log("Display all in paper");
    pool.query('SELECT * FROM InPaperTable', function(err, results){
        if(err) throw err;
        for(var i = 0; i < results.length; i++){
            results[i].created_at = results[i].created_at.split(' ')[0];
        }
        res.send(JSON.parse(JSON.stringify(results)));
    })
})

/*
 *  '/getDetailInPaper'
 *  @brief: API to show specific in paper
 *  req includes: id --- id of paper
 *
 * 
 *  @retval: object contain all info about product in paper
 *  id                  ---- id of product
 *  cur_name            ---- name of product
 *  perbox              ---- number of product per box
 *  box_amount          ---- number of boxes of product in current paper
 *  scan_number         ---- number of scanned box
 */
app.post('/getDetailInPaper', function(req, res) {
    console.log("Get detail of in paper " + req.body.id);
    pool.query('CALL in_paper_detail(?)', [req.body.id], function(err, rows){
        if(err) throw err;
        res.send(JSON.parse(JSON.stringify(rows[0])));
    })
})

/*
 *  '/addInScanProduct'
 *  @brief: API to show specific in paper
 *  req includes:
 *  productID:          ---- specific id of product
 *  typeID              ---- type code of product
 *  paperID             ---- id of paper of product
 *
 * 
 *  @retval: object includes:
 *  type_id:            ---- product type
 *  cur_name:           ---- name of product
 *  perbox:         ---- number of product / box
 *  location_id:        ---- id of location position
 *  building:           ---- building contain current location
 *  building_floor :    ---- floor of current building
 *  room:               ---- 
 *  rack:               ----
 *  rack_bin:           ----
 *  
 */
app.post('/addInScanProduct', function(req, res) {
    console.log("Add scanned product");
    console.log(req.body);
    var product_id = parseInt(req.body.productID);
    if(req.body.productID==''||req.body.typeID==''||req.body.paperID=='') return;
    pool.query('CALL add_in_scanned_product(?,?,?)', [product_id, req.body.typeID, req.body.paperID], function(err){
        if(err) throw err;
        pool.query('CALL assign_location_in_product(?)', [product_id], function(err){
            if(err) throw err;
            pool.query('CALL search_with_product_id(?)', [product_id], function(err, rows){
                if(err) throw err;
                console.log(rows[0]);
                res.send(JSON.parse(JSON.stringify(rows[0])));
            })
        })
    })
})

/*
 *  '/displayInScannedProduct'
 *  @brief: API to show specific in paper
 *  req includes:
 *  paperID             ---- id of paper of product
 *
 * 
 *  @retval: object includes:
 *  type_id:            ---- product type
 *  cur_name:           ---- name of product
 *  perbox:         ---- number of product / box
 *  location_id:        ---- id of location position
 *  building:           ---- building contain current location
 *  building_floor :    ---- floor of current building
 *  room:               ---- 
 *  rack:               ----
 *  rack_bin:           ----
 *  
 */
app.post('/displayInScannedProduct', function(req, res){
    //console.log(req.body);
    console.log("Display scanned products of paper "+req.body.paperID);
    pool.query('CALL search_scanned_product(?)', [req.body.paperID], function(err, rows){
        if(err) throw err;
        res.send(JSON.parse(JSON.stringify(rows[0])));
    })
})

/*
 *  '/confirmInScanPaper'
 *  @brief: API to confirm a paper
 *  req includes:
 *  paperID:    ID of in paper
 *
 * 
 *  @retval: value: 'p': pending or 'c': complete
 */
app.post('/confirmInScanPaper', function(req, res){
    console.log("Confirm in paper "+req.body.paperID);
    pool.query('CALL complete_in_paper(?)', [req.body.paperID], function(err){
        if(err) throw err;
        pool.query('SELECT cur_status FROM InPaperTable WHERE id = ?',[req.body.paperID], function(err, rows) {
            if(err) throw err;
            res.send(rows);
        })
    })
})

//--------------------------------------------------------------------
//---------------************************************-----------------
//--------------- API used for Outward Product -----------------------


/*
 *  '/displayProductLeft'
 *  @brief: API to confirm a paper
 * 
 *  @retval:
 *  type_id:            type of product code
 *  cur_name:           name of product
 *  perbox:             number of products per box
 *  total_amount:       amount of product left in warehouse
 */
app.post('/displayProductLeft', function(req, res) {
    console.log("Get product type and number left in warehouse");
    pool.query('CALL show_total_product_warehouse()', function(err, rows) {
        if(err) throw err;
        res.send(JSON.parse(JSON.stringify(rows[0])));
    })
})

/*
 *  '/createOutPaper'
 *  @brief: API to create Outward paper
 *  req: 
 *  createDate:             ---date created
 *  buyer:                  ---buyer of product
 * 
 *  @retval:
 *  paper_id:               ---ID of paper
 */
app.post('/createOutPaper', function(req, res){
    var dateObject = date_convert(req.body.createDate);
    console.log(req.body);
    pool.query("CALL create_out_paper_with_date(?,?)", [req.body.buyer, dateObject], function(err){
        if(err) return res.json(0);
        pool.query("SELECT MAX(id) AS paper_id FROM OutPaperTable", function(err, rows) {
            if(err) throw err;
            return res.json(rows[0].paper_id);
        })
    })
})

/*
 *  '/addOutProduct'
 *  @brief: API when add 1 product to specific in paper
 *  request: json file include:
 *  + paper_id
 *  + product_info: {type_id, cur_name, amount}
 *  @retval: true or false
 */
app.post('/addOutProduct', async(req, res) => {
    console.log("Add out product");
    console.log(req.body.paper_id);
    var prodFile = JSON.parse(JSON.stringify(req.body.product_info));
    //console.log(product_file);
    console.log(prodFile);
    
    var length = Object.keys(req.body.product_info).length;

    for(var i=0;i<length;i++) {
        pool.query('CALL add_product_type_out_paper(?,?,?)',[req.body.paper_id, prodFile[i].productID, prodFile[i].productQuantity], function(err, results){
            if(err) return res.json(false);
        })
    }
    return res.json(true);
})


/*******---------------------------*********/
/****----API for Searching Out Paper-----****/

/*
 *  '/displayAllOutPaper'
 *  @brief: API to show all out paper
 *
 * 
 *  @retval: object contain all info about date
 *  id                      --id of paper
 *  buyer                   --supplier
 *  created_at              --date that paper is created
 *  cur_status              --status of paper
 */

app.post('/displayAllOutPaper', function(req, res){
    console.log("Display all out paper");
    pool.query('SELECT * FROM OutPaperTable', function(err, rows){
        if(err) throw err;
        for(var i = 0; i < rows.length; i++){
            rows[i].created_at = rows[i].created_at.split(' ')[0];
        }
        res.send(JSON.parse(JSON.stringify(rows)));
    })
})

/*
 *  '/getDetailOutPaper'
 *  @brief: API to show specific out paper
 *  req includes: paperID --- id of paper
 *
 * 
 *  @retval: object contain all info about product in paper
 *  id                  ---- id of product
 *  cur_name            ---- name of product
 *  perbox              ---- number of product per box
 *  amount              ---- number of boxes of product in current paper
 *  selected_amount     ---- number of scanned box
 */
app.post('/getDetailOutPaper', function(req, res) {
    //console.log(req.body);
    console.log("Get detail of out paper " + req.body.paperID);
    pool.query('CALL out_paper_detail(?)', [req.body.paperID], function(err, rows){
        if(err) throw err;
        res.send(JSON.parse(JSON.stringify(rows[0])));
    })
})

/*
 *******************************************************************
 *******************************************************************
 */
app.listen(port, () => {
    console.log(`App listening at http://localhost:${port}`);
});
