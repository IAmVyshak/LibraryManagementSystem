	--creating a database for library management system
 create database AbrahamMossLibrary;

 -- use the above database
 use AbrahamMossLibrary;

 --create libraryMembers table
CREATE TABLE LibraryMembers 
	(MemberID INT IDENTITY(20311,1) PRIMARY KEY,
	FirstName VARCHAR(30) NOT NULL,
	MiddleName VARCHAR(30) NULL,
	LastName VARCHAR (30) NOT NULL,
	Address1 VARCHAR(100) NOT NULL,
	Address2 VARCHAR(100) NOT NULL,
	PostCode VARCHAR (20) NOT NULL,
	DateOfBirth DATE NOT NULL,
	Username VARCHAR (30) NOT NULL,
	Password VARCHAR (100) NOT NULL,
	Email VARCHAR(255) NOT NULL CHECK (Email LIKE '%@%')
);

--create a table to track all active and inactive members
CREATE TABLE MemberStatus(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	MemberID INT NOT NULL FOREIGN KEY REFERENCES LibraryMembers (MemberID),
	MemberStartDate DATE NOT NULL,
	MemberEndDate DATE,
	StatusOfMember VARCHAR(10)
);

--Create catalogue type table. 
Create table CatalogueTypes(
	CatalogueID INT NOT NULL PRIMARY KEY,
	CatalogueType VARCHAR (50)
);

--Create table for current catalogue status
CREATE TABLE StatusOfCatalogues (
	CurrentStatusID INT NOT NULL PRIMARY KEY,
	CurrentStatus VARCHAR (50) NOT NULL
);

--Create a table to store all catalogues
CREATE TABLE Catalogues (
	CatalogueNameID INT NOT NULL PRIMARY KEY,
	CatalogueID INT NOT NULL FOREIGN KEY REFERENCES CatalogueTypes (CatalogueID),
	CatalogueName VARCHAR (150) NOT NULL,
	CatalogueAuthor VARCHAR (30) NOT NULL,
	PublishedYear INT NOT NULL,
	AddedToCollectionDate DATETIME NOT NULL,
	CurrentStatusID INT NOT NULL FOREIGN KEY REFERENCES StatusOfCatalogues (CurrentStatusID),
	LossOfCatalogue DATE,
	ISBN VARCHAR (30) CONSTRAINT uc_isbn UNIQUE (ISBN)
);

--Create a loan table to view and calculate the loans
CREATE TABLE Loans (
	loanID INT IDENTITY(1,1) PRIMARY KEY,
	MemberID INT NOT NULL FOREIGN KEY REFERENCES LibraryMembers (MemberID),
	CatalogueNameID INT NOT NULL FOREIGN KEY REFERENCES Catalogues (CatalogueNameID),
	OutTakenDate DATE NOT NULL,
	DateDue DATE NOT NULL,
	DateOfReturn DATE,
	FineIfOverdue DECIMAL (10,2)
);

--Table to maintain how much fine is paid
CREATE TABLE FineDetails (
    OverdueFineID INT IDENTITY(1,1) PRIMARY KEY,
    MemberID INT NOT NULL,
    TotalFineAmount DECIMAL(10,2) NOT NULL,
    RepaidAmount DECIMAL(10,2) NOT NULL DEFAULT 0,
    ExistingBalance AS (TotalFineAmount - RepaidAmount),
    CONSTRAINT FK_FineOverdueOfMembers FOREIGN KEY (MemberID) REFERENCES LibraryMembers(MemberID)
);

--Altering the table to make FineDetails a 1 to 1 relation with LibraryMembers
ALTER TABLE FineDetails
ADD CONSTRAINT uq_FineDetails UNIQUE (MemberID);

--Table to track the payments made
CREATE TABLE RepaymentHistory (
    RepaymentHistoryID INT IDENTITY(101,1) PRIMARY KEY,
    OverdueFineID INT NOT NULL,
    PayBackDate DATE NOT NULL,
    AmountPaidBack DECIMAL(10,2) NOT NULL,
    PaymentMethod VARCHAR(10) CHECK (PaymentMethod IN ('Cash', 'Card'))
    CONSTRAINT FK_RepayOverdueFine FOREIGN KEY (OverdueFineID) REFERENCES FineDetails(OverdueFineID)
);

--Alter tables based on requirements

