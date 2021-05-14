##########--------------------------------############
#### Searching product insde the warehouse
##########--------------------------------############

#---------------------------------------
### Show total product in warehouse
DELIMITER &&
DROP PROCEDURE IF EXISTS show_total_product_warehouse;
CREATE PROCEDURE show_total_product_warehouse()
BEGIN
	SELECT FactTable.product_type_id, ProductTypeTable.cur_name, SUM(FactTable.amount) AS total_amount
    FROM FactTable
	JOIN ProductTypeTable
		ON FactTable.product_type_id = ProductTypeTable.id
	GROUP BY FactTable.product_type_id;
END &&
DELIMITER ;
#---------------------------------------
### Searching total of each product in warehouse
DELIMITER &&
DROP PROCEDURE IF EXISTS show_product_according_name;
CREATE PROCEDURE show_product_according_name (IN product_name VARCHAR(100))
BEGIN
	SELECT FactTable.product_type_id, ProductTypeTable.cur_name, SUM(FactTable.amount) AS total_amount
    FROM FactTable
	JOIN ProductTypeTable
		ON FactTable.product_type_id = ProductTypeTable.id
	WHERE product_name = ProductTypeTable.cur_name
	GROUP BY FactTable.product_type_id;
END &&
DELIMITER ;

##### Used for searching product in zone
#----------------------------------------
### Searching product according to location
DELIMITER &&
DROP PROCEDURE IF EXISTS show_products_according_location;
CREATE PROCEDURE show_products_according_location (IN sel_building INT, IN sel_floor INT, IN sel_room INT)
BEGIN
	SELECT FactTable.product_type_id, ProductTypeTable.cur_name, SUM(amount) AS total_amount
    FROM FactTable
	JOIN ProductTypeTable
		ON FactTable.product_type_id = ProductTypeTable.id
	JOIN LocationTable
		ON FactTable.location_id = LocationTable.id
	WHERE LocationTable.building = sel_building AND LocationTable.building_floor = sel_floor AND LocationTable.room = sel_room
    GROUP BY FactTable.product_type_id;
END &&
DELIMITER ;
#----------------------------------------
### Searching product in building and floor
DELIMITER &&
DROP PROCEDURE IF EXISTS show_products_building_floor;
CREATE PROCEDURE show_products_building_floor (IN sel_building INT, IN sel_floor INT)
BEGIN
	SELECT FactTable.product_type_id, ProductTypeTable.cur_name, SUM(amount) AS total_amount
    FROM FactTable
	JOIN ProductTypeTable
		ON FactTable.product_type_id = ProductTypeTable.id
	JOIN LocationTable
		ON FactTable.location_id = LocationTable.id
	WHERE LocationTable.building = sel_building AND LocationTable.building_floor = sel_floor
    GROUP BY FactTable.product_type_id;
END &&
DELIMITER ;
#----------------------------------------
### Searching product in building
DELIMITER &&
DROP PROCEDURE IF EXISTS show_products_building;
CREATE PROCEDURE show_products_building(IN sel_building INT)
BEGIN
	SELECT FactTable.product_type_id, ProductTypeTable.cur_name, SUM(amount) AS total_amount
    FROM FactTable
	JOIN ProductTypeTable
		ON FactTable.product_type_id = ProductTypeTable.id
	JOIN LocationTable
		ON FactTable.location_id = LocationTable.id
	WHERE LocationTable.building = sel_building
    GROUP BY FactTable.product_type_id;
END &&
DELIMITER ;
#----------------------------------------
###Searching location of each product
DELIMITER &&
DROP PROCEDURE IF EXISTS search_product_location;
CREATE PROCEDURE search_product_location(IN product_name VARCHAR(100))
BEGIN
	SELECT building, building_floor AS 'floor', room, rack, storage_bin, FactTable.amount
    FROM FactTable
    JOIN LocationTable
		ON FactTable.location_id = LocationTable.id
	JOIN ProductTypeTable
		ON FactTable.product_type_id = ProductTypeTable.id
	WHERE ProductTypeTable.cur_name = product_name;
END &&
DELIMITER ;

##########--------------------------------############
#### Searching product in and out of warehouse
##########--------------------------------############
#---------------------------------------
#### Searching product in with first_date
DELIMITER &&
DROP PROCEDURE IF EXISTS search_in_product_with_first_date;
CREATE PROCEDURE search_in_product_with_first_date(IN first_date DATE)
BEGIN
	SELECT InProductTable.id, ProductTypeTable.cur_name, max_amount AS perbox, SUM(box_amount) AS total_box
    FROM InProductTable
    JOIN InPaperTable
		ON InProductTable.paper_id = InPaperTable.id
	JOIN ProductTypeTable
		ON InProductTable.id = ProductTypeTable.id
	WHERE CAST(InPaperTable.created_at AS DATE) >= first_date
    GROUP BY InProductTable.id;
