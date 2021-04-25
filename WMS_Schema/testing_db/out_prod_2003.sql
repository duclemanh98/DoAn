CALL create_out_paper_with_date('Cty TNHH lắp đặt ống nước', '2021-03-20');

CALL add_product_type_out_paper(1, 'RL40', 280);
CALL add_product_type_out_paper(1, 'RT110', 12);
CALL add_product_type_out_paper(1, 'RNC3220X', 1740);
CALL add_product_type_out_paper(1, 'RUZRN20', 200);
CALL add_product_type_out_paper(1, 'RTRT20', 1060);

CALL add_single_out_product(127,80,1,'RL40');
CALL add_single_out_product(128,80,1,'RL40');
CALL add_single_out_product(129,80,1,'RL40');
CALL add_single_out_product(130,40,1,'RL40');
CALL add_single_out_product(89,6,1,'RT110');
CALL add_single_out_product(90,6,1,'RT110');
CALL add_single_out_product(448,360,1,'RNC3220X');
CALL add_single_out_product(449,360,1,'RNC3220X');
CALL add_single_out_product(450,360,1,'RNC3220X');
CALL add_single_out_product(451,360,1,'RNC3220X');
CALL add_single_out_product(452,300,1,'RNC3220X');
CALL add_single_out_product(338,90,1,'RUZRN20');
CALL add_single_out_product(339,90,1,'RUZRN20');
CALL add_single_out_product(340,20,1,'RUZRN20');
CALL add_single_out_product(420,120,1,'RTRT20');
CALL add_single_out_product(421,120,1,'RTRT20');
CALL add_single_out_product(422,120,1,'RTRT20');
CALL add_single_out_product(423,120,1,'RTRT20');
CALL add_single_out_product(424,120,1,'RTRT20');
CALL add_single_out_product(425,120,1,'RTRT20');
CALL add_single_out_product(426,120,1,'RTRT20');
CALL add_single_out_product(427,120,1,'RTRT20');
CALL add_single_out_product(428,100,1,'RTRT20');

CALL scan_out_product(127,80,1,'RL40');
### test
#call scan_out_product(127, 10, 1, 'RL40');
#call scan_out_product(127, 20, 1, 'RL40');
#call scan_out_product(127, 50, 1, 'RL40');
####

CALL scan_out_product(128,80,1,'RL40');

CALL scan_out_product(129,80,1,'RL40');
CALL scan_out_product(130,40,1,'RL40');
CALL scan_out_product(89,6,1,'RT110');
CALL scan_out_product(90,6,1,'RT110');
CALL scan_out_product(448,360,1,'RNC3220X');
CALL scan_out_product(449,360,1,'RNC3220X');
CALL scan_out_product(450,360,1,'RNC3220X');
CALL scan_out_product(451,360,1,'RNC3220X');
CALL scan_out_product(452,300,1,'RNC3220X');
CALL scan_out_product(338,90,1,'RUZRN20');
CALL scan_out_product(339,90,1,'RUZRN20');
CALL scan_out_product(340,20,1,'RUZRN20');
CALL scan_out_product(420,120,1,'RTRT20');
CALL scan_out_product(421,120,1,'RTRT20');
CALL scan_out_product(422,120,1,'RTRT20');
CALL scan_out_product(423,120,1,'RTRT20');
CALL scan_out_product(424,120,1,'RTRT20');
CALL scan_out_product(425,120,1,'RTRT20');
CALL scan_out_product(426,120,1,'RTRT20');
CALL scan_out_product(427,120,1,'RTRT20');
CALL scan_out_product(428,100,1,'RTRT20');


CALL complete_out_paper(1);

#DELETE FROM TotalOutProductTable;
#DELETE FROM SingleOutProductTable;


#SELECT * FROM FactTable WHERE id = 129;
SELECT * FROM OutPaperTable;
SELECT * FROM TotalOutProductTable;
SELECT * FROM SingleOutProductTable;
SELECT * FROM FactTable WHERE amount = 0;
SELECT * FROM LocationTable WHERE bin_status = 'free';