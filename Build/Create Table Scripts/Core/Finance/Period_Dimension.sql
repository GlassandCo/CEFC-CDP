create table core.Period_Dimension
(
	Period numeric(3),
	Description nvarchar(20),
	PRIMARY KEY (Period)
)

insert into core.Period_Dimension (Period,Description)
values 
(0,'Brought Forward'),
( 1,'July'),
(2,'August'),
(3,'September'),
(4,'October'),
(5,'November'),
(6,'December'),
(7,'January'),
(8,'February'),
(9,'March'),
(10,'April'),
(11,'May'),
(12,'June')
