--Create Database Datawarehouse
use master;
Go

--Drop and recreate the Datawarehouse database.
if exists(select 1 from sys.databases where name = 'DataWarehouse')
Begin
	alter database DataWarehouse set single_user with Rollback immediate;
	Drop Database DataWarehouse;
End;
Go

--create the Datawarehouse database.
Create Database DataWarehouse;
Go

use DataWarehouse;

--Create Schema
Create Schema bronze;
Go

Create Schema silver;
Go

Create Schema gold;
