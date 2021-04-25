## Searching
CALL show_total_product_warehouse;

CALL show_product_according_name('Bích nối ống phun PPR DN 110 PN20');
CALL show_products_according_location(1, 1, 4);
CALL show_products_building_floor(1,1);

CALL search_product_location('Bích nối ống phun PPR DN 110 PN20');

CALL search_in_product_with_last_date('2021-03-18');
CALL search_out_product_with_first_date('2021-03-21');
SELECT * FROM LocationTable;