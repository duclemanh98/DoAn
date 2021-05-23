
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
const { SSL_OP_EPHEMERAL_RSA } = require('constants');


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
    var dateObject;
    if(date_arr.includes("-")) {
        var dateParts = date_arr.split("-");
        dateObject = new Date(+dateParts[2], dateParts[1] - 1, +dateParts[0]);
    } 
    else {
        var dateParts = date_arr.split("/");
        dateObject = new Date(+dateParts[2], dateParts[1] - 1, +dateParts[0]);
    }
    return dateObject;
}

/*
 *  This function will update scanned data to server
 *  @param:     productInfo:
 *                  boxID:      --- ID of product
 *                  typeID:     --- ID of type code
 *                  amount:     --- number of products selected
 *                  status:     --- pending (p) or complete (c)
 *  @retval:    none
 */
// async function addOutScanProduct(productInfo, paperID) {
//     return new Promise(resolve =>{
//         var i;
//         for(i = 0; i < productInfo.length; i++) {
//             if(productInfo.status == 'c') {
//                 pool.query('CALL scan_out_product(?,?,?,?',[perProductInfo.boxID, perProductInfo.amount, paperID, perProductInfo.typeID], function(err){
//                     if(err) throw err;
//                     resolve('done');
//                 })
//             }
//         }
//     })
// }

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
    if(!req.body.created_time) {
        pool.query("CALL create_in_paper_wo_date(?)", [req.body.store], function(err){
            if(err) return res.json(0);
            pool.query("SELECT MAX(id) AS paper_id FROM InPaperTable", function(err, result) {
                if(err) throw err;
                return res.json(result[0].paper_id);
            })
        })
    }
    else {
        var dateObject = date_convert(req.body.created_time);
        console.log(req.body);
        pool.query("CALL create_in_paper_with_date(?,?,?)", [req.body.store, dateObject, req.body.description], function(err){
            if(err) return res.json(0);
            pool.query("SELECT MAX(id) AS paper_id FROM InPaperTable", function(err, result) {
                if(err) throw err;
                return res.json(result[0].paper_id);
            })
        })
    }
    
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
    pool.query('SELECT id AS type_id, cur_name, max_amount FROM ProductTypeTable', function(err, result){
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
            // results[i].created_at = results[i].created_at.split(' ')[0];
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
 *  @brief: API add 1 scan product to in paper
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
        if(err) {
            console.log("Error in current input product");
            return;
        }
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
        if(err) return;
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
    pool.query('CALL show_total_product_warehouse(?)', [''], function(err, rows) {
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
    if(!req.body.createDate) {
        pool.query("CALL create_out_paper_wo_date(?)", [req.body.buyer], function(err){
            if(err) return res.json(0);
            pool.query("SELECT MAX(id) AS paper_id FROM OutPaperTable", function(err, rows) {
                if(err) throw err;
                return res.json(rows[0].paper_id);
            })
        })
    }
    else {
        var dateObject = date_convert(req.body.createDate);
        console.log(req.body);
        pool.query("CALL create_out_paper_with_date(?,?)", [req.body.buyer, dateObject], function(err){
            if(err) return res.json(0);
            pool.query("SELECT MAX(id) AS paper_id FROM OutPaperTable", function(err, rows) {
                if(err) throw err;
                return res.json(rows[0].paper_id);
            })
        })
    }
    
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
            console.log(rows[i].created_at);
            // rows[i].created_at = rows[i].created_at.split(' ')[0];
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
 *  '/displayOutScannedProduct'
 *  @brief: API to show specific in paper
 *  req includes:
 *  paperID             ---- id of paper of product
 *
 * 
 *  @retval: object includes:
 *  product_id:         ---- id of product
 *  type_id:            ---- product type
 *  cur_name:           ---- name of product
 *  perbox:             ---- amount of product/box
 *  amount:             ---- required amount to be taken from location
 *  location_id:        ---- id of location position
 *  building:           ---- building contain current location
 *  building_floor :    ---- floor of current building
 *  room:               ---- 
 *  rack:               ----
 *  rack_bin:           ----
 *  cur_status:          ---- display if product is taken or not
 */
app.post('/displayOutScannedProduct', function(req, res){
    if(req.body.paperID == '') return;
    console.log("Display scanned product of out paper "+req.body.paperID);

    pool.query('CALL show_out_paper_scan_product(?)', [req.body.paperID], function(err, rows){
        if(err) throw err;
        res.send(JSON.parse(JSON.stringify(rows[0])));
    })
})

/*
 *  '/confirmOutScanProduct'
 *  @brief: API to add 1 scanned out product
 *  req includes:
 *  paperID             ---- id of paper of product
 *  productInfo:
 *      productID:          ---- specific id of product
 *      typeID              ---- type code of product
 *      amount:             ---- selected amount of product
 *      cur_status:         ---- check if product is scanned or not
 * 
 *  @retval: true/false
 *  
 */

app.post('/confirmOutScanProduct', async(req, res) => {
    console.log("Confirm out paper "+req.body.paperID);
    var prodFile = req.body.productInfo;
    for(var i = 0; i < req.body.productInfo.length; i++) {
        pool.query('CALL scan_out_product(?,?,?,?)', [prodFile[i].productID, prodFile[i].amount, req.body.paperID, prodFile[i].typeID], function(err) {
            if(err) throw err;
        }) 
    }
})


/*******---------------------------*********/
/****----API for Warehouse Report-----****/

/*
 *  '/searchImportExport'
 *  @brief: API to show import and export of products inside warehouse
 *  req includes 2 dates to search
 *  firstDate:            ---- 
 *  lastDate:
 *  keyword:
 * 
 *  @retval:
 *  type_id:            ---- id code of product type
 *  cur_name:           ---- name of product
 *  perbox:             ---- number of products / box
 *  in_number:          ---- number of in boxes
 *  out_number:         ---- number of out products
 *  
 */
app.post('/searchImportExport', function(req, res) {
    console.log("Searching import and export amount between "+ req.body.firstDate + " and " + req.body.lastDate);
    var first_date, last_date;
    if(req.body.firstDate == '') {
        first_date = date_convert('01/01/0000');
    } 
    else first_date = date_convert(req.body.firstDate);

    if(req.body.lastDate == '') {
        last_date = date_convert('31/12/2099');
    }
    else last_date = date_convert(req.body.lastDate);
    // var first_date = date_convert(req.body.firstDate);
    // var last_date = date_convert(req.body.lastDate);
    if(req.body.keyword == '') {
        pool.query('CALL search_inout_product(?,?,?)', [first_date, last_date, req.body.keyword], function(err, rows){
            if(err) throw err;
            res.send(JSON.parse(JSON.stringify(rows[0])));
        })
    }
    else {
        pool.query('CALL search_inout_product(?,?,?)', [first_date, last_date, req.body.keyword.name], function(err, rows){
            if(err) throw err;
            res.send(JSON.parse(JSON.stringify(rows[0])));
        })
    } 
})


/*
 *  '/searchWarehouseProduct'
 *  @brief: API to show number products inside warehouse
 *  keyword:            ---- name of product or ''
 * 
 *  @retval:
 *  type_id:            ---- id code of product type
 *  cur_name:           ---- name of product
 *  total_amount:       ---- number of selected products in warehouse
 *  
 */
app.post('/searchWarehouseProduct', function(req, res) {
    console.log(req.body);
    console.log("Searching number of product left in warehouse");
    if(!req.body.keyword) {
        pool.query('CALL show_total_product_warehouse(?)', [''], function(err, rows){
            if(err) return;
            res.send(JSON.parse(JSON.stringify(rows[0])));
        })
    }
    else {
        pool.query('CALL show_total_product_warehouse(?)', [req.body.keyword], function(err, rows){
            if(err) return;
            res.send(JSON.parse(JSON.stringify(rows[0])));
        })
    }
})


/********************************************/
/**** Create Inventory Checking *************/

/*
 *  '/checkValidLocation'
 *  @brief: API used before creating Inventory Checking paper and Inventory checking product => check if location is valid
 *  buildingName:           ---- building I or J or K
 *  buildingFloor:          ---- 1 2 3
 *  buildingRoom:           ---- 
 * 
 *  @retval: true or false
 *  
 */

app.post('/checkValidLocation', function(req, res){
    console.log('Check location: building ?, floor ?, room ?', [req.body.buildingName, req.body.buildingFloor, req.body.buildingRoom]);
    pool.query('SELECT COUNT(*) AS num FROM LocationTable WHERE building = ? AND building_floor = ? AND room = ?', [req.body.buildingName, req.body.buildingFloor, req.body.buildingRoom], function(err, rows){
        if(err) throw err;
        if(rows[0].num == 0) return res.json(false);
        else return res.json(true);
    })
})


//--------------------------------------
/*
 *  @brief: API to create Inventory Checking Paper and return ID of paper
 */
function createInventoryChecking(req) {
    return new Promise(resolve => {
        pool.query('CALL InventoryCheckingPaperCreate(?,?,?)',[req.body.buildingName, req.body.buildingFloor, req.body.buildingRoom], function(err) {
            if(err) throw err;
            pool.query('SELECT MAX(id) AS id FROM InventoryCheckingPaperTable', function(err, rows) {
                if(err) throw err;
                resolve(rows[0].id);
            })    
        })
    })
}
/*
 *  @brief: API to select all products corresponding to location sent in request
 */
function selectProductInLocation(req) {
    return new Promise(resolve => {
        pool.query('CALL show_products_according_location(?,?,?)', [req.body.buildingName, req.body.buildingFloor, req.body.buildingRoom], function(err, rows){
            if(err) throw err;
            resolve(rows[0]);
        })
    })
}

/*
 *  @brief: adding each product into InventoryProductTable
 */
function addPerProductToInventory(perProductFile, paperID) {
    return new Promise(resolve => {
        pool.query('CALL AddInventoryCheckingProduct(?,?,?)', [perProductFile.id, paperID, perProductFile.amount], function(err){
            if(err) throw err;
            resolve(true);
        })
    })
}

/*
 *  '/createInventoryCheckingPaper'
 *  @brief: API to create Inventory Checking paper and Inventory checking product
 *  createDate:             ---- Date Created
 *  buildingName:           ---- building I or J or K
 *  buildingFloor:          ---- 1 2 3
 *  buildingRoom:           ---- 
 * 
 *  @retval:
 *  location_id
 *  building
 *  building_floor
 *  room
 *  rack
 *  rack_bin
 *  product_id
 *  product_type_id
 *  cur_name
 *  sys_amount
 *  real_amount
 *  cur_status
 *  
 */

app.post('/createInventoryCheckingPaper', async(req, res) => {
    console.log('Create Inventory Checking Paper');
    //console.log(req.body);
    var paperID = await createInventoryChecking(req);
    var productFile = await selectProductInLocation(req);
    
    for(var i = 0; i < productFile.length; i++) {
        await addPerProductToInventory(productFile[i], paperID);
    }
    pool.query('CALL ShowDetailCheckingPaper(?)', [paperID], function(err, rows) {
        if(err) throw err;
        res.send(JSON.parse(JSON.stringify(rows[0])))
    })
})

/*
 *  '/detailInventoryCheckingPaper'
 *  @brief: API to show detail of Inventory Checking paper
 *  req: paperID:           --- ID of checking paper
 *  
 *  @retval:
 *  location_id:            --- ID of location
 *  building
 *  building_floor
 *  room
 *  rack
 *  rack_bin
 *  product_id:             --- ID of product
 *  product_type_id:        --- ID of type
 *  cur_name:               --- name of product
 *  sys_amount:             --- number of products on system
 *  real_amount:            --- number of products in real life
 *  cur_status:             --- status of product checking (p or c)
 *  perbox
 *  
 */
app.post('/detailInventoryCheckingPaper', function(req, res) {
    //console.log(req.body);
    console.log('Detail of Inventory Checking Paper '+req.body.paperID);
    pool.query('CALL ShowDetailCheckingPaper(?)', [req.body.paperID], function(err, rows){
        if(err) throw err;
        res.send(JSON.parse(JSON.stringify(rows[0])));
    })
})


/*
 *  '/displayAllInventoryCheckingPaper'
 *  @brief: API to list all Inventory Checking paper     
 * 
 *  @retval:
 *  id:         --- id of checking paper
 *  created_at: --- time created
 *  building:
 *  building_floor
 *  building_room
 *  cur_status:           --- 'c' - complete and correct / 'p' pending / m: complete but missing products
 */

app.post('/displayAllInventoryCheckingPaper', function(req, res){
    console.log('Display all Inventory checking paper');
    pool.query('CALL DisplayAllInventoryPaper()', function(err, rows){
        if(err) throw err;
        res.send(JSON.parse(JSON.stringify(rows[0])));
    })
})


//---------------------------------------------
function AddInventoryProduct(perProductFile, paperID){
    return new Promise(resolve => {
        if(perProductFile.cur_status == 'c') {
            if(perProductFile.real_amount > perProductFile.sys_amount) {
                var addAmount = productFile[i].real_amount - productFile[i].sys_amount;
                pool.query('CALL AddInInventoryProduct(?,?,?)',[perProductFile.productID, paperID, addAmount], function(err){
                    if(err) throw err;
                    pool.query('CALL UpdateAmountProductSystem(?,?)', [perProductFile.productID, perProductFile.real_amount], function(err){
                        if(err) throw err;
                        resolve(true);
                    })
                })
            }
            else if(perProductFile.real_amount < perProductFile.sys_amount) {
                var addAmount = perProductFile.sys_amount - perProductFile.real_amount;
                pool.query('CALL AddOutInventoryProduct(?,?,?)',[perProductFile.productID, paperID, addAmount], function(err){
                    if(err) throw err;
                    pool.query('CALL UpdateAmountProductSystem(?,?)', [perProductFile.productID, perProductFile.real_amount], function(err){
                        if(err) throw err;
                        resolve(true);
                    })
                })
            }
        }
    })
}

/*
 *  '/confirmInventoryCheckingPaper'
 *  @brief: API to confirm 1 inventory checking paper / automatically generate in and out inventory paper
 *  req includes:  
 *  paperID:            --- id of checking paper
 *  productInfo:
 *      productID:      --- id of product
 *      sys_amount:     --- number of products on system
 *      real_amount:    --- amount of products in real life
 *      cur_status:     --- status of checking products (checked or not - c or p)
 * 
 *  @retval: none
 *  
 */

app.post('/confirmInventoryCheckingPaper', async(req, res) => {
    console.log('Confirm Inventory Checking Paper '+req.body.paperID);
    var productFile = req.body.productInfo;
    for(var i = 0; i < productFile.length; i++) {
        await AddInventoryProduct(productFile[i], paperID);
    }
    pool.query('CALL ConfirmInventoryCheckingPaper(?)', [req.body.paperID], function(err){
        if(err) throw err;
    })
})


/*
 *  '/detailInInventoryPaper'
 *  @brief: API to show detail of In Inventory paper
 *  req: paperID:           --- ID of checking paper
 *  
 *  @retval:
 *  location_id:            --- ID of location
 *  building
 *  building_floor
 *  room
 *  rack
 *  rack_bin
 *  product_id:             --- ID of product
 *  type_id:                --- ID of type
 *  cur_name:               --- name of product
 *  amount:                 --- in amount
 *  
 */

app.post('/detailInInventoryPaper', function(req, res){
    console.log('Show detail of In Inventory of paper '+req.body.paperID);
    pool.query('CALL DetailInInventoryChecking(?)', [req.body.paperID], function(err, rows) {
        if(err) throw err;
        res.send(JSON.parse(JSON.stringify(rows[0])));
    })
})

/*
 *  '/detailOutInventoryPaper'
 *  @brief: API to show detail of Out Inventory paper
 *  req: paperID:           --- ID of checking paper
 *  
 *  @retval:
 *  location_id:            --- ID of location
 *  building
 *  building_floor
 *  room
 *  rack
 *  rack_bin
 *  product_id:             --- ID of product
 *  type_id:                --- ID of type
 *  cur_name:               --- name of product
 *  amount:                 --- out amount
 *  
 */

app.post('/detailOutInventoryPaper', function(req, res){
    console.log('Show detail of Out Inventory of paper '+req.body.paperID);
    pool.query('CALL DetailOutInventoryChecking(?)', [req.body.paperID], function(err, rows) {
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
