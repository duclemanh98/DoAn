###### SQL query procedure for insert data in to in paper

#----------------------------------------------------------
DELIMITER &&
DROP PROCEDURE IF EXISTS create_in_paper_with_date;
CREATE PROCEDURE create_in_paper_with_date(IN supply VARCHAR(100), IN create_time DATETIME, IN in_desc VARCHAR(100), IN createUser VARCHAR(50))
BEGIN
	INSERT INTO InPaperTable(supplier, created_at, paper_desc, create_user) VALUES (supply, DATE(create_time), in_desc, createUser);
END &&
DELIMITER ;

#----------------------------------------------------------
DELIMITER &&
DROP PROCEDURE IF EXISTS create_in_paper_wo_date;
CREATE PROCEDURE create_in_paper_wo_date(IN supply VARCHAR(100), IN createUser VARCHAR(50))
BEGIN
	INSERT INTO InPaperTable(supplier, create_user) VALUES (supply, createUser);
END &&
DELIMITER ;

#----------------------------------------------------------
### Insert 1 product type into in paper/use for admin when creating in paper
DELIMITER &&
DROP PROCEDURE IF EXISTS add_product_in_paper;
CREATE PROCEDURE add_product_in_paper(IN paper INT, IN product_name VARCHAR(100), IN amount INT)
BEGIN
	DECLARE product_type VARCHAR(15);
    SELECT id INTO product_type FROM ProductTypeTable
    WHERE ProductTypeTable.cur_name = product_name;
	INSERT INTO InProductTable(id, paper_id, box_amount) VALUES (product_type, paper, amount);
    CALL add_bar_code_with_name(product_name, paper, amount);
END &&
DELIMITER ;

#----------------------------------------------------------
### Delete 1 product from in paper (used by admin when creating)
DELIMITER &&
DROP PROCEDURE IF EXISTS delete_product_in_paper;
CREATE PROCEDURE delete_product_in_paper(IN paper INT, IN product_type VARCHAR(15))
BEGIN
	DELETE FROM InProductTable WHERE InProductTable.paper_id = paper AND InProductTable.id = product_type;
END &&
DELIMITER ;
#----------------------------------------------------------
### update status of in paper/use for user when submit in paper
DELIMITER &&
DROP PROCEDURE IF EXISTS complete_in_paper;
CREATE PROCEDURE complete_in_paper(IN paper INT, IN confirmUser VARCHAR(50))
BEGIN
	DECLARE total_box INT;
    DECLARE scan_box INT;
    DECLARE location_null_count INT;
    DECLARE location_temp_count INT;
    DECLARE username VARCHAR(500);
	DECLARE temp_name VARCHAR(500);
    
    IF confirmUSer != '' THEN
		SELECT confirm_user INTO username FROM InPaperTable WHERE id = paper;
		IF ISNULL(username) = 1 OR username = '' THEN
			UPDATE InPaperTable SET confirm_user = confirmUser WHERE id = paper;
		ELSE
			SELECT confirm_user INTO temp_name FROM InPaperTable WHERE id = paper;
			SET temp_name = CONCAT(temp_name, "\n", confirmUser);
			UPDATE InPaperTable SET confirm_user = temp_name WHERE id = paper;
		END IF;
	END IF;
    
    SELECT SUM(box_amount) INTO total_box FROM InProductTable
    WHERE paper = InProductTable.paper_id;
    
    SELECT SUM(scan_number) INTO scan_box FROM InProductTable
    WHERE paper = InProductTable.paper_id;
    
    SELECT COUNT(*) INTO location_null_count FROM FactTable
    WHERE FactTable.in_paper_id = paper AND ISNULL(FactTable.location_id);
    
    SELECT COUNT(*) INTO location_temp_count FROM FactTable
    JOIN InProductTable ON InProductTable.id = FactTable.product_type_id
    JOIN LocationTable ON FactTable.location_id = LocationTable.id
    WHERE LocationTable.bin_status != 'occu' AND FactTable.in_paper_id = paper;
    
	IF total_box = scan_box AND location_null_count = 0 AND location_temp_count = 0 THEN
		UPDATE InPaperTable SET cur_status = 'c' WHERE paper = InPaperTable.id;
	ELSE
		UPDATE InPaperTable SET cur_status = 'p' WHERE paper = InPaperTable.id;
	END IF;
END &&
DELIMITER ;

#----------------------------------------------------------
# increase 1 scan number and add to fact table/ user for user when choosing scanning
# Note: backend should stop calling this function when user has reaches max scan for one type of product 
### Deprecated procedure
DELIMITER &&
DROP PROCEDURE IF EXISTS increase_in_scan_product;
CREATE PROCEDURE increase_in_scan_product(IN paper INT, IN product_type VARCHAR(15))
BEGIN
	DECLARE current_amount INT;
    SELECT scan_number INTO current_amount FROM InProductTable
    WHERE paper = InProductTable.paper_id AND product_type = InProductTable.id;
    SET current_number = current_number + 1;
    UPDATE InProductTable SET InProductTable.scan_number = current_number
    WHERE product_type = InProductTable.id AND paper = InProductTable.paper_id;
