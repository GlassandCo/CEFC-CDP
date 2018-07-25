create table staging.ContractSummary_Flynn
(
[Lease Id] nvarchar(20),
[Vehicle Id] nvarchar(20),
[Registration] nvarchar(20),
[Finance Company] nvarchar(50),
[Bond Code] nvarchar(20),
[Customer Code (Level 1)] nvarchar(20),
[Lease Type] nvarchar(20),
[Lease Type Description] nvarchar(20),
[Vehicle Group] nvarchar(20),
[Vehicle Category] nvarchar(70),
[New/Used] nvarchar(20),
[CO2 Rating] nvarchar(70),
[Make] nvarchar(70),
[Model] nvarchar(70),
[Derivative] nvarchar(100),
[Activation Date] nvarchar(20),
[Start Date] nvarchar(20),
[End Date] nvarchar(20),
[Term] nvarchar(3),
[Init Funded Cap] nvarchar(15),
[Current Value] nvarchar(15),
[WDV as at previous waterfall month end pool cut] nvarchar(15),
[GST on IFC] nvarchar(15),
[Total Init Funded Cap] nvarchar(15),
[Final Funded Cap] nvarchar(15),
[Base Rate Code] nvarchar(20),
[Lease BRFM1 funder margin] nvarchar(5),
[Refinance ?] nvarchar(1),
[State] nvarchar(20),
[Post code] nvarchar(10),
[Before discount margin] nvarchar(5),
[FileDate] nvarchar(20)
)

