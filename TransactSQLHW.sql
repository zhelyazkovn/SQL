--1. Create a database with two tables: Persons(Id(PK), FirstName, LastName, SSN) 
--and Accounts(Id(PK), PersonId(FK), Balance). Insert few records for testing. 
--Write a stored procedure that selects the full names of all persons.

CREATE PROC usp_GetAllPersonsFullNames
AS
SELECT FirstName + ' ' + LastName AS [Full Name]
FROM Persons
GO 

EXEC usp_GetAllPersonsFullNames
GO

------------------------------------------------------------------------------

--2. Create a stored procedure that accepts a number as a parameter and returns 
--all persons who have more money in their accounts than the supplied number.

CREATE PROC usp_GetPersonWithAmountOfMoneyMoreThan(@minWealth int)
AS
SELECT p.FirstName, p.LastName 
FROM Persons p
JOIN Accounts a
ON p.ID = a.PersonID
WHERE a.Balance > @minWealth
GO

EXEC usp_GetPersonWithAmountOfMoneyMoreThan 300
GO

------------------------------------------------------------------------------
--3. Create a function that accepts as parameters – sum, yearly interest 
--rate and number of months. It should calculate and return the new sum. 
--Write a SELECT to test whether the function works as expected.

CREATE FUNCTION ufn_CalculateRemunerated2(@sum money,
  									 @interestRate int,
										 @months int)
RETURNS money
AS
BEGIN
	DECLARE @result money
	SET @result = @sum + (@months/12.0)*((@interestRate*@sum)/100)
	return @result
END
GO


SELECT dbo.ufn_CalculateRemunerated2(100, 10, 110) AS [new sum]
GO

------------------------------------------------------------------------------
--4.Create a stored procedure that uses the function from the previous
-- example to give an interest to a person's account for one month. 
--It should take the AccountId and the interest rate as parameters.
CREATE PROC usp_UpdatePersonsBalance(@AccountID int,
									 @interestRate int)
AS
BEGIN
DECLARE @sum money
SET @sum = (SELECT Balance 
			FROM Accounts
			WHERE ID = CAST(@AccountID AS int))

DECLARE @updatedSum money
SET @updatedSum = dbo.ufn_CalculateRemunerated2(@sum, @interestRate, 1)

UPDATE Accounts 
SET Balance = CAST(@updatedSum AS money)
WHERE ID = CAST(@AccountID AS int)

END
GO

--before update
SELECT Balance
FROM Accounts
WHERE ID = 10

--DROP PROC usp_UpdatePersonsBalance

EXEC usp_UpdatePersonsBalance 10, 50

--after update
SELECT Balance
FROM Accounts
WHERE ID = 10
GO

------------------------------------------------------------------------------
--5. Add two more stored procedures WithdrawMoney( AccountId, money)
 -- and DepositMoney (AccountId, money) that operate in transactions.
 ALTER PROC usp_WithdrawMoney( @accountId int,
								@money money)
AS
BEGIN
DECLARE @oldSum money
SET @oldSum = (SELECT Balance
			FROM Accounts
			WHERE ID = @accountId)

DECLARE @newSUM money
SET @newSUM = @oldSum - @money

IF(@newSUM < 0)
	BEGIN
	SET @newSUM = 0
	END

UPDATE Accounts 
SET Balance = @newSUM
WHERE ID = CAST(@accountID AS int)

END
GO

EXEC usp_WithdrawMoney 10, 50.0
GO

-----------------

 ALTER PROC usp_DepositMoney( @accountId int,
								@money money)
AS
BEGIN
DECLARE @oldSum money
SET @oldSum = (SELECT Balance
			FROM Accounts
			WHERE ID = @accountId)

DECLARE @newSUM money
SET @newSUM = @oldSum + @money

UPDATE Accounts 
SET Balance = @newSUM
WHERE ID = CAST(@accountID AS int)

END
GO

EXEC usp_DepositMoney 10, 50.0
GO

------------------------------------------------------------------------------
--6.Create another table – Logs(LogID, AccountID, OldSum, NewSum). 
--Add a trigger to the Accounts table that enters a new entry into the 
--Logs table every time the sum on an account changes.
CREATE TABLE Logs(
					LogID INT IDENTITY,
					AccountID INT,
					OldSum money,
					NewSum money
					CONSTRAINT PK_LogID PRIMARY KEY(logID)
					CONSTRAINT FK_AccountID FOREIGN KEY(AccountID)
											REFERENCES Accounts(ID))
GO

ALTER TRIGGER tr_LogBalanceChanges 
ON Accounts
FOR UPDATE
AS
	BEGIN
		INSERT INTO Logs
			SELECT i.ID,
				   d.Balance,
				   i.Balance
		FROM inserted i
		JOIN deleted d
		ON d.ID = i.ID
	END
GO

EXEC usp_DepositMoney 10, 50.0
GO

-----------------------------------------------------------------------------

--7. Define a function in the database TelerikAcademy that returns all Employee's 
--names (first or middle or last name) and all town's names that are comprised of 
--given set of letters. Example 'oistmiahf' will return 'Sofia', 'Smith', … but not
-- 'Rob' and 'Guy'.
 
-----------------------------------------------------------------------------

--8.Using database cursor write a T-SQL script that scans all employees and
 --their addresses and prints all pairs of employees that live in the same town.


DECLARE empCursor CURSOR READ_ONLY 
FOR
  SELECT e.FirstName, e.LastName, t.Name, b.FirstName, b.LastName
  FROM Employees e
	JOIN Addresses a
	ON a.AddressID = e.AddressID
	JOIN Towns t
	ON t.TownID = a.TownID,
	 Employees b
	JOIN Addresses ad
	ON b.AddressID = ad.AddressID
	JOIN Towns t2
	ON ad.TownID = t2.TownID
	WHERE t.Name = t2.Name
	  AND e.EmployeeID <> b.EmployeeID
	ORDER BY e.FirstName, b.FirstName

OPEN empCursor
DECLARE @firstName char(20), @lastName char(20), @town char(20),
		 @firstName1 char(20), @lastName1 char(20)
FETCH NEXT FROM empCursor INTO @firstName, @lastName, @town, @firstName1, @lastName1

WHILE @@FETCH_STATUS = 0
  BEGIN
    PRINT @firstName + ' ' + @lastName + '-' + @town + ' ' + @firstName1 + ' ' + @lastName1
    FETCH NEXT FROM empCursor 
    INTO @firstName, @lastName, @town, @firstName1, @lastName1
  END

CLOSE empCursor
DEALLOCATE empCursor
GO

----------------------------------------------------------------------------------------
