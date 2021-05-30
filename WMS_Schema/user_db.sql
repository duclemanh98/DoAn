#### Pre - create database and table
#drop database new_db;
### Create and use database, uncomment and replace ... with name of database
#CREATE DATABASE wms_db ;
#USE wms_db;

### Create Table to store user name and pass word

DROP TABLE IF EXISTS UserTable;
CREATE TABLE UserTable (
	username VARCHAR(50) NOT NULL PRIMARY KEY,
    pass VARCHAR(50) NOT NULL,
    auth VARCHAR(5) NOT NULL DEFAULT 'users'
    #auth has 2 values: admin or user
);

SELECT * FROM UserTable;

###### Procedure to Deal with all action related to users

#-------------------------------------
DELIMITER &&
DROP PROCEDURE IF EXISTS add_user;
CREATE PROCEDURE add_user(IN in_username VARCHAR(50), IN in_pass VARCHAR(50), IN in_auth CHAR(5))
BEGIN
	INSERT INTO UserTable(username, pass, auth) VALUES (in_username, in_pass, in_auth);
END &&
DELIMITER ;
#----------
#---------------------------
DELIMITER &&
DROP PROCEDURE IF EXISTS delete_user;
CREATE PROCEDURE delete_user(IN in_username VARCHAR(50), IN in_pass VARCHAR(50))
BEGIN
	DELETE FROM UserTable WHERE UserTable.username = in_username AND UserTable.pass = in_pass;
END &&
DELIMITER ;
#-----------
#-------------------------
DELIMITER &&
DROP PROCEDURE IF EXISTS change_pass;
CREATE PROCEDURE change_pass(IN in_username VARCHAR(50), IN new_pass VARCHAR(50))
BEGIN
	UPDATE UserTable SET pass = new_pass WHERE username = in_username AND pass = new_pass;
END &&
DELIMITER ;
#----------
#--------------------------
DELIMITER &&
DROP PROCEDURE IF EXISTS check_login;
CREATE PROCEDURE check_login(IN in_username VARCHAR(50), IN in_pass VARCHAR(50), OUT checking_val TINYINT)
BEGIN
	SELECT COUNT(*) INTO checking_val FROM UserTable
    WHERE in_username = UserTable.username AND in_pass = UserTable.pass;
END &&
DELIMITER ;
#-----------------
#--------------
## Update user to admin
DELIMITER &&
DROP PROCEDURE IF EXISTS updateUserRole;
CREATE PROCEDURE updateUserRole(IN user_name VARCHAR(50))
BEGIN
	UPDATE UserTable SET auth = 'Admin' WHERE username = user_name;
END &&
DELIMITER ;

### END OF FILE ###
SELECT * FROM UserTable;

CALL updateUserRole('LeTao');