END &&
DELIMITER ;
#---------------------------------------
#### Searching product in with last_date
DELIMITER &&
DROP PROCEDURE IF EXISTS search_in_product_with_last_date;
CREATE PROCEDURE search_in_product_with_last_date(IN last_date DATE)
BEGIN
	SELECT InProductTable.id, ProductTypeTable.cur_name, max_amount AS perbox, SUM(box_amount) AS total_box
    FROM InProductTable
    JOIN InPaperTable
		ON InProductTable.paper_id = InPaperTable.id
	JOIN ProductTypeTable
		ON InProductTable.id = ProductTypeTable.id
	WHERE CAST(InPaperTable.created_at AS DATE) <= last_date
    GROUP BY InProductTable.id;
END &&
DELIMITER ;
#---------------------------------------
#### Searching product in with dates
DELIMITER &&
DROP PROCEDURE IF EXISTS search_in_product_with_dates;
CREATE PROCEDURE search_in_product_with_dates(IN first_date DATE, in last_date DATE)
BEGIN
	SELECT InProductTable.id, ProductTypeTable.cur_name, max_amount AS perbox, SUM(box_amount) AS total_box
    FROM InProductTable
    JOIN InPaperTable
		ON InProductTable.paper_id = InPaperTable.id
	JOIN ProductTypeTable
		ON InProductTable.id = ProductTypeTable.id
	WHERE CAST(InPaperTable.created_at AS DATE) BETWEEN first_date AND last_date
    GROUP BY InProductTable.id;
END &&
DELIMITER ;

#---------------------------------------
#### Searching product out with first_date
DELIMITER &&
DROP PROCEDURE IF EXISTS search_out_product_with_first_date;
CREATE PROCEDURE search_out_product_with_first_date(IN first_date DATE)
BEGIN
	SELECT TotalOutProductTable.id, ProductTypeTable.cur_name, SUM(TotalOutProductTable.amount) AS total_amount
    FROM TotalOutProductTable
    JOIN OutPaperTable
		ON TotalOutProductTable.paper_id = OutPaperTable.id
	JOIN ProductTypeTable
		ON TotalOutProductTable.id = ProductTypeTable.id
	WHERE CAST(OutPaperTable.created_at AS DATE) >= first_date
    GROUP BY TotalOutProductTable.id;
END &&
DELIMITER ;
#---------------------------------------
#### Searching product in with last_date
DELIMITER &&
DROP PROCEDURE IF EXISTS search_out_product_with_last_date;
CREATE PROCEDURE search_out_product_with_last_date(IN last_date DATE)
BEGIN
	SELECT TotalOutProductTable.id, ProductTypeTable.cur_name, SUM(TotalOutProductTable.amount) AS total_amount
    FROM TotalOutProductTable
    JOIN OutPaperTable
		ON TotalOutProductTable.paper_id = OutPaperTable.id
	JOIN ProductTypeTable
		ON TotalOutProductTable.id = ProductTypeTable.id
	WHERE CAST(OutPaperTable.created_at AS DATE) <= last_date
    GROUP BY TotalOutProductTable.id;
END &&
DELIMITER ;
#---------------------------------------
#### Searching product in with dates
DELIMITER &&
DROP PROCEDURE IF EXISTS search_out_product_with_dates;
CREATE PROCEDURE search_out_product_with_dates(IN first_date DATE, in last_date DATE)
BEGIN
	SELECT TotalOutProductTable.id, ProductTypeTable.cur_name, SUM(TotalOutProductTable.amount) AS total_amount
    FROM TotalOutProductTable
    JOIN OutPaperTable
		ON TotalOutProductTable.paper_id = OutPaperTable.id
	JOIN ProductTypeTable
		ON TotalOutProductTable.id = ProductTypeTable.id
	WHERE CAST(OutPaperTable.created_at AS DATE) BETWEEN first_date AND last_date
    GROUP BY TotalOutProductTable.id;
END &&
DELIMITER ;
#--------------------------------------
#### Search location according to product_id
DELIMITER &&
DROP PROCEDURE IF EXISTS search_location_with_product_id;
CREATE PROCEDURE search_location_with_product_id(IN product_id INT)
BEGIN
	SELECT * FROM LocationTable WHERE LocationTable.id =
    (
		SELECT location_id FROM FactTable WHERE FactTable.id = product_id
    );
END &&
DELIMITER ;
#--------------------------------------
#### Search product detail according to product_id
DELIMITER &&
DROP PROCEDURE IF EXISTS search_with_product_id;
CREATE PROCEDURE search_with_product_id(IN product_id INT)
BEGIN
	SELECT ProductTypeTable.cur_name, ProductTypeTable.max_amount, LocationTable.id, building, building_floor, room, rack, rack_bin
    FROM FactTable
    JOIN LocationTable ON FactTable.location_id = LocationTable.id
    JOIN ProductTypeTable ON FactTable.product_type_id = ProductTypeTable.id
    WHERE FactTable.id = product_id;
END &&
DELIMITER ;