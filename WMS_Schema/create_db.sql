CREATE DATABASE wms_db;
USE wms_db;
#--------------------------------------
#### Create Table
#DROP TABLE UserTable;
#CREATE TABLE UserTable (
#	username VARCHAR(50) NOT NULL PRIMARY KEY,
#    pass VARCHAR(50) NOT NULL,
#    auth CHAR(5) NOT NULL DEFAULT 'users'
#    #auth has 2 values: admin or user
#);

CREATE TABLE LocationTable (
	id INT auto_increment PRIMARY KEY, 
    building CHAR(1) NOT NULL,			#'I' or 'J' or 'K'
    building_floor INT NOT NULL,
    room INT NOT NULL,
    rack INT NOT NULL,
    rack_bin INT NOT NULL,
    bin_status CHAR(4) DEFAULT 'free',
    #bin_status has 2 values: 'free' or 'occu'
    priority INT,				#0: lowest priority, highest priority
    class_type CHAR(1) DEFAULT 'C'		#use for class type: A or B or C
);

CREATE TABLE ProductTypeTable (
	no_id INT AUTO_INCREMENT PRIMARY KEY,
	id VARCHAR(15) NOT NULL UNIQUE,
    cur_name VARCHAR(100) NOT NULL UNIQUE,
    max_amount INT NOT NULL,
    pareto_type CHAR(1) DEFAULT 'C'					#this type includes 3 value: A, B or C
);

CREATE TABLE ProductTypeAnalysis (
	id VARCHAR(15) NOT NULL UNIQUE,
    previous_time TIMESTAMP DEFAULT NOW(),
    previous_amount INT DEFAULT 0,
    current_amount INT DEFAULT 0,
    current_sale INT DEFAULT 0,
	turn_over FLOAT DEFAULT 0,
    FOREIGN KEY(id) REFERENCES ProductTypeTable(id)
);

CREATE TABLE InPaperTable (
	id INT auto_increment PRIMARY KEY,
    supplier VARCHAR(100),
    #receive_staff VARCHAR(50) NOT NULL DEFAULT '',
    created_at TIMESTAMP DEFAULT NOW(),
	cur_status CHAR(1) NOT NULL DEFAULT 'p',
    paper_desc VARCHAR(100) NOT NULL DEFAULT ''
    #cur_status has 2 values: 'p' = pending or 'c' = complete
);

CREATE TABLE InProductTable (
	id VARCHAR(15) NOT NULL,
    box_amount INT NOT NULL,
    scan_number INT DEFAULT 0,
    paper_id INT NOT NULL,
    FOREIGN KEY (paper_id) REFERENCES InPaperTable(id),
    FOREIGN KEY (id) REFERENCES ProductTypeTable(id),
    PRIMARY KEY(id, paper_id)
);

CREATE TABLE OutPaperTable (
	id INT auto_increment PRIMARY KEY,
	buyer VARCHAR(100),
    created_at TIMESTAMP DEFAULT NOW(),
    cur_status CHAR(1) NOT NULL DEFAULT 'p',
    paper_desc VARCHAR(100) NOT NULL DEFAULT ''
);

CREATE TABLE TotalOutProductTable (
	id VARCHAR(15) NOT NULL,
    paper_id INT NOT NULL,
    amount INT NOT NULL,
    selected_amount INT DEFAULT 0,
    FOREIGN KEY (id) REFERENCES ProductTypeTable(id),
    FOREIGN KEY (paper_id) REFERENCES OutPaperTable(id),
    PRIMARY KEY (id, paper_id)
);
#DROP TABLE FactTable;
CREATE TABLE FactTable(
	id INT PRIMARY KEY,
    in_paper_id INT NOT NULL,
    amount INT NOT NULL,
    location_id INT DEFAULT NULL,
    product_type_id VARCHAR(15) NOT NULL,
    old_location INT DEFAULT NULL,
    FOREIGN KEY (in_paper_id) REFERENCES InPaperTable(id),
    FOREIGN KEY (location_id) REFERENCES LocationTable(id),
    FOREIGN KEY (product_type_id) REFERENCES ProductTypeTable(id),
    FOREIGN KEY (old_location) REFERENCES LocationTable(id)
);
#DROP TABLE SingleOutProductTable;
CREATE TABLE SingleOutProductTable (
	id INT NOT NULL,
    amount INT NOT NULL,
    selected_amount INT DEFAULT 0,
    paper_id INT NOT NULL,
    cur_status CHAR(1) DEFAULT 'p',
    FOREIGN KEY (id) REFERENCES FactTable(id),
    FOREIGN KEY (paper_id) REFERENCES OutPaperTable(id),
    PRIMARY KEY (id, paper_id)
);

CREATE TABLE id_barcode (
	id INT auto_increment PRIMARY KEY,
    product_type_id VARCHAR(15),
    paper_id INT NOT NULL,
    FOREIGN KEY (product_type_id) references ProductTypeTable(id)
);

CREATE TABLE InventoryCheckingPaperTable (
	id INT auto_increment PRIMARY KEY,
    created_at TIMESTAMP DEFAULT NOW(),
    first_location INT,
    last_location INT,
    cur_status CHAR(1) DEFAULT 'p',
    paper_desc VARCHAR(100) DEFAULT '',
    in_status INT DEFAULT 0,
    out_status INT DEFAULT 0,
    FOREIGN KEY (first_location) REFERENCES LocationTable(id),
    FOREIGN KEY (last_location) REFERENCES LocationTable(id)
);

CREATE TABLE InventoryCheckingProductTable (
	id INT,
    paper_id INT,
    sys_amount INT DEFAULT 0,
    real_amount INT DEFAULT 0,
    mis_amount INT DEFAULT 0,
    product_dir CHAR(1) DEFAULT 'i',            #i: in, o: out
    cur_status CHAR(1) DEFAULT 'p',				## p - pending, c - complete and correct,  or m - complete but missing
    FOREIGN KEY(id) references FactTable(id),
    FOREIGN KEY (paper_id) REFERENCES InventoryCheckingPaperTable(id)
);

DROP TABLE id_barcode;

DROP TABLE InventoryCheckingProductTable;
DROP TABLE InventoryCheckingPaperTable;

DROP TABLE SingleOutProductTable;
DROP TABLE FactTable;
DROP TABLE TotalOutProductTable;
DROP TABLE OutPaperTable;
DROP TABLE InProductTable;
DROP TABLE InPaperTable;
DROP TABLE ProductTypeAnalysis;
DROP TABLE ProductTypeTable;
DROP TABLE LocationTable;

UPDATE LocationTable SET bin_status = 'free' WHERE bin_status != 'free';

####-----------------------------------
## Function to create barcode for product
DELIMITER &&
DROP PROCEDURE IF EXISTS add_bar_code;
CREATE PROCEDURE add_bar_code(IN typeID VARCHAR(15), IN paper INT, IN amount INT)
BEGIN 
	loop_label: LOOP
		IF amount = 0 THEN
			LEAVE loop_label;
		END IF;
        
        INSERT INTO id_barcode(product_type_id, paper_id) VALUES (typeID, paper);
		SET amount = amount - 1;
        ITERATE loop_label;
	END LOOP;
END &&
DELIMITER ;