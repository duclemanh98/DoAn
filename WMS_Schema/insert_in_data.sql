###### SQL query procedure for insert data in to in paper

#----------------------------------------------------------
DELIMITER &&
DROP PROCEDURE IF EXISTS create_in_paper_with_date;
CREATE PROCEDURE create_in_paper_with_date(IN supply VARCHAR(100), IN create_time DATE)
BEGIN
	INSERT INTO InPaperTable(supplier, created_at) VALUES (supply, create_time);
END &&
DELIMITER ;

#----------------------------------------------------------
DELIMITER &&
DROP PROCEDURE IF EXISTS create_in_paper_wo_date;
CREATE PROCEDURE create_in_paper_wo_date(IN supply VARCHAR(100))
BEGIN
	INSERT INTO InPaperTable(supplier) VALUES (supply);
END &&
DELIMITER ;

#----------------------------------------------------------
### Insert 1 product type into in paper/use for admin when creating in paper
DELIMITER &&
DROP PROCEDURE IF EXISTS add_product_in_paper;
CREATE PROCEDURE add_product_in_paper(IN paper INT, IN product_type VARCHAR(15), IN amount INT)
BEGIN
	INSERT INTO InProductTable(id, paper_id, box_amount) VALUES (product_type, paper, amount);
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
CREATE PROCEDURE complete_in_paper(IN paper INT)
BEGIN
	DECLARE total_box INT;
    DECLARE scan_box INT;
    DECLARE location_null_count INT;
    
    SELECT SUM(box_amount) INTO total_box FROM InProductTable
    WHERE paper = InProductTable.paper_id;
    
    SELECT SUM(scan_number) INTO scan_box FROM InProductTable
    WHERE paper = InProductTable.paper_id;
    
    SELECT COUNT(*) INTO location_null_count FROM FactTable
    WHERE FactTable.in_paper_id = paper AND FactTable.location_id = NULL;
    
	IF total_box = scan_box AND location_null_count = 0 THEN
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
### insert product into fact table (used with increase_in_scan_product) ### Deprecated
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
### add location into product after calculation / when user finish scanning ### Deprecated
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
    INSERT INTO FactTable(id, in_paper_id, amount, product_type_id) VALUES (product_id, in_paper, temp_amount, product_type);
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