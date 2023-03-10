/*

- Part A - Design and Create Database: 

	-- Design the database you’ll use to analyze the Spreadsheet tabs and 
		design a database with a set of tables tables and fields. 
		*** At this point, you won’t need to populate it, but will need to 
			design a normalized set  of database table structures and 
			relationships(e.g. FK).
			**** HINT: the spreadsheet Entities  (People, Offices, Software) 
				are NOT normalized and need to be by adding additional tables.
		*** In each of the tables, ensure there is an int ID that uniquely 
			identifies the row (e.g. could be your PK?). Each ID should be a 
			simple IDENTITY - generated automatically.
		*** HINT: Avoid using PK or FKs that don’t make sense (e.g. “Erik Kellener”)
			may be a unique key, but doesn’t mean it makes for a good unique PK/FK
	-- Create a series of statements that ~ (remember it needs to be idempotent)
		DROP and CREATE the NewCo database
		DROP and CREATE the  tables to use in the database
		Again, use your best judgement on data-types, but try to retain the 
		intended naming convention from each column in the sheet 
		(e.g avoid using ]zip code field that has a name “city” 
	-- Hint: Use your understanding of a normal form to model the database 
		from the spreadsheet. ******Avoid just mapping a single tab to a single 
		table, there’s more normalization to the structure needed.*****
*/



USE master;
GO

/****** A.1.0:  Drop a database if existing  ******/
IF DB_ID('FinalProject') IS NOT NULL
	DROP DATABASE FinalProject
GO

--- A.1.1 Create a database named FinalProject ---
CREATE DATABASE FinalProject;
GO 


USE FinalProject;
GO

---  A.2.0 Drop Addresses table if existing ---
IF OBJECT_ID('EmployeeOffice') IS NOT NULL
    DROP TABLE EmployeeOffice
GO

---  A.2.0 Drop Employees table if existing ---
IF OBJECT_ID('Employees') IS NOT NULL
    DROP TABLE Employees
GO

---  A.2.0 Drop Employees table if existing ---
IF OBJECT_ID('Office') IS NOT NULL
    DROP TABLE Office
GO

---  A.2.0 Drop System table if existing ---
IF OBJECT_ID('System') IS NOT NULL
    DROP TABLE System
GO

---  A.2.0 Drop Manager table if existing ---
IF OBJECT_ID('Manager') IS NOT NULL
    DROP TABLE Manager
GO


---  A.2.1 Create a table called Employees ---
CREATE TABLE Employees
(
EmployeeID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
FirstName varchar(50) NOT NULL,
LastName varchar(50) NOT NULL,
DateOfBirth Date NOT NULL,
HomeZip varchar(10) NOT NULL
)
GO


---  A.2.1 Create a table called Addresses ---
CREATE TABLE EmployeeOffice
(
InternalID INT IDENTITY(1,1) NOT NULL,
EmployeeID INT NOT NULL,
OfficeLocation varchar(60) NOT NULL,
)
GO

---  A.2.1 Create a table called Office ---
CREATE TABLE Office
(
InternalID INT IDENTITY(1,1) NOT NULL,
OfficeLoc varchar(60) NOT NULL,
Capacity INT NOT NULL,
OffLocZip varchar(10) NOT NULL,
ManagerID INT NOT NULL
)
GO


---  A.2.1 Create a table called System ---
CREATE TABLE System
(
SystemID INT IDENTITY(1,1) NOT NULL,
Asset_key varchar(60) NOT NULL,
VendorName varchar(60) NOT NULL,
ProductName varchar(60) NOT NULL,
ProductVersion INT NOT NULL,
PurchaseDate varchar(60) NOT NULL
)
GO

---  A.2.1 Create a table called Manager ---
CREATE TABLE Manager
(
ManagerID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
OfficeMgr varchar(60) NOT NULL
)
GO



