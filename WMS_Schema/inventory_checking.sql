###### Procedure related to Inventory Checking (kiem ke san pham)
#--------------------------------

#-------------------------------------------------
### Tao phieu kiem ke
DELIMITER &&
DROP PROCEDURE IF EXISTS InventoryCheckingPaperCreate;
CREATE PROCEDURE InventoryCheckingPaperCreate(IN buildingName CHAR(1), IN buildingFloor INT, IN buildingRoom INT, IN check_desc VARCHAR(100), IN createUser VARCHAR(50))
BEGIN 
	DECLARE first_pos INT;
    DECLARE last_pos INT;
    DECLARE paperID INT;
    DECLARE temp_count INT;
    
    ## Create in paper table
    SELECT MAX(LocationTable.id), MIN(LocationTable.id) INTO last_pos, first_pos
    FROM LocationTable
    WHERE LocationTable.building = buildingName AND LocationTable.building_floor = buildingFloor AND LocationTable.room = buildingRoom;
    
    INSERT INTO InventoryCheckingPaperTable(first_location, last_location, paper_desc, create_user) VALUES (first_pos, last_pos, check_desc, createUser);
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
           InventoryCheckingPaperTable.cur_status, InventoryCheckingPaperTable.paper_desc,
           InventoryCheckingPaperTable.create_user
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

#----------------------------------------------
#### Procedure to update product in inventory product table when doing checking
DELIMITER &&
DROP PROCEDURE IF EXISTS UpdateIOInventoryChecking;
CREATE PROCEDURE UpdateIOInventoryChecking(IN productID INT, IN paperID INT, IN sysAmount INT, IN realAmount INT)
BEGIN
	DECLARE misAmount INT;
    DECLARE in_stat INT;
    DECLARE out_stat INT;
    
    SELECT in_status, out_status INTO in_stat, out_stat FROM InventoryCheckingPaperTable 
    WHERE InventoryCheckingPaperTable.id = paperID;
	
    IF in_stat = 0 AND out_stat = 0 THEN
		UPDATE InventoryCheckingProductTable SET real_amount = realAmount, cur_status = 'c'
		WHERE InventoryCheckingProductTable.id = productID AND InventoryCheckingProductTable.paper_id = paperID;
    
		IF realAmount > sysAmount THEN
			SET misAmount = realAmount - sysAmount;
			UPDATE InventoryCheckingProductTable SET mis_amount = misAmount, product_dir = 'i'
			WHERE InventoryCheckingProductTable.id = productID AND InventoryCheckingProductTable.paper_id = paperID;
		ELSEIF realAmount < sysAmount THEN
			SET misAmount = sysAmount - realAmount;
			UPDATE InventoryCheckingProductTable SET mis_amount = misAmount, product_dir = 'o'
			WHERE InventoryCheckingProductTable.id = productID AND InventoryCheckingProductTable.paper_id = paperID;
		ELSE
			UPDATE InventoryCheckingProductTable SET mis_amount = 0
			WHERE InventoryCheckingProductTable.id = productID AND InventoryCheckingProductTable.paper_id = paperID;
		END IF;
	END IF;
END &&
DELIMITER ;

#--------------------------------------
#### Update paper desc for checking paper
DELIMITER &&
DROP PROCEDURE IF EXISTS UpdatePaperDescCheckingPaper;
CREATE PROCEDURE UpdatePaperDescCheckingPaper(IN paperID INT, IN paperDesc VARCHAR(1000))
BEGIN
	DECLARE newDesc VARCHAR(1000);
    DECLARE finish_check CHAR(1);
    
    SELECT cur_status INTO finish_check FROM InventoryCheckingPaperTable WHERE id = paperID;
    
    IF finish_check != 'c' THEN
		SELECT paper_desc INTO newDesc FROM InventoryCheckingPaperTable WHERE id = paperID;
        IF ISNULL(newDesc) = 1 THEN
			SET newDesc = paperDesc;
		ELSE
			SET newDesc = CONCAT(newDesc, "\n", paperDesc);
		END IF;
        
        UPDATE InventoryCheckingPaperTable SET paper_desc = newDesc WHERE id = paperID;
    END IF;
END &&
DELIMITER ;

#--------------------------------------
#### Procedure to complete CheckingPaper
DELIMITER &&
DROP PROCEDURE IF EXISTS ConfirmInventoryCheckingPaper;
CREATE PROCEDURE ConfirmInventoryCheckingPaper(IN paperID INT)
BEGIN
	DECLARE temp_check INT;
    DECLARE io_check INT;
    DECLARE finish_check CHAR(1);
    
    SELECT cur_status INTO finish_check FROM InventoryCheckingPaperTable WHERE id = paperID;
    #check if finish or not
    
    IF finish_check != 'c' THEN
		SELECT COUNT(*) INTO temp_check FROM InventoryCheckingProductTable
		WHERE InventoryCheckingProductTable.paper_id = paperID AND InventoryCheckingProductTable.cur_status = 'p';
    
		SELECT COUNT(*) INTO io_check FROM InventoryCheckingProductTable 
		WHERE InventoryCheckingProductTable.paper_id = paperID AND InventoryCheckingProductTable.mis_amount != 0;
    
		IF temp_check = 0 THEN
			IF io_check = 0 THEN
				UPDATE InventoryCheckingPaperTable SET cur_status = 'c' WHERE InventoryCheckingPaperTable.id = paperID;
			ELSE
				UPDATE InventoryCheckingPaperTable SET cur_status = 'm' WHERE InventoryCheckingPaperTable.id = paperID;
			END IF;
		ELSE
			UPDATE InventoryCheckingPaperTable SET cur_status = 'p' WHERE InventoryCheckingPaperTable.id = paperID;
		END IF;
	END IF;
