SELECT * FROM LocationTable;

UPDATE LocationTable SET class_type = 'A'
WHERE building = 'I' AND building_floor = 1;

UPDATE LocationTable SET class_type = 'B'
WHERE building = 'I' AND building_floor = 2;

UPDATE LocationTable SET class_type = 'B'
WHERE building = 'K' AND building_floor = 1;

UPDATE LocationTable SET priority = 6
WHERE building = 'I' AND building_floor = 1;

UPDATE LocationTable SET priority = 4
WHERE building = 'K' AND building_floor = 1;

UPDATE LocationTable SET priority = 3
WHERE building = 'I' AND building_floor = 2;

UPDATE LocationTable SET priority = 2
WHERE building = 'K' AND building_floor = 2;

UPDATE LocationTable SET priority = 1
WHERE building_floor = 3;