-- Inserting values to tables created

--Insert values to the CatalogueTypes table
INSERT INTO CatalogueTypes (CatalogueID, CatalogueType)
VALUES (201, 'Book'), (202, 'Journal'), (203, 'DVD'), (204, 'Other Media');
select * from CatalogueTypes;

--Insert required items to StatusOfCatalogues table
INSERT INTO StatusOfCatalogues (CurrentStatusID, CurrentStatus)
VALUES (501, 'Available'), (502, 'Loan'), (503, 'Overdue'), (504, 'Lost'), (505, 'Removed');
select * from StatusOfCatalogues;

--Inserting members to the LibraryMembers tables
--Using stored procedures to insert the values.
--Demonstarting stored procedures
CREATE PROCEDURE insertingMember 	@FirstName NVARCHAR(30),
	@MiddleName NVARCHAR(30),
	@LastName NVARCHAR (30),
	@Address1 NVARCHAR(100),
	@Address2 NVARCHAR(100),
	@PostCode NVARCHAR (30),
	@DateOfBirth DATE,
	@Username NVARCHAR (30),
	@Password NVARCHAR (100),
	@Email NVARCHAR(255)ASBEGIN	SET NOCOUNT ON;	INSERT INTO LibraryMembers (FirstName, MiddleName, LastName, Address1, Address2, PostCode, DateOfBirth, Username, Password, Email)	VALUES (@FirstName, @MiddleName, @LastName, @Address1, @Address2, @PostCode, @DateOfBirth, @Username, HASHBYTES ('SHA2_256', @Password), @Email)END--insert values by calling the stored procedures. --Initially creating 6 membersEXEC insertingMember 'Vyshak', 'Madathil', 'Vattekat', ' 72', 'Lansdowne Road',  'M8 5SH', '1995-03-27', 'Vyshak', 'Vyshak@123', 'Vmadathil@gmail.com'EXEC insertingMember 'Sanjana', '', 'Manoj', ' 74', 'Jury Road',  'M8 5WT', '1999-11-01', 'Sanjana01', 'Sanjana@123', 'MSanjana@gmail.com'EXEC insertingMember 'Nimesh', '', 'Vismaya', ' 34', 'Prestwich Road',  'M7 3RS', '1992-03-14', 'Readnim', 'Nimesh@123', 'NimeshV@gmail.com'EXEC insertingMember 'Sarang', 'K', 'Das', ' 74', 'Lansdowne Road',  'M8 5SH', '1994-10-24', 'itssarang', 'Sarang@123', 'SarangD@gmail.com'EXEC insertingMember 'Ramya', '', 'Ramachandrakumar', ' 72', 'Lansdowne Road',  'M8 5SH', '1994-10-23', 'ramya', 'Ramya@123', 'RamyaR@gmail.com'select * from LibraryMembers;--delete from LibraryMembers where MemberID = '20312';--insert values to Member status tableinsert into MemberStatus values(
	20311, '2023-02-17','',''
);

insert into MemberStatus values(
	20313, '2023-02-19','',''
);

insert into MemberStatus values(
	20314, '2023-03-01',NULL,''
);

insert into MemberStatus values(
	20315, '2023-03-03','2023-03-27',''
);

insert into MemberStatus values(
	20316,'2023-03-15','2023-04-02',''
);

--Altering MemberStatus table to allow NULL value incase if there is no MemberEnd =
ALTER TABLE MemberStatus
ALTER COLUMN MemberEndDate DATE NULL;

--updating existing tables who donot have an end date to have NULL in it
update MemberStatus
set MemberEndDate = NULL
where MemberID = 20313;

--Trigger to update the records of StatusOfMember field to Active or Inactive based on MemberEndDate
CREATE TRIGGER trg_UpdatingMemberStatus
ON MemberStatus
AFTER INSERT
AS
BEGIN
    UPDATE MemberStatus
    SET StatusOfMember = CASE
            WHEN MemberEndDate >= GETDATE() OR MemberEndDate IS NULL  THEN 'Active'
            ELSE 'Inactive'
        END
    WHERE ID IN (SELECT ID FROM inserted)
END

--Display the items of MemberStatus table
select * from MemberStatus;

