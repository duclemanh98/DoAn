##### query for searching in paper

#### These procedures are used for searching total paper
#-------------------------------------------------
### Show all in paper
DELIMITER &&
DROP PROCEDURE IF EXISTS show_all_in_paper;
CREATE PROCEDURE show_all_in_paper()
BEGIN
	SELECT id, supplier, CAST(created_at AS DATE) AS 'date', cur_status  FROM InPaperTable;
END &&
DELIMITER ;

#------------------------------------------------
### Search in paper before first_date
DELIMITER &&
DROP PROCEDURE IF EXISTS search_in_paper_first_date;
CREATE PROCEDURE search_in_paper_first_date(IN first_date DATE)
BEGIN
	SELECT * FROM InPaperTable
    WHERE CAST(created_at AS DATE) >= CAST(first_date AS DATE);
END &&
DELIMITER ;
#------------------------------------------------
### Search in paper after last_date
DELIMITER &&
DROP PROCEDURE IF EXISTS search_in_paper_last_date;
CREATE PROCEDURE search_in_paper_last_date(IN last_date DATE)
BEGIN
	SELECT * FROM InPaperTable
    WHERE CAST(created_at AS DATE) <= CAST(last_date AS DATE);
END &&
DELIMITER ;
#------------------------------------------------
### Search in paper with keyword
DELIMITER &&
DROP PROCEDURE IF EXISTS search_in_paper_keyword;
CREATE PROCEDURE search_in_paper_keyword(IN keyword VARCHAR(100))
BEGIN
	SELECT * FROM InPaperTable
    WHERE supplier LIKE CONCAT("%", keyword, "%");
END &&
DELIMITER ;
#------------------------------------------------
### Search with 2 dates
DELIMITER &&
DROP PROCEDURE IF EXISTS search_in_paper_dates;
CREATE PROCEDURE search_in_paper_dates(IN first_date DATE, IN last_date DATE)
BEGIN
	SELECT * FROM InPaperTable
    WHERE CAST(created_at AS DATE) BETWEEN first_date AND last_date;
END &&
DELIMITER ;
#------------------------------------------------
### Search with first_date and keyword
DELIMITER &&
DROP PROCEDURE IF EXISTS search_in_paper_first_date_keyword;
CREATE PROCEDURE search_in_paper_first_date_keyword(IN first_date DATE, IN keyword VARCHAR(100))
BEGIN
	SELECT * FROM InPaperTable
    WHERE CAST(created_at AS DATE) >= first_date AND supplier LIKE CONCAT("%", keyword, "%");
END &&
DELIMITER ;
#------------------------------------------------
### Search with last_date and keyword
DELIMITER &&
DROP PROCEDURE IF EXISTS search_in_paper_last_date_keyword;
CREATE PROCEDURE search_in_paper_last_date_keyword(IN last_date DATE, IN keyword VARCHAR(100))
BEGIN
	SELECT * FROM InPaperTable
    WHERE CAST(created_at AS DATE) <= last_date AND supplier LIKE CONCAT("%", keyword, "%");
END &&
DELIMITER ;
#------------------------------------------------
### Search with all 3
DELIMITER &&
DROP PROCEDURE IF EXISTS search_in_paper_dates_keyword;
CREATE PROCEDURE search_in_paper_dates_keyword(IN first_date DATE, IN last_date DATE, IN keyword VARCHAR(100))
BEGIN
	SELECT * FROM InPaperTable
    WHERE CAST(created_at AS DATE) BETWEEN first_date AND last_date
    AND supplier LIKE CONCAT("%", keyword, "%");
END &&
DELIMITER ;

#------------------------------------------------
### Show detail of in paper with paper id - used when select specific table
DELIMITER &&
DROP PROCEDURE IF EXISTS in_paper_detail;
CREATE PROCEDURE in_paper_detail(IN in_paper_id INT)
BEGIN
	SELECT ProductTypeTable.id, cur_name, max_amount AS perbox, box_amount, scan_number
    FROM ProductTypeTable
    JOIN InProductTable
		ON InProductTable.id = ProductTypeTable.id
    WHERE InProductTable.paper_id = in_paper_id;
END &&
DELIMITER ;

#-----------------------------------------------
### Use to show detail about paper - used after select specific paper
DELIMITER &&
DROP PROCEDURE IF EXISTS in_paper_info;
CREATE PROCEDURE in_paper_info(IN in_paper_id INT)
BEGIN
	SELECT * FROM InPaperTable WHERE id = in_paper_id;
END &&
DELIMITER ;