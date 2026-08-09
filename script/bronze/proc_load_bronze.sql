/*
===================================================================
DML script: Truncate & Load the data to bronze table from csv file.
This stored procedure loads data into bronze schema from external CSV file.
It truncates the table before loading data.
Uses bulk insert command to load data from csv file to bronze table.
===================================================================
*/

Create or Alter procedure bronze.load_bronze as
Begin
	Declare @start_time datetime, @end_time datetime;
	set @start_time = getdate();
	Begin Try
		print '======= Loading Bronze layer ======';
		Print '------ Loading CRM tables ------';

		set @start_time = getdate();
		Print '>> Truncating & inserting data in table: bronze.crm_cust_info';
		Truncate table bronze.crm_cust_info;
		Bulk Insert bronze.crm_cust_info
		from 'D:\Suraj\Study Material\SQL\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time = getdate();
		print'>> Load duration:' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' sec';
		print'------------------------------';

		set @start_time = getdate();
		Print '>> Truncating & inserting data in table: bronze.crm_prd_info';
		Truncate table bronze.crm_prd_info;
		Bulk Insert bronze.crm_prd_info
		from 'D:\Suraj\Study Material\SQL\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time = getdate();
		print'>> Load duration:' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' sec';
		print'------------------------------';

		set @start_time =  getdate();
		Print '>> Truncating & inserting data in table: bronze.crm_sales_details';
		Truncate table bronze.crm_sales_details;
		Bulk Insert bronze.crm_sales_details
		from 'D:\Suraj\Study Material\SQL\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time = getdate();
		print'>> Load duration:' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' sec';
		print'------------------------------';

		Print '------ Loading ERP tables ------';
		set @start_time =  getdate();
		Print '>> Truncating & inserting data in table: bronze.erp_cust_az12';
		Truncate Table bronze.erp_cust_az12
		Bulk Insert bronze.erp_cust_az12
		from 'D:\Suraj\Study Material\SQL\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time =  getdate();
		print'>> Load duration:' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' sec';
		print'------------------------------';

		set @start_time =  getdate();
		Print '>> Truncating & inserting data in table: bronze.erp_loc_a101';
		Truncate table bronze.erp_loc_a101;
		Bulk Insert bronze.erp_loc_a101
		from 'D:\Suraj\Study Material\SQL\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time =  getdate();
		print'>> Load duration:' + cast(datediff(second,@start_time,@end_time) as nvarchar) + ' sec';
		print'------------------------------';

		set @start_time =  getdate();
		Print '>> Truncating & inserting data in table: bronze.erp_px_cat_g1v2';
		Truncate table bronze.erp_px_cat_g1v2;
		Bulk Insert bronze.erp_px_cat_g1v2
		from 'D:\Suraj\Study Material\SQL\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time =  getdate();
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
