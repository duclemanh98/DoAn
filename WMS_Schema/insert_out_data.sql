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
DELIMITER &&
DROP PROCEDURE IF EXISTS check_amount_out_product;
CREATE PROCEDURE check_amount_out_product(IN product_type VARCHAR(15), IN selected_amount INT, OUT check_val TINYINT)
BEGIN
	DECLARE warehouse_amount INT;
    SELECT SUM(amount) INTO warehouse_amount FROM FactTable
    WHERE product_type = FactTable.product_type_id
    GROUP BY product_type_id;
    
    IF warehouse_amount < selected_amount THEN
		SET check_val = 0;
	ELSE
		SET check_val = 1;
	END IF;
END &&
DELIMITER ;

#------------------------------------------
### Insert 1 product type (total) into out paper / admin uses when creating paper
DELIMITER &&
DROP PROCEDURE IF EXISTS add_product_type_out_paper;
CREATE PROCEDURE add_product_type_out_paper(IN paper INT, IN product_type VARCHAR(15), IN out_amount INT)
BEGIN
	###Variable storing temp amount of current product
	DECLARE temp_amount INT;			#store amount of current product
    DECLARE saved_amount INT;			#store amount of current selected product
    DECLARE saved_id INT DEFAULT 0;		#store id of current selected product
    DECLARE select_location INT;		#store location
    
    ###Update TotalOutProductTable
	INSERT INTO TotalOutProductTable(id, paper_id, amount) VALUES (product_type, paper, out_amount);
    SET temp_amount = out_amount;
    
    ###Update SingleOutProductTable
    SingleProdUpdate: LOOP
		SELECT FactTable.id, FactTable.amount, FactTable.location_id INTO saved_id, saved_amount, select_location FROM FactTable
        JOIN LocationTable ON FactTable.location_id = LocationTable.id
        WHERE product_type = FactTable.product_type_id AND FactTable.id > saved_id 
        AND FactTable.amount > 0 AND LocationTable.bin_status = 'occu'
        ORDER BY in_paper_id ASC LIMIT 1;
        
        ### Update Location Table to prevent users from taking another product from current location
        UPDATE LocationTable SET bin_status = 'temp' WHERE LocationTable.id = select_location;
        
        IF temp_amount > saved_amount THEN
			INSERT INTO SingleOutProductTable(id, amount, paper_id) VALUES (saved_id, saved_amount, paper);
            SET temp_amount = temp_amount - saved_amount;
		ELSE 
			INSERT INTO SingleOutProductTable(id, amount, paper_id) VALUES (saved_id, temp_amount, paper);
            SET temp_amount = 0;
		END IF;
       
        IF temp_amount > 0 THEN
			ITERATE SingleProdUpdate;
		END IF;
		LEAVE SingleProdUpdate;
	END LOOP SingleProdUpdate;
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
### Deprecated
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
### Scan in 1 out Product / use when user actually scan out 1 product from paper
DELIMITER &&
DROP PROCEDURE IF EXISTS scan_out_product;
CREATE PROCEDURE scan_out_product(IN product_id INT, IN select_amount INT, IN out_paper INT, IN product_type VARCHAR(15))
BEGIN
    DECLARE temp_amount INT;
    DECLARE total_amount INT;
    DECLARE location INT;
    DECLARE check_status CHAR(1);
    ###check if product has been completed before or not
    SELECT cur_status INTO check_status FROM SingleOutProductTable
    WHERE product_id = SingleOutProductTable.id AND out_paper = SingleOutProductTable.paper_id;
    
    IF check_status = 'p' THEN
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
		SELECT location_id INTO location FROM FactTable WHERE FactTable.id = product_id;
    
		#### Update amount from FactTable and bin_status from temp to free or occu
		IF temp_amount = 0 THEN
			UPDATE LocationTable SET bin_status = 'free' WHERE LocationTable.id = location;
			UPDATE FactTable SET location_id = NULL WHERE FactTable.id = product_id;
			UPDATE FactTable SET amount = 0 WHERE FactTable.id = product_id;
		ELSE
			UPDATE FactTable SET amount = temp_amount WHERE FactTable.id = product_id;
			UPDATE LocationTable SET bin_status = 'occu' WHERE LocationTable.id = location;
		END IF;
	END IF;
END &&
DELIMITER ;
#--------------------------------
#### Procedure to check if current location have enough products
DELIMITER &&
DROP PROCEDURE IF EXISTS check_location_product_amount;
CREATE PROCEDURE check_location_product_amount(IN product_id INT, IN selected_amount INT, OUT check_val TINYINT)
BEGIN
	DECLARE current_amount INT;
    SELECT amount INTO current_amount FROM FactTable WHERE FactTable.id = product_id;
    IF current_amount < selected_amount THEN
		SET check_val = 0;
	ELSE
		SET check_val = 1;
	END IF;
END &&
DELIMITER ;
