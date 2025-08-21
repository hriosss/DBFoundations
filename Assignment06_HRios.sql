--*************************************************************************--
-- Title: Assignment06
-- Author: HRios
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,HRios,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_HRios')
	 Begin 
	  Alter Database [Assignment06DB_HRios] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_HRios;
	 End
	Create Database Assignment06DB_HRios;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_HRios;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
go
create or alter view vcategories
with schemabinding
as
	select categoryid
	, categoryname
	from dbo.Categories;
go
select * from vcategories
--
go
create or alter view vproducts
with schemabinding
as
	select productid
	, productname
	, CategoryID
	, unitprice
	from dbo.Products;
go
select * from vproducts
--
go
create or alter view vemployees
with schemabinding
as
	select employeeid
	, employeefirstname
	, employeelastname
	, managerid
	from dbo.Employees;
go
select * from vemployees
--
go
create or alter view vinventories
with schemabinding
as
	select inventoryid
	, inventorydate
	, employeeid
	, productid
	, [count]
	from dbo.Inventories;
go
select * from vinventories
go
-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?
--Categories
go
create or alter view vprivatecategories
as
select categoryid
, categoryname
from Categories;
go
select * from vprivatecategories
go
go
create or alter view vpubliccategories
as
select categoryname
from Categories;
go
select * from vpubliccategories
go
--Products
go
create or alter view vprivateproducts
as
select productid
, productname
, CategoryID
, unitprice
from Products;
go
select * from vprivateproducts
go
go
create or alter view vpublicproducts
as
select productname
, unitprice
from Products;
go
select * from vpublicproducts
go
--Employees
go
create or alter view vprivateemployees
as
select employeeid
, employeefirstname
, employeelastname
, managerid
from Employees;
go
select * from vprivateemployees
go
create or alter view vpublicemployees
as
select employeefirstname
, employeelastname
from Employees;
go
select * from vpublicemployees
go
--
create or alter view vprivateinventories
as
select inventoryid
, inventorydate
, employeeid
, productid
, [count]
from Inventories;
go
select * from vprivateinventories
go
create or alter view vpublicinventories
as
select InventoryID
, inventorydate
, [count]
from Inventories;
go
select * from vpublicinventories
go


-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

Create or Alter View vProductsByCategories
as
	select categoryname
	, productname
	, unitprice
	from categories c
	join products p
		on c.CategoryID=p.CategoryID;
go
select * from vProductsByCategories
	order by CategoryName, ProductName;


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!
go
Create or Alter View vInventoriesByProductsByDates
as
	select productname, InventoryDate, [Count]
	from Products p
	join Inventories i
		on p.ProductID = i.ProductID;
go
select * from vInventoriesByProductsByDates
	order by ProductName, InventoryDate, [Count];
go

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth
go
Create or Alter View vInventoriesByEmployeesByDates
as
	select distinct inventorydate, 
	employeename = e.EmployeeFirstName + ' ' + e.EmployeeLastName
	from inventories i
	join Employees e
		on i.EmployeeID = e.EmployeeID;
go
select * from vInventoriesByEmployeesByDates
	order by InventoryDate;
go

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!
go
create or alter view vInventoriesByProductsByCategories
as
	select c.categoryname
	, p.productname
	, i.inventorydate
	, i.[count]
	from Categories c
	join products p
		on c.CategoryID=p.CategoryID
	join Inventories i
		on i.ProductID=p.ProductID;
go
select * from vInventoriesByProductsByCategories
	order by categoryname, productname, inventorydate, [count];
go



-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!
go
create or alter view vInventoriesByProductsByEmployees
as
	select c.categoryname
	, p.productname
	, i.inventorydate
	, i.[count]
	, employeefirstname + ' ' + employeelastname AS 'EmployeeName'
	from Categories c
	join products p
		on c.CategoryID=p.CategoryID
	join Inventories i
		on i.ProductID=p.ProductID
	join employees e
		on e.EmployeeID=i.EmployeeID;
go
select * from vInventoriesByProductsByEmployees
	order by inventorydate, categoryname, productname, EmployeeName;
go 


-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 
go
create or alter view vInventoriesForChaiAndChangByEmployees
as
	select c.CategoryName
	, p.ProductName
	, i.InventoryDate
	, i.[Count]
	, e.employeefirstname + ' ' + e.employeelastname AS 'employeename'
	from Categories c
	join products p
		on c.CategoryID = p.CategoryID
	join Inventories i
		on p.productid = i.ProductID
	join employees e
		on i.EmployeeID = e.EmployeeID
	where p.productID IN (SELECT productID
							FROM products p
							WHERE p.productname IN ('Chai','Chang')
							)
go
select * from vInventoriesForChaiAndChangByEmployees
	order by InventoryDate, ProductName;
go


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!
go
create or alter view vEmployeesByManager
as
	select m.employeefirstname + ' ' + m.employeelastname AS 'ManagerName'
	, e.employeefirstname + ' ' + e.employeelastname AS 'EmployeeName'
	from employees e
	join employees m
		on e.ManagerID=m.EmployeeID;
go
select * from vEmployeesByManager
	order by ManagerName, EmployeeName;
go

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.
go
create or alter view vInventoriesByProductsByCategoriesByEmployees
as
	Select c.categoryID
	, c.CategoryName
	, p.ProductID
	, p.ProductName
	, p.UnitPrice
	, i.InventoryID
	, i.InventoryDate
	, i.[Count]
	, e.EmployeeID
	, e.employeefirstname + ' ' + e.employeelastname AS 'EmployeeName'
	, m.employeefirstname + ' ' + m.employeelastname AS 'ManagerName'
	From Categories c
	join Products p
		on p.CategoryID=c.CategoryID
	join Inventories i
		on i.ProductID=p.ProductID
	join Employees e
		on e.EmployeeID=i.employeeID
	join employees m
		on e.ManagerID=m.EmployeeID;
go
select * from vInventoriesByProductsByCategoriesByEmployees
	order by CategoryName
	, ProductName
	, InventoryID
	, ManagerName;
go


-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/