##### SQL Query for insert data into out paper

DELIMITER &&
DROP PROCEDURE IF EXISTS create_out_paper_with_date;
CREATE PROCEDURE create_out_paper_with_date(IN buy VARCHAR(100), IN create_time TIMESTAMP)
BEGIN
	INSERT INTO OutPaperTable(buyer, created_at) VALUES (buy, create_time);
END &&
DELIMITER ;
#------------------------------------------

DELIMITER &&
DROP PROCEDURE IF EXISTS create_out_paper_wo_date;
CREATE PROCEDURE create_out_paper_wo_date(IN buy VARCHAR(100))
BEGIN
	INSERT INTO OutPaperTable(buyer) VALUES (buy);
END &&
DELIMITER ;
#------------------------------------------
### Insert 1 product type (total) into out paper / admin uses when creating paper
DELIMITER &&
DROP PROCEDURE IF EXISTS add_product_type_out_paper;
CREATE PROCEDURE add_product_type_out_paper(IN paper INT, IN product_type VARCHAR(15), IN amount INT)
BEGIN
	INSERT INTO TotalOutProductTable(id, paper_id, amount) VALUES (product_type, paper, amount);
END &&
DELIMITER ;
#----------------------------------------------------------
### Delete product from in paper / used by admin
DELIMITER &&
DROP PROCEDURE IF EXISTS delete_product_out_paper;
CREATE PROCEDURE delete_product_out_paper(IN paper INT, IN product_type VARCHAR(15))
BEGIN
	DELETE FROM TotalOutProductTable WHERE TotalOutProductTable.id = product_type AND TotalOutProductTable.paper = paper_id;
END &&
DELIMITER ;
#----------------------------------------------------------
### update status of out paper / when user submit paper
DELIMITER &&
DROP PROCEDURE IF EXISTS complete_out_paper;
CREATE PROCEDURE complete_out_paper(IN paper INT)
BEGIN
	DECLARE total_count INT;
    DECLARE complete_count INT;
    
    SELECT COUNT(*) INTO total_count FROM SingleOutProductTable
    WHERE paper = SingleOutProductTable.paper_id;
    
    SELECT COUNT(cur_status) INTO complete_count FROM SingleOutProductTable
    WHERE paper = SingleOutProductTable.paper_id AND SingleOutProductTable.cur_status = 'c';
    
	IF complete_count = total_count THEN
		UPDATE OutPaperTable SET cur_status = 'c' WHERE paper = OutPaperTable.id;
	ELSE
		UPDATE OutPaperTable SET cur_status = 'p' WHERE paper = OutPaperTable.id;
	END IF;
END &&
DELIMITER ;
#---------------------------------------------------------
### Add product from location into SingleOutProduct / use after calculate the requested product an location for worker
DELIMITER &&
DROP PROCEDURE IF EXISTS add_single_out_product;
CREATE PROCEDURE add_single_out_product(IN location INT, IN amount INT, IN paper INT, IN product_type VARCHAR(15))
BEGIN
	DECLARE temp INT;
    SELECT id INTO temp FROM FactTable
    WHERE location = FactTable.location_id;
    
    INSERT INTO SingleOutProductTable(id, amount, paper_id) VALUES (temp, amount, paper);
    
    # update TotalOutProductTable    
    #SELECT select_amount INTO temp FROM TotalOutProductTable
    #WHERE product_type = TotalOutProductTable.id AND paper = TotalOutProductTable.paper_id;
    #SET temp = temp + amount;
    #UPDATE TotalOutProductTable SET selected_amount = temp
    #WHERE product_type = TotalOutProductTable.id AND paper = TotalOutProductTable.paper_id;
END &&
DELIMITER ;
#---------------------------------------------------------
### Scan in 1 out Product / use when user actually scan out 1 paper from paper
DELIMITER &&
DROP PROCEDURE IF EXISTS scan_out_product;
CREATE PROCEDURE scan_out_product(IN product_id INT, IN select_amount INT, IN out_paper INT, IN product_type VARCHAR(15))
BEGIN
    DECLARE temp_amount INT;
    DECLARE total_amount INT;
    DECLARE location INT;
    
    # update SingleOutProductTable
    SELECT amount INTO total_amount FROM SingleOutProductTable 
    WHERE SingleOutProductTable.id = product_id AND SingleOutProductTable.paper_id = out_paper;
    SELECT selected_amount INTO temp_amount FROM SingleOutProductTable 
    WHERE SingleOutProductTable.id = product_id AND SingleOutProductTable.paper_id = out_paper;

    SET temp_amount = temp_amount + select_amount;
    UPDATE SingleOutProductTable SET selected_amount = temp_amount 
    WHERE SingleOutProductTable.id = product_id AND SingleOutProductTable.paper_id = out_paper;
    
    IF temp_amount = total_amount THEN
		UPDATE SingleOutProductTable SET cur_status = 'c' 
        WHERE SingleOutProductTable.id = product_id AND SingleOutProductTable.paper_id = out_paper;
	ELSE
		UPDATE SingleOutProductTable SET cur_status = 'p' 
        WHERE SingleOutProductTable.id = product_id AND SingleOutProductTable.paper_id = out_paper;
    END IF;
    
    # update TotalOutProductTable
    SELECT selected_amount INTO temp_amount FROM TotalOutProductTable
    WHERE TotalOutProductTable.id = product_type AND TotalOutProductTable.paper_id = out_paper;
    SET temp_amount = temp_amount + select_amount;
    UPDATE TotalOutProductTable SET selected_amount = temp_amount
    WHERE TotalOutProductTable.id = product_type AND TotalOutProductTable.paper_id = out_paper;
 
    # update FactTable and LocationTable
    SELECT amount INTO temp_amount FROM FactTable
    WHERE FactTable.id = product_id;
    SET temp_amount = temp_amount - select_amount;
    
    IF temp_amount = 0 THEN
        SELECT location_id INTO location FROM FactTable WHERE FactTable.id = product_id;
        UPDATE LocationTable SET bin_status = 'free' WHERE LocationTable.id = location;
        UPDATE FactTable SET location_id = NULL WHERE FactTable.id = product_id;
        UPDATE FactTable SET amount = 0 WHERE FactTable.id = product_id;
	ELSE
		UPDATE FactTable SET amount = temp_amount WHERE FactTable.id = product_id;
	END IF;
END &&
DELIMITER ;
#---------------
