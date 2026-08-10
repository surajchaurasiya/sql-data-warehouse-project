/*
===================================================================
DML script: Truncate & Load the data to silver table from bronze table.
This stored procedure loads data into silver schema from bronze schema.
It truncates the table before loading data from bronze layer.
===================================================================
*/

Create or Alter procedure silver.load_silver as 
Begin
	Declare @start_time datetime, @end_time datetime;
	set @start_time = getdate();
	Begin Try
		print '======= Loading Bronze layer ======';
		Print '------ Loading CRM tables ------';

		set @start_time = getdate();
		print'>> Truncating & Inserting date into table: silver.crm_cust_info';
		Truncate table silver.crm_cust_info
		Insert into silver.crm_cust_info(
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_grnd,
			cst_create_date
		)

		select 
			cst_id,
			cst_key,
			trim(cst_firstname) as cst_firstname,
			trim(cst_lastname) as cst_lastname,
			case when upper(trim(cst_marital_status)) = 'M' then 'Married'
				 when upper(trim(cst_marital_status)) = 'S' then 'Single'
				 else 'n/a'
			end as cst_marital_status, -- Map marital status to descriptive value
			case when upper(trim(cst_grnd)) = 'M' then 'Male'
				 when upper(trim(cst_grnd)) = 'F' then 'Female'
				 else 'n/a'
			end as cst_grnd, -- Map gender to descriptive value
			cst_create_date
		from (
			select *,ROW_NUMBER() over(partition by cst_id order by cst_create_date desc) as flag
			from bronze.crm_cust_info
		)t 
		where flag = 1 and cst_id is not null
		set @end_time = getdate();
		print'>> Load duration:' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' sec';
		print'------------------------------';

		set @start_time = getdate();
		print'>> Truncating & Inserting date into table: silver.crm_prd_info';
		Truncate table silver.crm_prd_info
		Insert into silver.crm_prd_info(
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)

		Select 
			prd_id,
			replace(SUBSTRING(prd_key,1,5),'-','_') as cat_id, -- Extract category id
			SUBSTRING(prd_key,7,len(prd_key)) as prd_key, -- Extract Product key
			prd_nm,
			ISNULL(prd_cost,0) as prd_cost,
			case upper(trim(prd_line))
				 when 'M' then 'Mountain'
				 when 'R' then 'Road'
				 when 'S' then 'Other Sales'
				 when 'T' then 'Touring'
				 else 'n/a'
			end as prd_line, -- Map product line to description value
			cast(prd_start_dt as date) as prd_start_dt,
			cast(
			lead(prd_start_dt) over(partition by prd_key order by prd_start_dt)-1 as date
			) as prd_end_dt -- calculate end date as one day before the next start date
		from bronze.crm_prd_info
		set @end_time = getdate();
		print'>> Load duration:' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' sec';
		print'------------------------------';

		set @start_time = getdate();
		print'>> Truncating & Inserting date into table: silver.crm_sales_details';
		Truncate table silver.crm_sales_details
		Insert into silver.crm_sales_details(
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)

		select 
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			case when sls_order_dt =0 or len(sls_order_dt) != 8 then Null
				 else cast(cast(sls_order_dt as varchar)as date)
				 end as sls_order_dt,
			case when sls_ship_dt =0 or len(sls_ship_dt) != 8 then Null
				 else cast(cast(sls_ship_dt as varchar)as date)
				 end as sls_ship_dt,
			case when sls_due_dt =0 or len(sls_due_dt) != 8 then Null
				 else cast(cast(sls_due_dt as varchar)as date)
				 end as sls_due_dt,
			case when sls_sales is null or sls_sales <=0 or sls_sales != sls_quantity*abs(sls_price) then sls_quantity*abs(sls_price)
				 else sls_sales 
				 end as sls_sales,
			sls_quantity,
			case when sls_price is null or sls_price <=0 then sls_sales/nullif(sls_quantity,0)
				 else sls_price 
				 end as sls_price
		from bronze.crm_sales_details
		set @end_time = getdate();
		print'>> Load duration:' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' sec';
		print'------------------------------';

		set @start_time = getdate();
		Print '------ Loading ERP tables ------';
		print'>> Truncating & Inserting date into table: silver.erp_cust_az12';
		Truncate table silver.erp_cust_az12
		Insert into silver.erp_cust_az12(
			cid,
			bdate,
			gen
		)

		select 
			case when cid like 'NAS%' then SUBSTRING(cid,4,len(cid))
				 else cid
				 end as cid,
			case when bdate > getdate() then null
				 else bdate
				 end as bdate,
			case when upper(trim(gen)) in ('F','FEMALE') then 'Female'
				 when upper(trim(gen)) in ('M','MALE') then 'Male'
				 else 'n/a'
				 end as gen
		from bronze.erp_cust_az12
		set @end_time = getdate();
		print'>> Load duration:' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' sec';
		print'------------------------------';

		set @start_time = getdate();
		print'>> Truncating & Inserting date into table: silver.erp_loc_a101';
		Truncate table silver.erp_loc_a101
		Insert into silver.erp_loc_a101(
			cid,
			cntry
		)

		select 
			REPLACE(cid,'-','') as cid,
			case when trim(cntry) = 'DE' then 'Germany'
				 when trim(cntry) in ('US','USA') then 'United States'
				 when trim(cntry) = '' or cntry is null  then 'n/a'
				 else trim(cntry)
				 end as cntry
		from bronze.erp_loc_a101
		set @end_time = getdate();
		print'>> Load duration:' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' sec';
		print'------------------------------';

		set @start_time = getdate();
		print'>> Truncating & Inserting date into table: silver.erp_px_cat_g1v2';
		Truncate table silver.erp_px_cat_g1v2
		Insert into silver.erp_px_cat_g1v2(
			id,
			cat,
			subcat,
			maintenance
		)

		select
			id,
			cat,
			subcat,
			maintenance
		from bronze.erp_px_cat_g1v2
		set @end_time = getdate();
		print'>> Load duration:' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' sec';
		print'------------------------------';
	End Try
	Begin catch
		Print'====== Error occured loading bronze layer =======';
		print'Error message:'+ cast(error_message() as nvarchar);
		print'Error number:'+ cast(error_number() as nvarchar);
		print'Error state:'+ cast(error_state() as nvarchar);
	End catch
	set @end_time = getdate();
	print'>> Total Load duration:' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' sec';
End
