SELECT * FROM FactTable;
SELECT * FROM InPaperTable;
SELECT * FROM InProductTable;
SELECT * FROM OutPaperTable;
SELECT * FROM TotalOutProductTable;
SELECT * FROM SingleOutProductTable;
SELECT * FROM UserTable;
SELECT * FROM LocationTable;
SELECT * FROM ProductTypeTable;

#### Delete data from table
DELETE FROM InProductTable;
DELETE FROM InPaperTable WHERE id > 1;

#-------------------------------
### use these command to clear value from LocationTable
UPDATE LocationTable SET bin_status = 'free';
SELECT max_amount FROM ProductTypeTable WHERE cur_name = 'RB1110';