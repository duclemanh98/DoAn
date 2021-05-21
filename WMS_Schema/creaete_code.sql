SELECT * FROM InProductTable ORDER BY paper_id;
SELECT * FROM FactTable;
SELECT * FROM LocationTable WHERE bin_status != 'free';

SELECT * FROM id_barcode;

CALL add_bar_code('RB110', 1, 5);
CALL add_bar_code('RDB75', 1, 3);

SELECT * FROM ProductTypeTable WHERE id = 'RB110' OR id = 'RDB75';
#####------------------------------------------
##### run these 3 below command to reset database
UPDATE LocationTable SET bin_status = 'free' WHERE bin_status != 'free';
UPDATE InProductTable SET scan_number = 0;
DELETE FROM FactTable;

#### Add product:
CALL create_in_paper_wo_date('Xưởng A');
CALL add_product_in_paper(1, 'Bích nối ống phun PPR DN 110 PN20', 5);
CALL add_product_in_paper(1, 'Đầu bịt phun PPR DN 75 PN20', 3);

CALL add_in_scanned_product(1, 'RB110', 1);
CALL add_in_scanned_product(2, 'RB110', 1);
CALL add_in_scanned_product(3, 'RB110', 1);
CALL add_in_scanned_product(4, 'RB110', 1);
CALL add_in_scanned_product(5, 'RB110', 1);

CALL add_in_scanned_product(6, 'RDB75', 1);
CALL add_in_scanned_product(7, 'RDB75', 1);
CALL add_in_scanned_product(8, 'RDB75', 1);

CALL assign_location_in_product(1);
CALL assign_location_in_product(2);
CALL assign_location_in_product(3);
CALL assign_location_in_product(4);
CALL assign_location_in_product(5);
CALL assign_location_in_product(6);
CALL assign_location_in_product(7);
CALL assign_location_in_product(8);

CALL complete_in_paper(1);
CALL show_total_product_warehouse();

CALL create_out_paper_wo_date('Khách hàng A');

CALL add_product_type_out_paper(1, 'RB110', 30);
CALL add_product_type_out_paper(1, 'RDB75', 60);

SELECT * FROM id_barcode;
#### Create barcode
CALL add_bar_code('RDKTC9020', 2, 3);
CALL add_bar_code('RV40', 2, 5);
CALL add_bar_code('RZC2510', 2, 4);

CALL add_bar_code('RB110', 3, 3);
CALL add_bar_code('RDKTC9040', 3, 4);
CALL add_bar_code('RVC32', 3, 5);