---  A.3.1 Create relationship ( Foreign key: Address/Primary key: Employees) ---
ALTER TABLE EmployeeOffice
WITH NOCHECK ADD CONSTRAINT FK_EmployeeOffice_Employees
FOREIGN KEY(EmployeeID)   /* Foreign key */
REFERENCES Employees (EmployeeID) /* Primary key */
GO


---  A.3.1 Create relationship ( Foreign key: Office/Primary key: Manager) ---
ALTER TABLE Office
WITH NOCHECK ADD CONSTRAINT FK_Office_Manager
FOREIGN KEY(ManagerID)   /* Foreign key */
REFERENCES Manager (ManagerID) /* Primary key */
GO




/*

- Part B -Create data management stored procedures and functions - 
  (again, all of these should be idempotent)

	-- sp_addEmployee: Parameters (firstname, lastname, dob, zipcode)
		** zipcode is the employee’s home zip.
		** Action:Adds an employee to the database
	-- fn_findEmployeeID: Parameters (fullname)
		** Note fullname is the firstname + ‘ ‘ +lastname
		** Action:Performs a lookup on the fullname, and returns an internal ID 
		for the employee (note, these are generated by the identities)
	-- sp_addOffice: Parameters (location,capacity,zip,manager’s name)
		** location is the name of the office (e.g. Olaf)
		** capacity is the number of employees that can fit at the location
		** Zip is the office’s zipcode
		** Manager’s name is the fullname of the employee’s manager
		** Action:Adds a new Office location record
		Incorporate the newly created fn_findEmployeeID function into your 
		solution. This will help you translate the Manager’s name (fullname) 
		to their corresponding EmployeeID.
	-- fn_findOfficeID: Parameters (location)
		** location is the name of the office (e.g. Olaf)
		** Action:returns the corresponding internal ID for the @location parameter.
	-- sp_addEmployeeOffice: Parameters (fullname, location)
		** location is the name of the office (e.g. Olaf)
		** fullname is the firstname + ‘ ‘ +lastname
		** Hint: Feel free to use any of the functions, stored procedures, 
		or create your own to support this.
		** Action: Assigns an employee to an office location
		** Use the fn_findOfficeID and fn_findEmployeeID to assist in 
		adding the data to the appropriate tables.
		** Every employee should be assigned to an office. Employees 
		can be assigned to multiple offices.
	-- sp_addSoftware: Parameters (asset_key, vendor name, product name, product version, purchaseDate)
		** Asset_key is unique id of a software asset
		** Vendor_name is the name of the software publisher
		** Product_name is the name of the software product
		** Product_version is the version of the product
		** purchaseDate is the date the product was purchased by the company
		** Action: Adds a software asset to the system
		** Note: for Software, assignedTo and approvedBy fields are defaulted to NULL. They are updated via other stored procedures.
		** Note: purchaseDate parameter is optional and if not specified, defaults to the current date.
	-- sp_assignSoftware: Parameters (asset_key, fullname, approvedBy)
		** Asset_key is unique id of a software asset
		** Fullname is the name of the employee the software should be assigned to
		** approvedBy is the fullname of the employee that approved the software 
		assignment. Use the fn_findEmployeeId(approvedBy) to translate 
		fullname to Id for storing in the table.
		** Action: Assigns a specific software license to an employee 
		(e.g. updates AssignedTo field). Use fn_findEmployeeId(fullname) 
		to translate to an Id for storing in the table.
		** Software can only be assigned to a single person at one time. 
		Software that has a NULL in the assignedTo is considered to be unassigned.

*/


/****** B.1.0:  Drop stored procedures:sp_addEmployee if existing  ******/
IF OBJECT_ID('sp_addEmployee') IS NOT NULL
    DROP PROC sp_addEmployee;
GO

/****** B.1.1:  Create stored procedures:sp_addEmployee  ******/
CREATE PROC sp_addEmployee
	@FirstName varchar(50),
	@LastName varchar(50),
	@DateOfBirth Date,
	@HomeZip varchar(10)

AS

	INSERT Employees
	VALUES (
		@FirstName,
		@LastName,
		@DateOfBirth,
		@HomeZip);