END &&
DELIMITER ;

#----------------------------------------------------------
### insert product into fact table (used with increase_in_scan_product) 
### Deprecated
DELIMITER &&
DROP PROCEDURE IF EXISTS add_product_fact_table;
CREATE PROCEDURE add_product_fact_table(IN product_id INT, IN in_paper INT, IN product_type VARCHAR(15))
BEGIN
	INSERT INTO FactTable(id, in_paper_id, product_type_id) VALUES (product_id, in_paper, product_type);
    DECLARE amount INT;
    SELECT max_amount INTO amount FROM ProductTypeTable
    WHERE product_type = ProductTypeTable.product_type_id;
END &&
DELIMITER ;

#-----------------------------------------------------------
### add location into product after calculation / when user finish scanning 
### Deprecated
DELIMITER &&
DROP PROCEDURE IF EXISTS add_location_product;
CREATE PROCEDURE add_location_product(IN product_id INT, IN location INT)
BEGIN
    UPDATE LocationTable SET bin_status = 'occu' WHERE location = LocationTable.id;
	UPDATE FactTable SET location_id = location WHERE product_id = FactTable.id;
END &&
DELIMITER ;

#----------------------------------------------------------
### After scanning, add product to fact table and increase value in InProductTable, used when user scan 1 product
DELIMITER &&
DROP PROCEDURE IF EXISTS add_in_scanned_product;
CREATE PROCEDURE add_in_scanned_product(IN product_id INT, IN product_type VARCHAR(15), IN in_paper INT)
BEGIN
	# Create in fact table
    DECLARE temp_amount INT;
    SELECT max_amount INTO temp_amount FROM ProductTypeTable WHERE ProductTypeTable.id = product_type;
    INSERT INTO FactTable(id, in_paper_id, amount, changed_amount,product_type_id) VALUES (product_id, in_paper, temp_amount, temp_amount, product_type);
	# Update InProductTable
    SELECT scan_number INTO temp_amount FROM InProductTable
    WHERE in_paper = InProductTable.paper_id AND product_type = InProductTable.id;
    SET temp_amount = temp_amount + 1;
    UPDATE InProductTable SET scan_number = temp_amount
    WHERE in_paper = InProductTable.paper_id AND product_type = InProductTable.id;
END &&
DELIMITER ;


#----------------------------------------------------------
### Delete scan product /when user delete scan product. This can be only delete when user hasnt submited. This means that the location
### hasnt been updated yet
DELIMITER &&
DROP PROCEDURE IF EXISTS delete_in_scanned_product;
CREATE PROCEDURE delete_in_scanned_product(IN product_id INT, IN product_type VARCHAR(15), IN in_paper INT)
BEGIN
	DECLARE temp_amount INT;
	#Delete from fact table
    DELETE FROM FactTable WHERE FactTable.id = product_id;
    #Update from InProductTable (decrease by 1)
    SELECT scan_number INTO temp_amount FROM InProductTable
    WHERE product_type = InProductTable.id AND in_paper = InProductTable.paper_id;
    SET temp_amount = temp_amount - 1;
    UPDATE InProductTable SET scan_number = temp_amount
    WHERE product_type = InProductTable.id AND in_paper = InProductTable.paper_id;
END &&
DELIMITER ;

#------------------------------------------------------
#### Choosing location for each type of product
#### this also updates status of location to 'occu'
DELIMITER &&
DROP PROCEDURE IF EXISTS assign_location_in_product;
CREATE PROCEDURE assign_location_in_product(IN product_id INT)
BEGIN
	DECLARE product_class CHAR(1);
    DECLARE id_location INT;
    
    SELECT pareto_type INTO product_class FROM ProductTypeTable
    JOIN FactTable
    ON ProductTypeTable.id = FactTable.product_type_id
    WHERE product_id = FactTable.id;
    
    SELECT LocationTable.id INTO id_location FROM LocationTable
    WHERE LocationTable.class_type = product_class AND LocationTable.bin_status = 'free'
    ORDER BY priority DESC, id ASC LIMIT 1;
    
    UPDATE LocationTable SET bin_status = 'occu' WHERE id = id_location;
    UPDATE FactTable SET FactTable.location_id = id_location WHERE FactTable.id = product_id;
    UPDATE FactTable SET FactTable.old_location = id_location WHERE FactTable.id = product_id;
    
    SELECT id FROM LocationTable WHERE id = id_location;
END &&
DELIMITER ;
#------------------------------------------------
##### After finishing put product into place, workers press submit =>update location to occu
#### Deprecated function => not used
DELIMITER &&
DROP PROCEDURE IF EXISTS finish_storage_location;
CREATE PROCEDURE finish_storage_location(IN id_location INT)
BEGIN
	UPDATE LocationTable SET bin_status = 'occu' WHERE id = id_location;
END &&
DELIMITER ;