--Insert values to Catalogue table
CREATE PROCEDURE insertCatalogue	@CatalogueNameID INT,	@CatalogueID INT,
	@CatalogueName VARCHAR (150),
	@CatalogueAuthor VARCHAR (30),
	@PublishedYear INT,
	@AddedToCollectionDate DATETIME,
	@CurrentStatusID INT,
	@LossOfCatalogue DATE,
	@ISBN VARCHAR (30)ASBEGIN	SET NOCOUNT ON;	INSERT INTO Catalogues (CatalogueNameID, CatalogueID, CatalogueName, CatalogueAuthor, PublishedYear, AddedToCollectionDate, CurrentStatusID, LossOfCatalogue, ISBN)	VALUES (@CatalogueNameID, @CatalogueID, @CatalogueName, @CatalogueAuthor, @PublishedYear, @AddedToCollectionDate, @CurrentStatusID, @LossOfCatalogue, @ISBN)END

--Altering the above procedure to achieve data concurrency
ALTER PROCEDURE insertCatalogue	@CatalogueNameID INT,	@CatalogueID INT,
	@CatalogueName VARCHAR (150),
	@CatalogueAuthor VARCHAR (30),
	@PublishedYear INT,
	@AddedToCollectionDate DATETIME,
	@CurrentStatusID INT,
	@LossOfCatalogue DATE,
	@ISBN VARCHAR (30)ASBEGIN	BEGIN TRY		BEGIN TRANSACTION;		SET NOCOUNT ON;		INSERT INTO Catalogues (CatalogueNameID, CatalogueID, CatalogueName, CatalogueAuthor, PublishedYear, AddedToCollectionDate, CurrentStatusID, LossOfCatalogue, ISBN)		VALUES (@CatalogueNameID, @CatalogueID, @CatalogueName, @CatalogueAuthor, @PublishedYear, @AddedToCollectionDate, @CurrentStatusID, @LossOfCatalogue, @ISBN)		COMMIT TRANSACTION;	END TRY	BEGIN CATCH		ROLLBACK TRANSACTION;		END CATCHEND


drop stored

--Altering Catalogues table to allow NULL value incase if there is no LossOfCatalogue
ALTER TABLE Catalogues
ALTER COLUMN LossOfCatalogue DATE NULL;

--inserting values to catalogue by executing the stored procedure
EXEC insertCatalogue 3101, 201, 'The Alchemist', 'Paulo Coelho', 1988, '2023-03-14', 501, NULL, '2341001';
EXEC insertCatalogue 3102, 201, 'The Great Gatsby', 'F. Scott Fitzgerald', 1925, '2023-03-14', 501, NULL, '2341002';
EXEC insertCatalogue 3103, 201, 'Hamlet', 'William Shakespeare', 1600, '2023-03-16', 501, NULL, '2341003';
EXEC insertCatalogue 3104, 201, 'Romeo And Juliet', 'William Shakespeare', 1595, '2023-03-16', 501, NULL, '2341004';
EXEC insertCatalogue 3105, 203, 'Harry Potter and the philosopher stone', 'JK Rowling', 2001, '2023-03-18', 501, NULL, '2341005';
EXEC insertCatalogue 3106, 203, 'Harry Potter and the chamber of secrets', 'JK Rowling', 2002, '2023-03-18', 501, NULL, '2341006';
EXEC insertCatalogue 3107, 203, 'Harry Potter and the prisoner of azkaban', 'JK Rowling', 2004, '2023-03-18', 501, NULL, '2341007';
EXEC insertCatalogue 3108, 203, 'Harry Potter and the goblet of fire', 'JK Rowling', 2005, '2023-03-19', 501, NULL, '2341008';
EXEC insertCatalogue 3109, 202, 'Observation of Gravitational Waves from a Binary Black Hole Merger', 'LIGO Scientific Collaboration', 2016, '2023-03-10', 501, NULL, '2341009';
EXEC insertCatalogue 3110, 202, 'Evolution of Darwins finches and their beaks revealed by genome sequencing', 'Peter and Rosemary Grant et al', 2014, '2023-03-11', 501, NULL, '2341010';
EXEC insertCatalogue 3111, 204, 'Thinking, Fast and Slow', 'Daniel Kahneman', 2011, '2023-03-17', 501, NULL, '2341011';
EXEC insertCatalogue 3112, 204, 'Sapiens: A Brief History of Humankind', 'Yuval Noah Harari', 2011, '2023-03-17', 501, NULL, '2341012';
EXEC insertCatalogue 3113, 204, 'Concurrency CHeck', 'Vyshak', 2021, '2023-03-17', 501, NULL, '2341013';

