/****** Object:  StoredProcedure [core].[Aggregation_Report]    Script Date: 23/08/2018 1:23:03 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ==========================================================================
-- Created by: Yolinda Moodley
-- Create date: 22/08/2018
-- Description:	Create stored procedure to get the relevant commitment amounts based on Aggregation File Date 
-- ==========================================================================

CREATE OR ALTER procedure [core].[Aggregation_Report] @file_date datetime
as 

	declare @local_date datetime

	declare @t_file_date datetime

  	select @local_date =  DBO.FN_LOCALDATE (GETDATE());

	select @t_file_date = case when @file_date = 'Mar  1 2018 12:00AM' then 'Apr  1 2018 12:00AM' else @file_date end; 

	with temp
	as 
	    (
		select	max(prjd.Update_From_TS) b_Update_From_TS,
		max(prjd.Update_to_TS) b_Update_To_TS,
		prjd.ID_Project,
		prjd.Project_Name,
		prjd.Description,
		prjd.rpt_Project_Description,
		prjd.Project_Borrower_Entity,
		prjd.cOrganisations,
		sum(Amt_CEFC) as Amt_CEFC,
		prjd.ID_Project_TNumber
		from core.Projects_Dimension prjd
		join 
		(select max(bdf.Update_From_TS) b_Update_From_TS,
				max(bdf.Update_to_TS) b_Update_To_TS,
			    sum(bdf.Amt_cCEFC) as Amt_CEFC,
				case when charindex('II',pd1.Project_Name) > 0 then substring(pd1.Project_name,1,(charindex('II',pd1.Project_Name)-2)) else pd1.Project_Name end  as Project_Name     
		 from core.Base_Data_Fact bdf
			join 
			(
			select	 max(pd.Update_From_TS) a_Update_From_TS,
					 max(pd.Update_to_TS) a_Update_To_TS,
					 pd.ID_Project,
					 pd.Project_Name
			from core.Projects_Dimension pd
				join 
					(select max(a.Update_From_TS) a_Update_From_TS,
							max(a.Update_to_TS) a_Update_To_TS,
							max(b.Update_From_TS) b_Update_From_TS,
							max(b.Update_to_TS) b_Update_To_TS,
							a.ID_Project,
							b.Project_Name
					from core.Aggregation_Fact a
					join core.Projects_Dimension b
					  on a.ID_Project = b.ID_Project
					where EOMONTH(convert(datetime,@t_file_date)) >= convert(datetime,b.Update_From_TS) 
					and EOMONTH(convert(datetime,@t_file_date)) <= convert(datetime,isnull(b.Update_to_TS,@local_date))
					--and a.File_Date = @file_date 
					group by a.ID_Project,
							 b.Project_Name  ) pd2
				on pd.Project_Name like pd2.Project_Name+'%'
				where EOMONTH(convert(datetime,@t_file_date)) >= convert(datetime,pd.Update_From_TS) 
				and EOMONTH(convert(datetime,@t_file_date)) <= convert(datetime,isnull(pd.Update_to_TS,@local_date))
				group by pd.ID_Project,
						 pd.Project_Name) pd1
			on bdf.ID_Project = pd1.ID_Project
			where EOMONTH(convert(datetime,@t_file_date)) >= convert(datetime,bdf.Update_From_TS) 
			and EOMONTH(convert(datetime,@t_file_date)) <= convert(datetime,isnull(bdf.Update_to_TS,@local_date))
			group by case when charindex('II',pd1.Project_Name) > 0 then substring(pd1.Project_name,1,(charindex('II',pd1.Project_Name)-2)) else pd1.Project_Name end       
			) as camt
		on prjd.Project_Name = camt.Project_Name
		where EOMONTH(convert(datetime,@t_file_date)) >= convert(datetime,prjd.Update_From_TS) 
		and EOMONTH(convert(datetime,@t_file_date)) <= convert(datetime,isnull(prjd.Update_to_TS,@local_date))
		group by prjd.ID_Project,
				prjd.Project_Name,
				prjd.Description,
				prjd.rpt_Project_Description,
				prjd.Project_Borrower_Entity,
				prjd.cOrganisations,
				prjd.ID_Project_TNumber
		) 

		
		select af.[ID_Project]
			  ,af.[Contract_Number]
			  ,af.[Asset_Number]
			  ,af.[ANZSIC_Code]
			  ,af.[Balloon_Amount]
			  ,af.[Brand]
			  ,af.[CEFC_Rebate_Monthly]
			  ,af.[Contract_Start_Date]
			  ,af.[Discounted_Interest_Rate]
			  ,af.[Funder_Margin]
			  ,af.[Maturity_Date]
			  ,af.[Postcode]
			  ,af.[Principal_Outstanding]
			  ,af.[Product_Type]
			  ,af.[Repayment_Frequency]
			  ,af.[State]
			  ,af.[Term]
			  ,af.[Termination_Date]
			  ,af.[Total_Amount_Financed]
			  ,af.[Total_Rebate_to_date_exclGST]
			  ,af.[Total_Rebate_to_date_inclGST]
			  ,asd.[Category]
			  ,asd.[Description] as Asset_Description
			  ,asd.[Variant]
			  ,asd.[Make]
			  ,asd.[Model]
			  ,asd.[Year]
			  ,asd.[Status]
			  ,ad.[Code]
			  ,ad.[Division]
			  ,ad.[Subdivision]
			  ,ad.[Description] as ANZSIC_Description
			  ,ad.ABS_Division
			  ,ad.ABS_Subdivision
			  ,t.Amt_CEFC
			  ,t.Project_Name
			  ,t.cOrganisations
			  ,t.Description as Project_Description
			  ,t.rpt_Project_Description
			  ,t.Project_Borrower_Entity
			  ,t.ID_Project_TNumber
			  ,b.state as postcode_state
			  ,b.suburb
			  ,b.dc
			  ,b.type as postcode_type
			  ,b.latitude
			  ,b.longitude
			  ,c.Electoral_division as Electorate
			  ,c.[Percent] as Electorate_perc
			    
		from core.Aggregation_Fact af
		join (select  max(convert(datetime,af1.File_Date)) as Agg_FileDate
				,af1.[ID_Project]   	    	  
				from core.Aggregation_Fact af1
				where convert(datetime,af1.file_date) <= eomonth(format(@file_date,'yyyy-MM-dd'))   
				group by af1.[ID_Project]) max_dates 
		 on af.File_Date = max_dates.Agg_FileDate
			and af.ID_Project = max_dates.ID_Project
		left join [core].[Assets_Dimension] asd
		 on af.ID_Project = asd.ID_Project
		    and af.Contract_Number = asd.Contract_Number
		    and case when af.Asset_Number = 'Not Available' then asd.Asset_Number end = asd.Asset_Number
		    and convert(datetime,af.File_Date) = convert(datetime,asd.FileDate)
		left join core.ANZSIC_Dimension ad
		 on af.ID_Project = ad.ID_Project
		    and af.ANZSIC_Code = ad.Code
		left join temp t
		 on af.ID_Project = t.ID_Project
		left join core.Post_Codes b
		 on (case when substring(af.Postcode,1,1) = '0' then substring(af.Postcode,2,len(af.Postcode)-1) else af.Postcode end) = b.postcode
		left join core.Post_Codes_Electorate c
		on b.postcode = c.Postcode  
   where (af.ID_Project = 'S2537'
   and asd.Description in ('Solar Energy Battery','Solar Energy Equipment','Solar Energy Panels','Solar Water Heater')) or
   af.ID_Project != 'S2537'
	
GO


