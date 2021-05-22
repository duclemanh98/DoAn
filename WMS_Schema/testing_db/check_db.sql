SELECT * FROM FactTable;
SELECT * FROM InPaperTable;
SELECT * FROM InProductTable ORDER BY paper_id;
SELECT * FROM OutPaperTable;
SELECT * FROM TotalOutProductTable;
SELECT * FROM SingleOutProductTable;
SELECT * FROM UserTable;
SELECT * FROM LocationTable;
SELECT * FROM ProductTypeTable;
UPDATE inpapertable SET cur_status = 'p' WHERE id = 2;
SELECT * FROM LocationTable WHERE bin_status != 'free';

#### Delete data from table
#DELETE FROM InProductTable;
#DELETE FROM InPaperTable WHERE id > 1;

#-------------------------------
### use these command to clear value from LocationTable
UPDATE LocationTable SET bin_status = 'free' WHERE bin_status != 'free';

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

SELECT * FROM LocationTable WHERE id = 3363;

SELECT * FROM InProductTable WHERE paper_id = 13;

CALL search_location_with_product_id(2);

SELECT * FROM FactTable;
SELECT * FROM ProductTypeTable WHERE id = 'RB14016';
CALL search_with_product_id(4);

CALL create_in_paper_with_date('A','2021-08-09','');


SELECT * FROM OutPaperTable;
SELECT * FROM TotalOutProductTable;
SELECT * FROM SingleOutProductTable;
SELECT * FROM FactTable;
## TEst out product
CALL create_out_paper_wo_date('Buyer A');
CALL add_product_type_out_paper(1, 'RB110', 30);

CALL scan_out_product(2,10,1,'RB110');
SELECT * FROM LocationTable WHERE bin_status != 'free';

CALL complete_out_paper(1);
     
CALL show_total_product_warehouse('Bích nối ống phun PPR DN 110 PN20');
CALL out_paper_detail(4);
CALL show_out_paper_scan_product(4);
CALL show_out_paper_scan_product(1);

CALL scan_out_product(2, 10, 4, 'RB110');
CALL in_paper_detail(1);

CALL search_with_product_id(1);
CALL search_scanned_product(1);

CALL search_scanned_product(1);

CALL show_total_product_warehouse('');

CALL show_products_according_location('I', 1, 1);

SELECT * FROM InventoryCheckingPaperTable;
SELECT * FROM InventoryCheckingProductTable;