--Display all the items of catalogues table
select * from Catalogues;

--Inserting a value to loan table to test the above trigger
insert into Loans values(20313, 3103, '2023-04-15', '2023-04-25', '2023-04-18', 0.00);

select * from Catalogues;

--Trigger to update the fineIfOverdue column incase the member surpass the due date
CREATE TRIGGER trCalculateFineIfOverdue
ON Loans
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE Loans
    SET FineIfOverdue = 
        CASE 
            WHEN Loans.DateDue < GETDATE() 
            THEN DATEDIFF(day, Loans.DateDue, GETDATE()) * 0.10 
            ELSE 0 
        END
    FROM inserted
    WHERE inserted.loanID = Loans.loanID
END
Go

--Test the above trigger by adding a overdue and non overdue data
insert into Loans values(20314, 3106, '2023-04-01', '2023-04-11', '2023-04-15',0);

select * from Loans;

select * from LibraryMembers;
select * from Catalogues;

--Question 4 : 
--For this, firstly, let us assume that if DateOfReturn is NULL, then the catalogue is not yet returned or is not due
--Alter the Loans table to accept NULL for DateOfReturn as an indicator for catalogues not returned after due date or is not still due
ALTER TABLE Loans
ALTER COLUMN DateOfReturn DATE NULL;

--Trigger to set the Current Status to Overdue if a book is not returned after the due date
CREATE TRIGGER trUpdateCurrentStatusIDToOverdue
ON Loans
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE Catalogues
    SET CurrentStatusID = 503
    FROM Catalogues c
    INNER JOIN inserted i ON c.CatalogueNameID = i.CatalogueNameID
    WHERE i.DateDue < GETDATE()  AND i.DateOfReturn IS NULL AND c.CatalogueNameID = i.CatalogueNameID
END
go

----Trigger to set the Current Status to Available once the book is returned
CREATE TRIGGER trUpdateCurrentStatusToAvailable
ON Loans
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE Catalogues
    SET CurrentStatusID = 501
    FROM Catalogues c
    INNER JOIN inserted i ON c.CatalogueNameID = i.CatalogueNameID
    WHERE i.DateOfReturn IS NOT NULL AND c.CatalogueNameID = i.CatalogueNameID
END
go

----Trigger to set the Current Status to Loan if a book is borrowed
CREATE TRIGGER trCurrentStatusToLoan
ON Loans
AFTER Insert, UPDATE
AS
BEGIN
    UPDATE Catalogues
    SET CurrentStatusID = 502
    FROM Catalogues c
    INNER JOIN inserted i ON c.CatalogueNameID = i.CatalogueNameID
    WHERE i.DateOfReturn IS NULL AND i.DateDue > GETDATE() AND c.CatalogueNameID = i.CatalogueNameID
END
go

--Triggers to update the Repayment History table whenever a book is borrowed or if there is an overdue
--Here whenever an item is inserted or updated in loans table, this trigger should update the respective member id columns in repayment history table
CREATE TRIGGER trUpdatingFineDetailsTable
ON Loans
AFTER INSERT
AS
BEGIN
    DECLARE @MemberID INT
    SELECT @MemberID = MemberID FROM inserted
    
    IF NOT EXISTS (SELECT * FROM FineDetails WHERE MemberID = @MemberID)
    BEGIN
        -- Fine details have no records for this member, then insert a new value
        INSERT INTO FineDetails (MemberID, TotalFineAmount, RepaidAmount)
        SELECT @MemberID, FineIfOverdue, 0
        FROM Loans
        WHERE MemberID = @MemberID
    END
    ELSE
    BEGIN
        -- Member is already present in FineDetails table and update if there is a new loan on member
        UPDATE FineDetails
        SET TotalFineAmount = (SELECT COALESCE(SUM(FineIfOverdue), 0) FROM Loans WHERE MemberID = @MemberID)
        WHERE MemberID = @MemberID
    END
END
go

--Test the above triggers
--2. Check if the triggers update to loan after the book is taken to loan and updates back when book is returned
insert into Loans values(20313, 3101, '2023-04-12', '2023-04-23', NULL,0);
select * from catalogues;
select * from loans;

