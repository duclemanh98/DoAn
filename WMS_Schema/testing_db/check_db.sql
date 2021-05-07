SELECT * FROM FactTable;
SELECT * FROM InPaperTable;
SELECT * FROM InProductTable
INNER JOIN ProductTypeTable
ON InProductTable.id = ProductTypeTable.id;
SELECT * FROM OutPaperTable;
SELECT * FROM TotalOutProductTable;
SELECT * FROM SingleOutProductTable;
SELECT * FROM UserTable;
SELECT * FROM LocationTable;
SELECT * FROM ProductTypeTable;

SELECT * FROM LocationTable WHERE bin_status != 'free';

#### Delete data from table
DELETE FROM InProductTable;
DELETE FROM InPaperTable WHERE id > 1;

#-------------------------------
### use these command to clear value from LocationTable
UPDATE LocationTable SET bin_status = 'free';

CALL create_in_paper_wo_date('Kho A');
CALL add_product_in_paper(2, 'Bích nối ống phun PPR DN 125 PN20', 2);
CALL add_in_scanned_product(1, 'RB125', 2);
CALL add_in_scanned_product(2, 'RB125', 2);
##Test
CALL assign_location_in_product(1);
CALL assign_location_in_product(2);
CALL finish_storage_location(3361);
CALL finish_storage_location(3362);
##
CALL complete_in_paper(2);