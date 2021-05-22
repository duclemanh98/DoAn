###### Procedure related to Inventory Checking (kiem ke san pham)

#-------------------------------------------------
### Tao phieu kiem ke
DELIMITER &&
DROP PROCEDURE IF EXISTS InventoryCheckingPaperCreate;
CREATE PROCEDURE InventoryCheckingPaperCreate(IN createDate DATETIME, IN buildingName CHAR(1), IN buildingFloor INT, IN buildingRoom INT)
BEGIN 
	DECLARE first_pos INT;
    DECLARE last_pos INT;
    DECLARE paperID INT;
    DECLARE temp_count INT;
    
    ## Create in paper table
    SELECT MAX(LocationTable.id), MIN(LocationTable.id) INTO last_pos, first_pos
    FROM LocationTable
    WHERE LocationTable.building = buildingName AND LocationTable.building_floor = buildingFloor AND LocationTable.room = buildingRoom;
    
    INSERT INTO InventoryCheckingPaperTable(created_at, first_location, last_location) VALUES (createDate, first_pos, last_pos);
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

#----------------------------------------------
### Detail for each location in inventory paper
DELIMITER &&
DROP PROCEDURE IF EXISTS ShowDetailCheckingPaper;
CREATE PROCEDURE ShowDetailCheckingPaper(IN checking_paper INT)
BEGIN
	SELECT FactTable.location_id, FactTable.id, FactTable.product_type_id, ProductTypeTable.cur_name, 
		   InventoryCheckingProductTable.sys_amount, InventoryCheckingProductTable.cur_status
    FROM FactTable
    JOIN ProductTypeTable ON FactTable.product_type_id = ProductTypeTable.id
    JOIN InventoryCheckingProductTable ON FactTable.id = InventoryCheckingProductTable.id
    WHERE InventoryCheckingProductTable.paper_id = checking_paper
    ORDER BY FactTable.location_id ASC;
END &&
DELIMITER ;

#-------------------------