--Borrower returns the book before due date
update Loans set DateOfReturn = '2023-04-21' where loanID = 1048;
select * from catalogues;
select * from loans;

--1. check if the trigger update the catalogue as overdue if return date is more than the due date and
--set back to available when it is returned.
insert into Loans values(20311, 3105,'2023-04-08','2023-04-17',NULL,0);
select * from catalogues;
select * from loans;

update Loans set DateOfReturn = '2023-04-21' where loanID = 1047;
select * from catalogues;
select * from loans;

--Question 2 
--Section A
--Creating a stored procedure to search the catalogue for matching character strings by title
--reason for using stored procedure => while using select query, the user defined functions doesnot allow to 
-- include a order by clause in it. hence using a stored procedure
create procedure sp_searchForACatalogue
(
	@searchString nvarchar(50)
)
as
begin
	select *
	from Catalogues
	where CatalogueName like '%'+@searchString+'%'
	order by PublishedYear desc
end
go

--test the stored procedure to validate if it returns required result
exec sp_searchForACatalogue 'Harry';

-- Question 2 Section B
--Inorder to get list of items having loan whose due date is less than the current date
--The current date is 20 April 2024 so results shall be based on this date

--Insert few items in loans table first to proceed with this. Make sure we have items whoese due date is less than 5
insert into Loans values(20311, 3102,'2023-04-09','2023-04-18',NULL,0);
insert into Loans values(20311, 3107,'2023-04-08','2023-04-17',NULL,0);
insert into Loans values(20313, 3104,'2023-04-06','2023-04-13',NULL,0);

--list all the items in loan table
select * from loans;
--There are 5 items in loans table and there are 2 items currently on loan whose due date is less than 5
--Observe that there is a returned item with due date less than 5 days. So our function should be created to handle these conditions
--end of result

--user defined function to return full list of items on loan
create function itemsOnLoanDueInFiveDays()
RETURNS TABLE
as
RETURN
	select l.loanID, l.MemberID, lm.FirstName, c.CatalogueName
	from Loans as l
	inner join LibraryMembers as lm on l.MemberID = lm.MemberID
	inner join Catalogues as c on l.CatalogueNameID = c.CatalogueNameID
	where l.DateOfReturn IS NULL AND (DATEDIFF(DAY, l.DateDue, GETDATE()) < 5);

--test the function if it returns the desired result
select * from itemsOnLoanDueInFiveDays();


--Test the trigger trUpdatingFineDetailsTable to check if Fine Details table is updated after performing above operations
select * from Loans;
select * from FineDetails

--Let us also create a trigger to update the Repaid Amount column in FineDetails table whenever a member pays the loan amount
--This trigger is aimed at updating the repaid amount and related columns if a members pays certain amount of their fine.
CREATE TRIGGER trUpdateRepaidAmountIfFinePaid
ON RepaymentHistory
AFTER INSERT,UPDATE
AS
BEGIN
    DECLARE @OverdueFineID INT, @AmountPaidBack DECIMAL(10,2)

    SELECT @OverdueFineID = OverdueFineID, @AmountPaidBack = AmountPaidBack FROM inserted

    UPDATE FineDetails
    SET RepaidAmount = RepaidAmount + @AmountPaidBack
    WHERE OverdueFineID = @OverdueFineID
END
go
 
 --Test trUpdateRepaidAmountIfFinePaid and check RepaymentHistory as well as FineDetails Table
 --For this insert a value to Repayment History table
insert into RepaymentHistory values(7,'2023-04-21',0.10,'Card')

--Display the results
select * from RepaymentHistory;
select * from FineDetails;

--Question 2 Section C
--Inserting a new member to database using the stored procedure
EXEC insertingMember 'Robert', 'Franklin', 'Scot', ' 18', 'Prestwich Road',  'M9 8EH', '1992-10-23', 'robert', 'Robert@123', 'RobertS@gmail.com'select * from LibraryMembers;

