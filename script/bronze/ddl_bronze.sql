/*
================================
DDL Script: Create Bronze Tables
================================
*/

If OBJECT_ID('bronze.crm_cust_info','U') is not Null
drop table bronze.crm_cust_info;
Go

Create Table bronze.crm_cust_info(
	cst_id INT,
	cst_key nvarchar(50),
	cst_firstname nvarchar(50),
	cst_lastname nvarchar(50),
	cst_material_status nvarchar(50),
	cst_grnd nvarchar(50),
	cst_create_date date
);
Go

If OBJECT_ID('bronze.crm_prd_info','U') is not Null
drop table bronze.crm_prd_info;
Go

Create Table bronze.crm_prd_info(
	prd_id INT,
	prd_key	nvarchar(50),
	prd_nm	nvarchar(50),
	prd_cost INT,
	prd_line nvarchar(50),
	prd_start_dt datetime,
	prd_end_dt datetime
);
Go

If OBJECT_ID('bronze.crm_sales_details','U') is not Null
drop table bronze.crm_sales_details;
Go

Create Table bronze.crm_sales_details(
	sls_ord_num	nvarchar(50),
	sls_prd_key	nvarchar(50),
	sls_cust_id	int,
	sls_order_dt int,
	sls_ship_dt	int,
	sls_due_dt int,
	sls_sales int,	
	sls_quantity int,
	sls_price int
);
Go

If OBJECT_ID('bronze.erp_cust_az12','U') is not Null
drop table bronze.erp_cust_az12;
Go

Create Table bronze.erp_cust_az12(
cid	nvarchar(50),
bdate date,
gen nvarchar(50)
)
Go

If OBJECT_ID('bronze.erp_loc_a101','U') is not Null
drop table bronze.erp_loc_a101;
Go

Create Table bronze.erp_loc_a101(
cid nvarchar(50),
cntry nvarchar(50)
);
Go

If OBJECT_ID('bronze.erp_px_cat_g1v2','U') is not Null
drop table bronze.erp_px_cat_g1v2;
Go

Create Table bronze.erp_px_cat_g1v2(
id nvarchar(50),
cat	nvarchar(50),
subcat nvarchar(50),
maintenance nvarchar(50)
);

