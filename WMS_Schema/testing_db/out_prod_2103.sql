CALL create_out_paper_with_date('Cty TNHH Hari', '2021-03-21');

CALL add_product_type_out_paper(2, 'RLRT25', 350);
CALL add_product_type_out_paper(2, 'RL40', 380);
CALL add_product_type_out_paper(2, 'RV32', 192);
CALL add_product_type_out_paper(2, 'RTRT20', 300);

CALL add_single_out_product(668,100,2,'RLRT25');
CALL add_single_out_product(669,100,2,'RLRT25');
CALL add_single_out_product(670,100,2,'RLRT25');
CALL add_single_out_product(671,50,2,'RLRT25');
CALL add_single_out_product(130,40,2,'RL40');
CALL add_single_out_product(131,80,2,'RL40');
CALL add_single_out_product(132,80,2,'RL40');
CALL add_single_out_product(133,80,2,'RL40');
CALL add_single_out_product(134,80,2,'RL40');
CALL add_single_out_product(135,20,2,'RL40');
CALL add_single_out_product(846,36,2,'RV32');
CALL add_single_out_product(847,36,2,'RV32');
CALL add_single_out_product(848,36,2,'RV32');
CALL add_single_out_product(849,36,2,'RV32');
CALL add_single_out_product(850,36,2,'RV32');
CALL add_single_out_product(851,12,2,'RV32');
CALL add_single_out_product(428,20,2,'RTRT20');
CALL add_single_out_product(429,120,2,'RTRT20');
CALL add_single_out_product(430,120,2,'RTRT20');
CALL add_single_out_product(431,40,2,'RTRT20');

CALL scan_out_product(668,100,2,'RLRT25');
CALL scan_out_product(669,100,2,'RLRT25');
CALL scan_out_product(670,100,2,'RLRT25');
CALL scan_out_product(671,50,2,'RLRT25');
CALL scan_out_product(130,40,2,'RL40');

CALL scan_out_product(131,80,2,'RL40');
CALL scan_out_product(132,80,2,'RL40');
CALL scan_out_product(133,80,2,'RL40');
CALL scan_out_product(134,80,2,'RL40');
CALL scan_out_product(135,20,2,'RL40');
CALL scan_out_product(846,36,2,'RV32');
CALL scan_out_product(847,36,2,'RV32');
CALL scan_out_product(848,36,2,'RV32');
CALL scan_out_product(849,36,2,'RV32');
CALL scan_out_product(850,36,2,'RV32');
CALL scan_out_product(851,12,2,'RV32');
CALL scan_out_product(428,20,2,'RTRT20');
CALL scan_out_product(429,120,2,'RTRT20');
CALL scan_out_product(430,120,2,'RTRT20');
CALL scan_out_product(431,40,2,'RTRT20');

CALL complete_out_paper(2);

SELECT * FROM singleoutproducttable;