--Question 2 Section D
--Stored Procedure to update any element in the Library memeber table
CREATE PROCEDURE updateLibraryMember	@MemberID INT,	@FirstName NVARCHAR(30),
	@MiddleName NVARCHAR(30),
	@LastName NVARCHAR (30),
	@Address1 NVARCHAR(100),
	@Address2 NVARCHAR(100),
	@PostCode NVARCHAR (30),
	@DateOfBirth DATE,
	@Username NVARCHAR (30),
	@Password NVARCHAR (100),
	@Email NVARCHAR(255)ASBEGIN	SET NOCOUNT ON;UPDATE LibraryMembersSET FirstName = @FirstName,
		MiddleName = @MiddleName,
		LastName =  @LastName,
		Address1 = @Address1,
		Address2 = @Address2,
		PostCode = @PostCode,
		DateOfBirth = @DateOfBirth,
		Username = @Username ,
		Password = HASHBYTES ('SHA2_256', @Password),
		Email = @EmailWHERE MemberID = @MemberID;END;

--update the postcode for member 21312
exec updateLibraryMember 
	@MemberID = 21312,
	@FirstName = 'Robert',
	@MiddleName = 'Franklin',
	@LastName = 'Scot',
	@Address1 = '18',
	@Address2 = 'Prestwich Road',
	@PostCode = 'M9 8SH',
	@DateOfBirth = '1992-10-23',
	@Username = 'robert',
	@Password = 'Robert@123',
	@Email = 'RobertS@gmail.com'

--check if the table is updated
select * from LibraryMembers;

--Question 3

--Create a view to display Member Name, loan ID, member ID, CatalogueName its ID, borrowed date, due date and any fines associated with loan
create view historyOfLoans AS
	select 
		(lm.FirstName + ' ' +lm.LastName) as MemberName, l.loanID, l.MemberID, l.CatalogueNameID, l.OutTakenDate, l.DateDue, l.FineIfOverdue,
		c.CatalogueName
	from Loans l
	join Catalogues c on l.CatalogueNameID = c.CatalogueNameID
	join LibraryMembers lm on l.MemberID = lm.MemberID;

--execute the view to display all items in view
select * from historyOfLoans;

--execute the view to display only MemberName, CatalogueName, BorrowedDate, Due date and if any fines
select MemberName, CatalogueName, OutTakenDate, DateDue, FineIfOverdue from historyOfLoans;

--Question 5
--user defined function to to identify total number of loans made on a given date

create function displayTotalNumberLoanOnDate
(
	@dateOfBorrow DATE
)
RETURNS TABLE 
AS
RETURN 
	select count(*) as TotalNumberOfLoansForTheDay
	from Loans
	where OutTakenDate = @dateOfBorrow;

--display all the items in loans table to select a borrow date
select * from Loans;

--use the date as 08-04-2023
select * from displayTotalNumberLoanOnDate('2023-04-08');

--Question 6
--Demonstrating the entire data base by adding items to each table

--Demo 1
--Inserting a new member to the Library
--Earlier a stored procedure was created to add a libraryMember
--Executing the insertingMember stored procedure
EXEC insertingMember 'David', 'Junior', 'Beckham', ' 34', 'Broadway Street',  'M13 5RH', '1990-07-13', 'beckham', 'DavidB@123', 'DavidJ@gmail.com'select * from LibraryMembers;

--Demo 2
--add a new row to MemberStatus table
--The newly added member's start date should be entered against his member ID
--Once an item is inserted to the MemberStatus, the trigger trg_UpdatingMemberStatus is auto executed which sets member as Active
insert into MemberStatus values(
	21313, '2023-04-20',NULL,''
);

--display the updated memberStatus table
select * from MemberStatus;

--Demo 3
--add a new book to the catalogue table by executing the stored procedure insertCatalogue
EXEC insertCatalogue 3113, 201, 'The Melting Of Maggie Bean', 'Tricia Raybern', 2007, '2023-03-14', 501, NULL, '2341013';
select * from Catalogues;

--Demo 4
--Demonstarte inserting an item to loan table
--Assuming a member 20314 borrows book The Melting Of Maggie Bean on loan
--The member surpass the due date
--This case should fire triggers to update the CurrentStatusID of catalogues table t0 Overdue against the book
--It also fires a trigger to calculate the fine based on the current system date i.e., 21st of April
--A trigger is also executed to update the fine details table since there is a fine associated to it
insert into Loans values(20314, 3113,'2023-04-15','2023-04-19',NULL,0);

--display the catalogues, fine details and loan table to check if the specified triggers are executed
select * from loans;
select * from catalogues;
select * from FineDetails;