###### Procedure related to Inventory Checking (kiem ke san pham)
#--------------------------------

#-------------------------------------------------
### Tao phieu kiem ke
DELIMITER &&
DROP PROCEDURE IF EXISTS InventoryCheckingPaperCreate;
CREATE PROCEDURE InventoryCheckingPaperCreate(IN buildingName CHAR(1), IN buildingFloor INT, IN buildingRoom INT)
BEGIN 
	DECLARE first_pos INT;
    DECLARE last_pos INT;
    DECLARE paperID INT;
    DECLARE temp_count INT;
    
    ## Create in paper table
    SELECT MAX(LocationTable.id), MIN(LocationTable.id) INTO last_pos, first_pos
    FROM LocationTable
    WHERE LocationTable.building = buildingName AND LocationTable.building_floor = buildingFloor AND LocationTable.room = buildingRoom;
    
    INSERT INTO InventoryCheckingPaperTable(first_location, last_location) VALUES (first_pos, last_pos);
END &&
DELIMITER ;

#------------------------------------------------
### Insert in to InventoryCheckingProductTable
DELIMITER &&
DROP PROCEDURE IF EXISTS AddInventoryCheckingProduct;
CREATE PROCEDURE AddInventoryCheckingProduct(IN productID INT, IN paperID INT, IN sysAmount INT)
BEGIN
	INSERT INTO InventoryCheckingProductTable(id, paper_id, sys_amount) VALUES (productID, paperID, sysAmount);
END &&
DELIMITER ;

#---------------------------------------------
#### List all inventory checking paper
DELIMITER &&
DROP PROCEDURE IF EXISTS DisplayAllInventoryPaper;
CREATE PROCEDURE DisplayAllInventoryPaper()
BEGIN
	SELECT InventoryCheckingPaperTable.id, InventoryCheckingPaperTable.created_at,
		   LocationTable.building, LocationTable.building_floor, LocationTable.room,
           InventoryCheckingPaperTable.cur_status
	FROM InventoryCheckingPaperTable
    JOIN LocationTable ON LocationTable.id = InventoryCheckingPaperTable.first_location
    ORDER BY InventoryCheckingPaperTable.id ASC;
END &&
DELIMITER ;

#----------------------------------------------
### Detail for 1 inventory paper
DELIMITER &&
DROP PROCEDURE IF EXISTS ShowDetailCheckingPaper;
CREATE PROCEDURE ShowDetailCheckingPaper(IN checking_paper INT)
BEGIN
	SELECT FactTable.location_id, LocationTable.building, LocationTable.building_floor,
		   LocationTable.room, LocationTable.rack, LocationTable.rack_bin,
		   FactTable.id AS product_id, FactTable.product_type_id, ProductTypeTable.cur_name, 
		   InventoryCheckingProductTable.sys_amount, InventoryCheckingProductTable.real_amount,
           InventoryCheckingProductTable.cur_status, ProductTypeTable.max_amount AS perbox
    FROM FactTable
    JOIN ProductTypeTable ON FactTable.product_type_id = ProductTypeTable.id
    JOIN InventoryCheckingProductTable ON FactTable.id = InventoryCheckingProductTable.id
    JOIN LocationTable ON FactTable.location_id = LocationTable.id
    WHERE InventoryCheckingProductTable.paper_id = checking_paper
    ORDER BY FactTable.location_id ASC;
END &&
DELIMITER ;

#--------------------------------------
#### Procedure to complete CheckingPaper
DELIMITER &&
DROP PROCEDURE IF EXISTS ConfirmInventoryCheckingPaper;
CREATE PROCEDURE ConfirmInventoryCheckingPaper(IN paperID INT)
BEGIN
	DECLARE temp_check INT;
    DECLARE in_check INT;
    DECLARE out_check INT;
    SELECT COUNT(*) INTO temp_check FROM InventoryCheckingProductTable
    WHERE InventoryCheckingProductTable.paper_id = paperID AND InventoryCheckingProductTable.cur_status = 'p';
    
    SELECT COUNT(*) INTO in_check FROM InInventoryProductTable WHERE InInventoryProductTable.paper_id = paperID;
    SELECT COUNT(*) INTO out_check FROM OutInventoryProductTable WHERE OutInventoryProductTable.paper_id = paperID;
    
    IF temp_check = 0 THEN
		IF in_check = 0 AND out_check = 0 THEN
			UPDATE InventoryCheckingPaperTable SET cur_status = 'c' WHERE InventoryCheckingPaperTable.id = paperID;
		ELSE
			UPDATE InventoryCheckingPaperTable SET cur_status = 'm' WHERE InventoryCheckingPaperTable.id = paperID;
		END IF;
	ELSE
		UPDATE InventoryCheckingPaperTable SET cur_status = 'p' WHERE InventoryCheckingPaperTable.id = paperID;
	END IF;
END &&
DELIMITER ;

