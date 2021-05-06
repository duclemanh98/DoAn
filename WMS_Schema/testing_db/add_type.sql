insert into ProductTypeTable(id, cur_name, max_amount, pareto_type)
values
('RB110','Bích nối ống phun PPR DN 110 PN20',20,'C'),
('RB125','Bích nối ống phun PPR DN 125 PN20',10,'B'),
('RB14016','Bích nối ống phun PPR DN 140 PN16',10,'B'),
('RB50','Bích nối ống phun PPR DN 50 PN20',60,'B'),
('RB63','Bích nối ống phun PPR DN 63 PN20',50,'B'),
('RB75','Bích nối ống phun PPR DN 75 PN20',50,'C'),
('RB90','Bích nối ống phun PPR DN 90 PN20',30,'C'),
('RDB110','Đầu bịt phun PPR DN 110 PN20',20,'A'),
('RDB20','Đầu bịt phun PPR DN 20 PN20',1200,'A'),
('RDB25','Đầu bịt phun PPR DN 25 PN20',720,'C'),
('RDB32','Đầu bịt phun PPR DN 32 PN20',400,'C'),
('RDB40','Đầu bịt phun PPR DN 40 PN20',300,'B'),
('RDB50','Đầu bịt phun PPR DN 50 PN20',120,'B'),
('RDB63','Đầu bịt phun PPR DN 63 PN20',100,'C'),
('RDB75','Đầu bịt phun PPR DN 75 PN20',50,'B'),
('RDB90','Đầu bịt phun PPR DN 90 PN20',30,'C'),
('RDKTC11050','Đai khởi thủy hàn cắm phun PPR DN 110-50 PN20',100,'C'),
('RDKTC4020','Đai khởi thủy hàn cắm phun PPR DN 40- 20 PN20',800,'A'),
('RDKTC5020','Đai khởi thủy hàn cắm phun PPR DN 50- 20 PN20',800,'C'),
('RDKTC5025','Đai khởi thủy hàn cắm phun PPR DN 50- 25 PN20',640,'C'),
('RDKTC6320','Đai khởi thủy hàn cắm phun PPR DN 63- 20 PN20',800,'C'),
('RDKTC6325','Đai khởi thủy hàn cắm phun PPR DN 63- 25 PN20',640,'C'),
('RDKTC6332','Đai khởi thủy hàn cắm phun PPR DN 63- 32 PN20',300,'A'),
('RDKTC7525','Đai khởi thủy hàn cắm phun PPR DN 75- 25 PN20',600,'C'),
('RDKTC7532','Đai khởi thủy hàn cắm phun PPR DN 75- 32 PN20',300,'B'),
('RDKTC7540','Đai khởi thủy hàn cắm phun PPR DN 75- 40 PN20',180,'C'),
('RDKTC9020','Đai khởi thủy hàn cắm phun PPR DN 90- 20 PN20',800,'C'),
('RDKTC9025','Đai khởi thủy hàn cắm phun PPR DN 90- 25 PN20',600,'A'),
('RDKTC9040','Đai khởi thủy hàn cắm phun PPR DN 90- 40 PN20',180,'B'),
('ROT20','ống tránh PPR DN 20 PN20',210,'A'),
('ROT25','ống tránh PPR DN 25 PN20',120,'C'),
('RV20','Van chặn phun PPR DN 20',60,'B'),
('RV25','Van chặn phun PPR DN 25',60,'B'),
('RV32','Van chặn phun PPR DN 32',36,'C'),
('RV40','Van chặn phun PPR DN 40',20,'C'),
('RV50','Van chặn phun PPR DN 50',20,'A'),
('RVC20','Van cửa phun PPR DN 20',60,'C'),
('RVC25','Van cửa phun PPR DN 25',40,'C'),
('RVC32','Van cửa phun PPR DN 32',30,'B'),
('RVC40','Van cửa phun PPR DN 40',12,'C'),
('RVC50','Van cửa phun PPR DN 50',12,'B'),
('RVC63','Van cửa phun PPR DN 63',8,'C'),
('RZC2010','Zắc co phun PPR DN 20 PN10',100,'C'),
('RZC2510','Zắc co phun PPR DN 25 PN10',150,'A'),
('RZC3210','Zắc co phun PPR DN 32 PN10',60,'B'),
('RZC408','Zắc co phun PPR DN 40 PN8',40,'C'),
('RZC506','Zắc co phun PPR DN 50 PN6',30,'C'),
('RZC636','Zắc co phun PPR DN 63 PN6',18,'A'),
('RZRN20','Zắcco ren ngoài phun PPR DN 20-1/2 PN20',90,'B'),
('RZRN25','Zắcco ren ngoài phun PPR DN 25-3/4 PN20',30,'A');

insert into ProductTypeAnalysis(id)
values
('RB110'),
('RB125'),
('RB14016'),
('RB50'),
('RB63'),
('RB75'),
('RB90'),
('RDB110'),
('RDB20'),
('RDB25'),
('RDB32'),
('RDB40'),
('RDB50'),
('RDB63'),
('RDB75'),
('RDB90'),
('RDKTC11050'),
('RDKTC4020'),
('RDKTC5020'),
('RDKTC5025'),
('RDKTC6320'),
('RDKTC6325'),
('RDKTC6332'),
('RDKTC7525'),
('RDKTC7532'),
('RDKTC7540'),
('RDKTC9020'),
('RDKTC9025'),
('RDKTC9040'),
('ROT20'),
('ROT25'),
('RV20'),
('RV25'),
('RV32'),
('RV40'),
('RV50'),
('RVC20'),
('RVC25'),
('RVC32'),
('RVC40'),
('RVC50'),
('RVC63'),
('RZC2010'),
('RZC2510'),
('RZC3210'),
('RZC408'),
('RZC506'),
('RZC636'),
('RZRN20'),
('RZRN25');


SELECT * FROM ProductTypeAnalysis;

#---------------------------------------------
#### This is used to update the product analysis and type after every 3 months
DELIMITER &&
DROP PROCEDURE IF EXISTS update_product_analysis;
CREATE PROCEDURE update_product_analysis()
BEGIN
	UPDATE ProductTypeTable SET turn_over = (
		SELECT 
    )
END &&
DELIMITER ;
#---------------------------------------------