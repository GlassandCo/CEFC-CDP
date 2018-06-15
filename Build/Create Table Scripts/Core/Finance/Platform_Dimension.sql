CREATE TABLE [core].[Platform_Dimension](
	[Selection_Code] [nvarchar](5) NOT NULL,
	[Description] [nvarchar](70) NULL,
	[Updated_by] [nvarchar](20) NULL,
	[Update_from_TS] [datetime] NOT NULL,
	[Update_to_TS] [datetime] NULL,
	[Update_Reason] [nvarchar](20) NULL,
PRIMARY KEY CLUSTERED 
([Selection_Code] ,[Update_from_TS])
)
GO

ALTER TABLE [core].[Platform_Dimension] ADD  DEFAULT ('SSIS ETL') FOR [Updated_by]
GO

ALTER TABLE [core].[Platform_Dimension] ADD  DEFAULT (NULL) FOR [Update_to_TS]
GO

ALTER TABLE [core].[Platform_Dimension] ADD  DEFAULT ('Population process') FOR [Update_Reason]
GO