GO



USE FinalProject;
GO

/****** B.2.0:  Drop function:fn_findEmployeeID if existing  ******/
IF OBJECT_ID('fn_findEmployeeID') IS NOT NULL
    DROP FUNCTION fn_findEmployeeID;
GO


/****** B.2.1:  Create function:fn_findEmployeeID  ******/
CREATE FUNCTION fn_findEmployeeID
	(@Fullname varchar(60))
	RETURNS INT



BEGIN
	DECLARE @FirstName varchar(60), @LastName varchar(60);
	SET @FirstName = LEFT(@Fullname, CHARINDEX(' ', @Fullname)-1)
	SET @LastName = RIGHT(@Fullname, LEN(@Fullname) - CHARINDEX(' ', @Fullname))
	RETURN (SELECT EmployeeID FROM Employees WHERE FirstName = @FirstName 
		AND LastName = @LastName);
END;
GO



/****** B.3.0:  Drop stored procedures:sp_addOffice if existing  ******/
IF OBJECT_ID('sp_addOffice') IS NOT NULL
    DROP PROC sp_addOffice;
GO

/****** B.3.1:  Create stored procedures:sp_addOffice  ******/
CREATE PROC sp_addOffice
	@OfficeLoc varchar(60),
	@Capacity INT,
	@OffLocZip varchar(10),
	@OfficeMgr varchar(60)

AS

	INSERT Office
	VALUES (
		@OfficeLoc,
		@Capacity,
		@OffLocZip,
		@OfficeMgr);
GO



USE FinalProject;
GO

/****** B.4.0:  Drop function:fn_findOfficeID if existing  ******/
IF OBJECT_ID('fn_findOfficeID') IS NOT NULL
    DROP FUNCTION fn_findOfficeID;
GO


/****** B.4.1:  Create function:fn_findOfficeID  ******/
CREATE FUNCTION fn_findOfficeID
	(@OfficeLoc varchar(60))
	RETURNS INT



BEGIN
	RETURN (SELECT InternalID FROM Office WHERE OfficeLoc = @OfficeLoc);
END;
GO


/****** B.5.0:  Drop stored procedures:sp_addEmployeeOffice if existing  ******/
IF OBJECT_ID('sp_addEmployeeOffice') IS NOT NULL
    DROP PROC sp_addEmployeeOffice;
GO

/****** B.5.1:  Create stored procedures:sp_addOffice  ******/
CREATE PROC sp_addEmployeeOffice
    @Fullname varchar(60),
	@OfficeLoc varchar(60)

AS
	DECLARE @EmployeeID INT;
	DECLARE @FirstName varchar(60), @LastName varchar(60);
	SET @FirstName = LEFT(@Fullname, CHARINDEX(' ', @Fullname)-1)
	SET @LastName = RIGHT(@Fullname, LEN(@Fullname) - CHARINDEX(' ', @Fullname));
	SELECT @EmployeeID = EmployeeID
	FROM Employees
	WHERE FirstName = @FirstName AND LastName = @LastName;
	INSERT EmployeeOffice
	VALUES (
		@EmployeeID,
		@OfficeLoc);
GO


/****** B.6.0:  Drop stored procedures:sp_addSoftware if existing  ******/
IF OBJECT_ID('sp_addSoftware') IS NOT NULL
    DROP PROC sp_addSoftware;
GO

/****** B.6.1:  Create stored procedures:sp_addSoftware  ******/
CREATE PROC sp_addSoftware
	@Asset_key varchar(60),
	@VendorName varchar(60),
	@ProductName varchar(60),
	@ProductVersion INT,
	@PurchaseDate varchar(60)

AS

	INSERT System
	VALUES (
		@Asset_key,
		@VendorName,
		@ProductName,
		@ProductVersion,
		@PurchaseDate);
GO


USE FinalProject;
GO

