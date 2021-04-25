#### Pre - create database and table

### Create and use database, uncomment and replace ... with name of database
# CREATE DATABASE ... ;
# USE ...

### Create Table to store user name and pass word

DROP TABLE UserTable;
CREATE TABLE UserTable (
	username VARCHAR(50) NOT NULL PRIMARY KEY,
    pass VARCHAR(50) NOT NULL,
    auth CHAR(5) NOT NULL DEFAULT 'users'
    #auth has 2 values: admin or user
);

###### Procedure to Deal with all action related to users

#-------------------------------------
DELIMITER &&
DROP PROCEDURE IF EXISTS add_user;
CREATE PROCEDURE add_user(IN in_username VARCHAR(50), IN in_pass VARCHAR(50), IN in_auth CHAR(5))
BEGIN
	INSERT INTO UserTable(username, pass, auth) VALUES (in_username, in_pass, in_auth);
END &&
DELIMITER ;
#-------------------------------------
DELIMITER &&
DROP PROCEDURE IF EXISTS delete_user;
CREATE PROCEDURE delete_user(IN in_username VARCHAR(50), IN in_pass VARCHAR(50))
BEGIN
	DELETE FROM UserTable WHERE UserTable.username = in_username AND UserTable.pass = in_pass;
END &&
DELIMITER ;
#------------------------------------
DELIMITER &&
DROP PROCEDURE IF EXISTS change_pass;
CREATE PROCEDURE change_pass(IN in_username VARCHAR(50), IN new_pass VARCHAR(50))
BEGIN
	UPDATE UserTable SET pass = new_pass WHERE username = in_username AND pass = new_pass;
END &&
DELIMITER ;
#------------------------------------
DELIMITER &&
DROP PROCEDURE IF EXISTS check_login;
CREATE PROCEDURE check_login(IN in_username VARCHAR(50), IN in_pass VARCHAR(50), OUT checking_val TINYINT)
BEGIN
	SELECT COUNT(*) INTO checking_val FROM UserTable
    WHERE in_username = UserTable.username AND in_pass = UserTable.pass;
END &&
DELIMITER ;
#-----------------
### END OF FILE ###
SELECT * FROM UserTable;