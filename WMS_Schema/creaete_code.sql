SELECT * FROM InProductTable ORDER BY paper_id;
SELECT * FROM FactTable;
SELECT * FROM LocationTable WHERE bin_status != 'free';

SELECT * FROM id_barcode;

INSERT INTO id_barcode(product_type_id,paper_id)
VALUES ('RB110',1), ('RB110',1),('RV40',1);


#####------------------------------------------
##### run these 3 below command to reset database
UPDATE LocationTable SET bin_status = 'free' WHERE bin_status != 'free';
UPDATE InProductTable SET scan_number = 0;
DELETE FROM FactTable;


