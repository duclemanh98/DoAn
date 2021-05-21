##### query for searching out paper

#### These procedures are used for searching total paper
#-------------------------------------------------
### Show all in paper
DELIMITER &&
DROP PROCEDURE IF EXISTS show_all_out_paper;
CREATE PROCEDURE show_all_out_paper()
BEGIN
	SELECT * FROM OutPaperTable;
END &&
DELIMITER ;
#------------------------------------------------
### Search out paper before first_date
DELIMITER &&
DROP PROCEDURE IF EXISTS search_iout_paper_first_date;
CREATE PROCEDURE search_out_paper_first_date(IN first_date DATE)
BEGIN
	SELECT * FROM OutPaperTable
    WHERE CAST(created_at AS DATE) >= first_date;
END &&
DELIMITER ;
#------------------------------------------------
### Search out paper after last_date
DELIMITER &&
DROP PROCEDURE IF EXISTS search_out_paper_last_date;
CREATE PROCEDURE search_out_paper_last_date(IN last_date DATE)
BEGIN
	SELECT * FROM OutPaperTable
    WHERE CAST(created_at AS DATE) <= last_date;
END &&
DELIMITER ;
#------------------------------------------------
### Search out paper with keyword
DELIMITER &&
DROP PROCEDURE IF EXISTS search_out_paper_keyword;
CREATE PROCEDURE search_out_paper_keyword(IN keyword VARCHAR(100))
BEGIN
	SELECT * FROM outPaperTable
    WHERE buyer LIKE CONCAT("%", keyword, "%");
END &&
DELIMITER ;
#------------------------------------------------
### Search with 2 dates
DELIMITER &&
DROP PROCEDURE IF EXISTS search_out_paper_dates;
CREATE PROCEDURE search_out_paper_dates(IN first_date DATE, IN last_date DATE)
BEGIN
	SELECT * FROM outPaperTable
    WHERE CAST(created_at AS DATE) BETWEEN first_date AND last_date;
END &&
DELIMITER ;
#------------------------------------------------
### Search with first_date and keyword
DELIMITER &&
DROP PROCEDURE IF EXISTS search_out_paper_first_date_keyword;
CREATE PROCEDURE search_out_paper_first_date_keyword(IN first_date DATE, IN keyword VARCHAR(100))
BEGIN
	SELECT * FROM outPaperTable
    WHERE CAST(created_at AS DATE) >= first_date AND buyer LIKE CONCAT("%", keyword, "%");
END &&
DELIMITER ;
#------------------------------------------------
### Search with last_date and keyword
DELIMITER &&
DROP PROCEDURE IF EXISTS search_out_paper_last_date_keyword;
CREATE PROCEDURE search_out_paper_last_date_keyword(IN last_date DATE, IN keyword VARCHAR(100))
BEGIN
	SELECT * FROM outPaperTable
    WHERE CAST(created_at AS DATE) <= last_date AND buyer LIKE CONCAT("%", keyword, "%");
END &&
DELIMITER ;
#------------------------------------------------
### Search with all 3
DELIMITER &&
DROP PROCEDURE IF EXISTS search_out_paper_dates_keyword;
CREATE PROCEDURE search_out_paper_dates_keyword(IN first_date DATE, IN last_date DATE, IN keyword VARCHAR(100))
BEGIN
	SELECT * FROM outPaperTable
    WHERE CAST(created_at AS DATE) BETWEEN first_date AND last_date
    AND buyer LIKE CONCAT("%", keyword, "%");
END &&
DELIMITER ;

#------------------------------------------------
### Show detail of out paper with paper id - used when select specific table
DELIMITER &&
DROP PROCEDURE IF EXISTS out_paper_detail;
CREATE PROCEDURE out_paper_detail(IN in_paper_id INT)
BEGIN
	SELECT ProductTypeTable.id, cur_name, max_amount AS perbox,amount, selected_amount
    FROM ProductTypeTable
    JOIN TotalOutProductTable
		ON TotalOutProductTable.id = ProductTypeTable.id
    WHERE TotalOutProductTable.paper_id = in_paper_id;
END &&
DELIMITER ;

#-----------------------------------------------
### Use to show detail about paper - used after select specific paper
DELIMITER &&
DROP PROCEDURE IF EXISTS out_paper_info;
CREATE PROCEDURE out_paper_info(IN in_paper_id INT)
BEGIN
	SELECT * FROM outPaperTable WHERE id = in_paper_id;
END &&
DELIMITER ;

#-----------------------------------------------
### Use to search scanned product of out product from paperID
DELIMITER &&
DROP PROCEDURE IF EXISTS show_out_paper_scan_product;
CREATE PROCEDURE show_out_paper_scan_product(IN paper INT)
BEGIN
	SELECT FactTable.id AS product_id, FactTable.product_type_id AS type_id, ProductTypeTable.cur_name,
		   ProductTypeTable.max_amount AS perbox,
		   SingleOutProductTable.amount, FactTable.old_location AS location_id, LocationTable.building, LocationTable.building_floor,
           LocationTable.room, LocationTable.rack, LocationTable.rack_bin, SingleOutProductTable.cur_status
    FROM FactTable
    JOIN SingleOutProductTable ON FactTable.id = SingleOutProductTable.id
    JOIN LocationTable ON FactTable.old_location = LocationTable.id
    JOIN ProductTypeTable ON FactTable.product_type_id = ProductTypeTable.id
    WHERE SingleOutProductTable.paper_id = paper
    ORDER BY LocationTable.id;
END &&
DELIMITER ;