END &&
DELIMITER ;

#---------------------------------
#### Update Amount of product inside system (FactTable)
DELIMITER &&
DROP PROCEDURE IF EXISTS UpdateAmountProductSystem;
CREATE PROCEDURE UpdateAmountProductSystem(IN productID INT, IN misAmount INT, IN in_out CHAR(1), IN paperID INT)
BEGIN
	DECLARE location INT;
    DECLARE temp_amount INT;
    DECLARE in_stat, out_stat INT;
    
    SELECT FactTable.amount INTO temp_amount FROM FactTable WHERE FactTable.id = productID;
    SELECT in_status, out_status INTO in_stat, out_stat FROM InventoryCheckingPaperTable
    WHERE id = paperID;
    
    IF in_out = 'i' AND in_stat = 0 THEN
		SET temp_amount = temp_amount + misAmount;
	END IF;
    
    IF in_out = 'o' AND out_stat = 0 THEN
		SET temp_amount = temp_amount - misAmount;
    END IF;
    
	UPDATE FactTable SET amount = temp_amount WHERE FactTable.id = productID;
    
    IF temp_amount = 0 THEN
		SELECT location_id INTO location FROM FactTable WHERE FactTable.id = productID;
        UPDATE FactTable SET location_id = NULL WHERE FactTable.id = productID;
        UPDATE LocationTable SET bin_status = 'free' WHERE LocationTable.id = location;
    END IF;
END &&
DELIMITER ;

#--------------------------------
##### Show In Inventory Paper
DELIMITER &&
DROP PROCEDURE IF EXISTS DetailInInventoryChecking;
CREATE PROCEDURE DetailInInventoryChecking(IN paperID INT)
BEGIN
	SELECT LocationTable.id AS location_id, LocationTable.building, LocationTable.building_floor,
		LocationTable.room, LocationTable.rack, LocationTable.rack_bin,
        FactTable.id AS product_id,  FactTable.product_type_id,
        ProductTypeTable.cur_name,
        InventoryCheckingProductTable.mis_amount
    FROM FactTable
    JOIN LocationTable ON FactTable.old_location = LocationTable.id
    JOIN InventoryCheckingProductTable ON FactTable.id = InventoryCheckingProductTable.id
    JOIN ProductTypeTable ON FactTable.product_type_id = ProductTypeTable.id
    WHERE InventoryCheckingProductTable.paper_id = paperID AND product_dir = 'i'
	ORDER BY LocationTable.id ASC;
END &&
DELIMITER ;

#--------------------------------
##### Show Out Inventory Paper
DELIMITER &&
DROP PROCEDURE IF EXISTS DetailOutInventoryChecking;
CREATE PROCEDURE DetailOutInventoryChecking(IN paperID INT)
BEGIN
	SELECT LocationTable.id AS location_id, LocationTable.building, LocationTable.building_floor,
		LocationTable.room, LocationTable.rack, LocationTable.rack_bin,
        FactTable.id AS product_id,  FactTable.product_type_id,
        ProductTypeTable.cur_name,
        InventoryCheckingProductTable.mis_amount
    FROM FactTable
    JOIN LocationTable ON FactTable.old_location = LocationTable.id
    JOIN InventoryCheckingProductTable ON FactTable.id = InventoryCheckingProductTable.id
    JOIN ProductTypeTable ON FactTable.product_type_id = ProductTypeTable.id
    WHERE InventoryCheckingProductTable.paper_id = paperID AND product_dir = 'o'
	ORDER BY LocationTable.id ASC;
END &&
DELIMITER ;

#---------------------------------------
#### Procedure used to set the checking to be completed even if mismatch
DELIMITER &&
DROP PROCEDURE IF EXISTS ConfirmMismatchCheckingPaper;
CREATE PROCEDURE ConfirmMismatchCheckingPaper(IN paperID INT)
BEGIN
	UPDATE InventoryCheckingPaperTable
    SET cur_status = 'c'
    WHERE InventoryCheckingPaperTable.id = paperID AND InventoryCheckingPaperTable.in_status = 1
		AND InventoryCheckingPaperTable.out_status = 1;
END &&
DELIMITER ;

#### Procedure to update in / out status
DELIMITER &&
DROP PROCEDURE IF EXISTS ConfirmIOCheckingPaper;
CREATE PROCEDURE ConfirmIOCheckingPaper(IN paperID INT, IN io_check CHAR(1))
BEGIN
	IF io_check = 'i' THEN
		UPDATE InventoryCheckingPaperTable
		SET in_status = 1
		WHERE InventoryCheckingPaperTable.id = paperID;
	ELSEIF io_check = 'o' THEN
		UPDATE InventoryCheckingPaperTable
		SET out_status = 1
		WHERE InventoryCheckingPaperTable.id = paperID;
	END IF;
END &&
DELIMITER ;

#### Check if blank paper => confirm in/out
DELIMITER &&
DROP PROCEDURE IF EXISTS CheckBlankIOChecking;
CREATE PROCEDURE CheckBlankIOChecking(IN paperID INT)
BEGIN
	DECLARE check_count INT;
    SELECT COUNT(*) INTO check_count FROM InventoryCheckingProductTable
    WHERE paper_id = paperID AND product_dir = 'i' AND mis_amount != 0;
    
    IF check_count = 0 THEN
		UPDATE InventoryCheckingPaperTable SET in_status = 1 WHERE id = paperID;
    END IF;
    
    SELECT COUNT(*) INTO check_count FROM InventoryCheckingProductTable
    WHERE paper_id = paperID AND product_dir = 'o' AND mis_amount != 0;
    
    IF check_count = 0 THEN
		UPDATE InventoryCheckingPaperTable SET out_status = 1 WHERE id = paperID;
    END IF;
END &&
DELIMITER ;