#-------------------------
#### Add product into InInventoryProductTable
DELIMITER &&
DROP PROCEDURE IF EXISTS AddInInventoryProduct;
CREATE PROCEDURE AddInInventoryProduct(IN productID INT, IN paperID INT, IN addAmount INT)
BEGIN
	DECLARE temp_status CHAR(1);
    
    ###checking status or current product, if already complet => do not add to In Inventory Product
    SELECT InventoryCheckingProductTable.cur_status INTO temp_status FROM InventoryCheckingProductTable
    WHERE InventoryCheckingProductTable.id = productID AND InventoryCheckingProductTable.paper_id = paperID;
    
    IF temp_status = 'p' THEN
		### Add to InInventoryProductTable
        INSERT INTO InInventoryProductTable(product_id, paper_id, amount) VALUES (productID, paperID, addAmount);
        
        ### Update Status in InventoryProductTable
        UPDATE InventoryCheckingProductTable SET cur_status = 'c'
        WHERE InventoryCheckingProductTable.id = productID AND InventoryCheckingProductTable.paper_id = paperID;
	END IF;
END &&
DELIMITER ;

#-------------------------
#### Add product into OutInventoryProductTable
DELIMITER &&
DROP PROCEDURE IF EXISTS AddOutInventoryProduct;
CREATE PROCEDURE AddOutInventoryProduct(IN productID INT, IN paperID INT, IN addAmount INT)
BEGIN
	DECLARE temp_status CHAR(1);
    
    ###checking status or current product, if already complet => do not add to In Inventory Product
    SELECT InventoryCheckingProductTable.cur_status INTO temp_status FROM InventoryCheckingProductTable
    WHERE InventoryCheckingProductTable.id = productID AND InventoryCheckingProductTable.paper_id = paperID;
    
    IF temp_status = 'p' THEN
		INSERT INTO OutInventoryProductTable(product_id, paper_id, amount) VALUES (productID, paperID, addAmount);
		UPDATE InventoryCheckingProductTable SET cur_status = 'c'
        WHERE InventoryCheckingProductTable.id = productID AND InventoryCheckingProductTable.paper_id = paperID;
	END IF;
END &&
DELIMITER ;

#---------------------------------
#### Update Amount of product inside system (FactTable)
DELIMITER &&
DROP PROCEDURE IF EXISTS UpdateAmountProductSystem;
CREATE PROCEDURE UpdateAmountProductSystem(IN productID INT, IN updateAmount INT)
BEGIN
	UPDATE FactTable SET amount = updateAmount WHERE FactTable.id = productID;
END &&
DELIMITER ;

#--------------------------------
##### Show In Inventory Paper
DELIMITER &&
DROP PROCEDURE IF EXISTS DetailInInventoryChecking;
CREATE PROCEDURE DetailInInventoryChecking(IN paperID INT)
BEGIN
	DROP TEMPORARY TABLE IF EXISTS temp_table;
    CREATE TEMPORARY TABLE temp_table AS (
		SELECT FactTable.id AS product_id, ProductTypeTable.id AS type_id, ProductTypeTable.cur_name,
			   LocationTable.id AS location_id, LocationTable.rack, LocationTable.rack_bin,
               LocationTable.building, LocationTable.building_floor, LocationTable.room
		FROM FactTable
		JOIN InventoryCheckingProductTable ON FactTable.id = InventoryCheckingProductTable.id
		JOIN LocationTable ON FactTable.location_id = LocationTable.id
		JOIN ProductTypeTable ON FactTable.product_type_id = ProductTypeTable.id
		WHERE InventoryCheckingProductTable.paper_id = paperID
    );
    
    SELECT temp_table.product_id, temp_table.type_id, temp_table.cur_name,
		   temp_table.location_id, temp_table.rack, temp_table.rack_bin,
           InInventoryProductTable.amount,
           temp_table.building, temp_table.building_floor, temp_table.room
	FROM temp_table
    JOIN InInventoryProductTable ON temp_table.product_id = InInventoryProductTable.product_id
    WHERE InInventoryProductTable.paper_id = paperID
    ORDER BY temp_table.location_id ASC;
END &&
DELIMITER ;

#--------------------------------
##### Show Out Inventory Paper
DELIMITER &&
DROP PROCEDURE IF EXISTS DetailOutInventoryChecking;
CREATE PROCEDURE DetailOutInventoryChecking(IN paperID INT)
BEGIN
	DROP TEMPORARY TABLE IF EXISTS temp_table;
    CREATE TEMPORARY TABLE temp_table AS (
		SELECT FactTable.id AS product_id, ProductTypeTable.id AS type_id, ProductTypeTable.cur_name,
			   LocationTable.id AS location_id, LocationTable.rack, LocationTable.rack_bin,
               LocationTable.building, LocationTable.building_floor, LocationTable.room
		FROM FactTable
		JOIN InventoryCheckingProductTable ON FactTable.id = InventoryCheckingProductTable.id
		JOIN LocationTable ON FactTable.location_id = LocationTable.id
		JOIN ProductTypeTable ON FactTable.product_type_id = ProductTypeTable.id
		WHERE InventoryCheckingProductTable.paper_id = paperID
    );
    
    SELECT temp_table.product_id, temp_table.type_id, temp_table.cur_name,
		   temp_table.location_id, temp_table.rack, temp_table.rack_bin,
           OutInventoryProductTable.amount,
           temp_table.building, temp_table.building_floor, temp_table.room
	FROM temp_table
    JOIN InInventoryProductTable ON temp_table.product_id = InInventoryProductTable.product_id
    WHERE InInventoryProductTable.paper_id = paperID
    ORDER BY temp_table.location_id ASC;
END &&
DELIMITER ;

#---------------------------------------
