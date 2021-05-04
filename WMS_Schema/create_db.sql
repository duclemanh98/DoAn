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
    building INT NOT NULL,
    building_floor INT NOT NULL,
    room INT NOT NULL,
    rack INT NOT NULL,
    rack_bin INT NOT NULL,
    bin_status CHAR(4) DEFAULT 'free',
    #bin_status has 2 values: 'free' or 'occu'
    priority INT				#0: lowest priority, highest priority
);

CREATE TABLE ProductTypeTable (
	no_id INT AUTO_INCREMENT PRIMARY KEY,
	id VARCHAR(15) NOT NULL UNIQUE,
    cur_name VARCHAR(100) NOT NULL,
    max_amount INT NOT NULL,
    turn_over FLOAT DEFAULT 0,
    pareto_type CHAR(1) DEFAULT 'C'					#this type includes 3 value: A, B or C
);

CREATE TABLE InPaperTable (
	id INT auto_increment PRIMARY KEY,
    supplier VARCHAR(100),
    created_at TIMESTAMP DEFAULT NOW(),
	cur_status CHAR(1) NOT NULL DEFAULT 'p'
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
    cur_status CHAR(1) NOT NULL DEFAULT 'p'
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
    FOREIGN KEY (in_paper_id) REFERENCES InPaperTable(id),
    FOREIGN KEY (location_id) REFERENCES LocationTable(id),
    FOREIGN KEY (product_type_id) REFERENCES ProductTypeTable(id)
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
DROP TABLE ProductTypeTable;
DROP TABLE SingleOutProductTable;
DROP TABLE FactTable;
DROP TABLE TotalOutProductTable;
DROP TABLE OutPaperTable;
DROP TABLE InProductTable;
DROP TABLE InPaperTable;