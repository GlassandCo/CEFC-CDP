-- ==========================================================================
-- Created by: Yolinda Moodley
-- Create date: 22/08/2018
-- Description:	Create stored procedure to get the relevant commitment amounts based on Aggregation File Date split by Technology
-- ==========================================================================

CREATE or alter  procedure [core].Aggregation_Data_Technology @file_date datetime
as 

	declare @local_date datetime
	--declare @t_file_date nvarchar(20)
  

	select @local_date =  DBO.FN_LOCALDATE (GETDATE());

	--select @t_file_date = EOMONTH(case when len(@file_date) = 6 then '01-'+@file_date else @file_date end); 

	with temp
	as 
	    (
		select	max(prjd.Update_From_TS) b_Update_From_TS,
		max(prjd.Update_to_TS) b_Update_To_TS,
		max(td.Update_From_TS) Update_From_TS_td ,
        max(td.Update_to_TS) Update_To_TS_td ,
	    max(tm.Update_From_TS) Update_From_TS_tm ,
        max(tm.Update_to_TS) Update_To_TS_tm ,
	    prjd.ID_Project,
		prjd.Project_Name,
		prjd.Description,
		prjd.rpt_Project_Description,
		prjd.Project_Borrower_Entity,
		prjd.cOrganisations,
		sum(Amt_CEFC) as Amt_CEFC,
		td.cTechnology,
	    td.Tec_Technology,
	    td.Percent_of_Project_Amt as tech_Percent_of_Project_Amt,
	    td.Percent_of_Project_tCO2_savings as tech_Percent_of_Project_tCO2_savings,
	    td.Percent_renewable_calc,
	    tm.Renewable
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
					where EOMONTH(@file_date) >= convert(datetime,b.Update_From_TS) 
					and EOMONTH(@file_date) <= convert(datetime,isnull(b.Update_to_TS,@local_date))
					and a.File_Date = @file_date 
					group by a.ID_Project,
							 b.Project_Name  ) pd2
				on pd.Project_Name like pd2.Project_Name+'%'
				where EOMONTH(@file_date) >= convert(datetime,pd.Update_From_TS) 
				and EOMONTH(@file_date) <= convert(datetime,isnull(pd.Update_to_TS,@local_date))
				group by pd.ID_Project,
						 pd.Project_Name) pd1
			on bdf.ID_Project = pd1.ID_Project
			where EOMONTH(@file_date) >= convert(datetime,bdf.Update_From_TS) 
			and EOMONTH(@file_date) <= convert(datetime,isnull(bdf.Update_to_TS,@local_date))
			group by case when charindex('II',pd1.Project_Name) > 0 then substring(pd1.Project_name,1,(charindex('II',pd1.Project_Name)-2)) else pd1.Project_Name end       
			) as camt
		on prjd.Project_Name = camt.Project_Name
		left join core.Technology_Dimension td
	    on prjd.ID_Project = td.ID_Project
        left join core.TechMatrix_Dimension tm
	    on td.ID_Technology = tm.ID_Technology
		where EOMONTH(@file_date) >= convert(datetime,prjd.Update_From_TS) 
		and EOMONTH(@file_date) <= convert(datetime,isnull(prjd.Update_to_TS,@local_date))
		and EOMONTH(@file_date) >= convert(datetime,td.Update_From_TS)
		and EOMONTH(@file_date) <= convert(datetime,isnull(td.Update_to_TS,@local_date))
		and EOMONTH(@file_date) >= convert(datetime,tm.Update_From_TS)
		and EOMONTH(@file_date) <= convert(datetime,isnull(tm.Update_to_TS,@local_date))
		group by prjd.ID_Project,
				prjd.Project_Name,
				prjd.Description,
				prjd.rpt_Project_Description,
				prjd.Project_Borrower_Entity,
				prjd.cOrganisations,
				td.cTechnology,
				td.Tec_Technology,
				td.Percent_of_Project_Amt ,
				td.Percent_of_Project_tCO2_savings ,
				td.Percent_renewable_calc,
				tm.Renewable
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
      ,af.[File_Date]
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
	  ,t.Amt_CEFC*tech_Percent_of_Project_Amt as Amt_CEFC
	  ,t.Project_Name
	  ,t.cOrganisations
	  ,t.Description as Project_Descriptiom
	  ,t.rpt_Project_Description
	  ,t.Project_Borrower_Entity
	  ,t.cTechnology
	  ,t.Tec_Technology
	  ,t.tech_Percent_of_Project_Amt 
	  ,t.tech_Percent_of_Project_tCO2_savings
	  ,t.Percent_renewable_calc
	  ,t.Renewable
	  
	from core.Aggregation_Fact af
	left join [core].[Assets_Dimension] asd
	  on af.ID_Project = asd.ID_Project
	  and af.Contract_Number = asd.Contract_Number
	  and af.Asset_Number = asd.Asset_Number
	  and af.File_Date = asd.FileDate
	left join core.ANZSIC_Dimension ad
	  on af.ID_Project = ad.ID_Project
	  and af.ANZSIC_Code = ad.Code
    left join temp t
	  on af.ID_Project = t.ID_Project    

	where convert(datetime,af.File_Date) = @file_date
	and EOMONTH(@file_date) >= convert(datetime,isnull(ad.Update_From_TS,@file_date))
	and EOMONTH(@file_date) <= convert(datetime,isnull(ad.Update_to_TS,@local_date))
	
GO