/****** B.7.0:  Drop function:fn_findSystemID if existing  ******/
IF OBJECT_ID('fn_findSystemID') IS NOT NULL
    DROP FUNCTION fn_findSystemID;
GO


/****** B.7.1:  Create function:fn_findSystemID ******/
CREATE FUNCTION fn_findSystemID
	(@Asset_key varchar(60))
	RETURNS INT



BEGIN
	RETURN (SELECT SystemID FROM System WHERE Asset_key = @Asset_key);
END;
GO




/****** B.6.0:  Drop stored procedures:sp_addSoftware if existing  ******/
IF OBJECT_ID('sp_assignSoftware') IS NOT NULL
    DROP PROC sp_assignSoftware;
GO

/****** B.6.1:  Create stored procedures:sp_assignSoftware  ******/
CREATE PROC sp_assignSoftware
	@Asset_key varchar(60),
	@VendorName varchar(60),
	@ProductName varchar(60),
	@ProductVersion INT,
	@PurchaseDate varchar(60)

AS

	INSERT System
	VALUES (
		@Asset_key,
		@VendorName,
		@ProductName,
		@ProductVersion,
		@PurchaseDate);
GO



/* 

Part C - Populate database by using the following stored procedure calls. 

*/


-- Part C.1 Add employees:
EXEC sp_addEmployee 'Mickey','Mouse','01/02/1933','90012'
EXEC sp_addEmployee 'Minnie','Mouse','02/03/1933','90012'
EXEC sp_addEmployee 'Donald', 'Duck','03/04/1944','30011'
EXEC sp_addEmployee 'Porky', 'Pig','05/06/1956','90056'
EXEC sp_addEmployee 'Mister', 'Incredible','05/06/1956','90056'
EXEC sp_addEmployee 'Snow', 'White','07/08/1962','32700'


-- Part C.2 Add offices:
EXEC sp_addOffice 'Ariel',100,'92801','Mickey Mouse'
EXEC sp_addOffice 'Looney Tunes',500,'91522','Minnie Mouse'
EXEC sp_addOffice 'Olaf',300,'32830','Mickey Mouse'
EXEC sp_addOffice 'Simba',300,'32830','Mister Incredible'



-- Part C.3 Assign employee’s to an office
EXEC sp_addEmployeeOffice 'Mickey Mouse','Ariel'
EXEC sp_addEmployeeOffice 'Mickey Mouse','Olaf'
EXEC sp_addEmployeeOffice 'Mickey Mouse','Looney Tunes'
EXEC sp_addEmployeeOffice 'Donald Duck','Olaf'
EXEC sp_addEmployeeOffice 'Porky Pig','Looney Tunes'
EXEC sp_addEmployeeOffice 'Minnie Mouse','Ariel'
EXEC sp_addEmployeeOffice 'Minnie Mouse','Olaf'
EXEC sp_addEmployeeOffice 'Mister Incredible','Simba'
EXEC sp_addEmployeeOffice 'Snow White','Ariel'
EXEC sp_addEmployeeOffice 'Snow White','Olaf'



-- Part C.4 Add software licenses to the system
EXEC sp_addSoftware 'MW08ABCD','Microsoft','Windows','08','01/01/2017'
EXEC sp_addSoftware 'AA13EFGH','Adobe','Acrobat','14','01/06/2016'
EXEC sp_addSoftware 'MO16IJKLM','Microsoft','Windows','10','01/01/2017'
EXEC sp_addSoftware 'MW10NOPQ','Microsoft','Windows','10','01/01/2017'
EXEC sp_addSoftware 'MW11RSTU','Microsoft','Windows','11','01/01/2017'
EXEC sp_addSoftware 'MW13VWXY','Microsoft','Windows','13','01/01/2017'
EXEC sp_addSoftware 'MW14ZABC','Microsoft','Windows','14','01/01/2017'
EXEC sp_addSoftware 'AA12EFGH','Adboe','Acrobat','12','10/01/2017'
EXEC sp_addSoftware 'AA11IJKL','Adboe','Acrobat','11','10/01/2017'