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
DELETE FROM InPaperTable;

#-------------------------------
### use these command to clear value from LocationTable
UPDATE LocationTable SET bin_status = 'free';