-- solutions for AdventureWorks2017 database

USE AdventureWorks2017

-- Solution 1

SELECT country, region, city
FROM  
(
SELECT C.Name AS country, SP.StateProvinceCode AS region, A.City AS city, 0 AS orderid
FROM Person.Address AS A 
	INNER JOIN Person.StateProvince AS SP
		ON A.StateProvinceID = SP.StateProvinceID
	INNER JOIN Person.CountryRegion AS C
		ON SP.CountryRegionCode = C.CountryRegionCode
WHERE A.AddressID IN 
	(
		SELECT BE.AddressID 
		FROM Person.BusinessEntityAddress AS BE
			INNER JOIN HumanResources.Employee AS E 
				ON BE.BusinessEntityID = E.BusinessEntityID	
	)

UNION ALL

SELECT C.Name AS country, SP.StateProvinceCode AS region, A.City AS city, 1 AS orderid
FROM Person.Address AS A 
	INNER JOIN Person.StateProvince AS SP
		ON A.StateProvinceID = SP.StateProvinceID
	INNER JOIN Person.CountryRegion AS C
		ON SP.CountryRegionCode = C.CountryRegionCode
WHERE A.AddressID IN 
	(
		SELECT BE.AddressID 
		FROM Person.BusinessEntityAddress AS BE
			INNER JOIN Purchasing.Vendor AS V 
				ON BE.BusinessEntityID = V.BusinessEntityID	
	)
) AS Persons
ORDER BY orderid, country, region, city;



----------------------------------------------------------------------------------

-- Solution 2

WITH OrderValuesCTE
AS
(
SELECT  O.SalesOrderID, O.CustomerID, O.SalesPersonID, O.ShipMethodID, 
		O.OrderDate, O.DueDate, O.ShipDate, OD.OrderQty, OD.LineTotal
FROM    Sales.SalesOrderHeader AS O INNER JOIN
           Sales.SalesOrderDetail AS OD ON O.SalesOrderID = OD.SalesOrderID
)
SELECT LineTotal, DENSE_RANK() OVER(ORDER BY LineTotal) AS rownum
FROM OrderValuesCTE
GROUP BY LineTotal


----------------------------------------------------------------------------------

-- Solution 3

-- There is no orders in 2015, so I concidered year 2014 instead of year 2015

;WITH DIFDAYOrders
AS
(
SELECT CustomerID, orderdate , 
		ABS (DATEDIFF (DAY, orderdate, LAG(orderdate) OVER (PARTITION BY CustomerID
														ORDER BY orderdate))) AS DifDay
FROM Sales.SalesOrderHeader
WHERE CustomerID IN (
	SELECT CustomerID
	FROM Sales.SalesOrderHeader
	WHERE orderdate >= '20140101' AND orderdate < '20150101'
	GROUP BY CustomerID
	HAVING COUNT(*) >=10
	) 
),
CustomerInfo
AS
(

SELECT C.CustomerID, P.FirstName + ' ' + P.LastName AS contactname 
FROM Sales.Customer AS C
	INNER JOIN Person.Person AS P
		ON C.PersonID = P.BusinessEntityID

UNION ALL

SELECT C.CustomerID, S.Name AS contactname 
FROM Sales.Customer AS C
	INNER JOIN Sales.Store AS S
		ON C.StoreID = S.BusinessEntityID
WHERE C.PersonID IS NULL
)
SELECT D.CustomerID, C.contactname, AVG(D.DifDay) AS AVGDifDay
FROM	DIFDAYOrders AS D
		INNER JOIN CustomerInfo AS C
			ON D.CustomerID = C.CustomerID
GROUP BY D.CustomerID, C.contactname 
ORDER BY AVGDifDay DESC


----------------------------------------------------------------------------------

-- Solution 4

;WITH OrdersCTE
AS
(
SELECT	CustomerID, orderdate, 
		ABS (DATEDIFF (DAY, orderdate, LAG (orderdate,1) OVER (PARTITION BY CustomerID
															  ORDER BY orderdate))) AS DiffDay
FROM Sales.SalesOrderHeader
),
CustomerInfo
AS
(

SELECT C.CustomerID, P.FirstName + ' ' + P.LastName AS contactname 
FROM Sales.Customer AS C
	INNER JOIN Person.Person AS P
		ON C.PersonID = P.BusinessEntityID

UNION ALL

SELECT C.CustomerID, S.Name AS contactname 
FROM Sales.Customer AS C
	INNER JOIN Sales.Store AS S
		ON C.StoreID = S.BusinessEntityID
WHERE C.PersonID IS NULL
)
SELECT C.CustomerID, C.contactname, CAST (O.orderdate AS DATE) AS orderdate, O.DiffDay
FROM OrdersCTE AS O
		INNER JOIN CustomerInfo AS C 
			ON O.CustomerID = C.CustomerID
WHERE O.DiffDay>15

----------------------------------------------------------------------------------

-- Solution 5

;WITH OrdersCTE
AS
(
SELECT	SalesPersonID, orderdate, 
		ABS (DATEDIFF (DAY, orderdate, LAG (orderdate) OVER (PARTITION BY SalesPersonID
															  ORDER BY orderdate))) AS DiffDay
FROM Sales.SalesOrderHeader
)
SELECT	E.BusinessEntityID, E.firstname + ' ' + E.lastname AS EmployeeName, 
		CAST (O.orderdate AS DATE) AS orderdate, O.DiffDay
FROM OrdersCTE AS O
		INNER JOIN Person.Person AS E 
			ON O.SalesPersonID = E.BusinessEntityID
WHERE O.DiffDay>15
ORDER BY E.BusinessEntityID, O.orderdate 


----------------------------------------------------------------------------------

-- Solution 6

CREATE OR ALTER PROCEDURE Sales.OrderReport 
	@DateFrom DATE, -- Orderdate (required)
	@DateTo DATE, -- Orderdate (required)
	@Country NVARCHAR(15) = NULL, -- Customer Country (Optional)
	@EmpName NVARCHAR(30) = NULL, -- Employee Full Name (Optional)
	@Days INT -- difference between requireddate and orderdate less than @Days (required)
AS

/*
DECLARE @DateFrom DATE = '2014-08-06',
                       @DateTo DATE = '2014-09-04',
                       @Country NVARCHAR(15) = NULL,
                       @EmpName NVARCHAR(30) = NULL,
                       @Days INT= 30
*/

BEGIN

	WITH CustomerInfo
	AS
	(
	SELECT C.CustomerID, P.FirstName + ' ' + P.LastName AS contactname
	FROM Sales.Customer AS C
		INNER JOIN Person.Person AS P
			ON C.PersonID = P.BusinessEntityID

	UNION ALL

	SELECT C.CustomerID, S.Name AS contactname 
	FROM Sales.Customer AS C
		INNER JOIN Sales.Store AS S
			ON C.StoreID = S.BusinessEntityID
	WHERE C.PersonID IS NULL
	)
	SELECT
	O.orderdate --Sales.SalesOrderHeader: orderdate
	, O.DueDate -- Sales.DueDate: requireddate
	, S.Name -- Purchasing.ShipMethod: shipname
	--, O.shipcountry -- shipcountry
	--, O.shipcity -- shipcity
	, C.contactname -- Sales.Customers: contactname
	--, C.country -- Customers country
	, E.firstname + ' ' + E.lastname AS FullName -- Person.Person: Employee Full Name
	--, S.companyname -- Shipper companyname
	FROM 
		Sales.SalesOrderHeader AS O
		INNER JOIN CustomerInfo AS C
			ON O.CustomerID = C.CustomerID
		INNER JOIN Person.Person AS E
			ON O.SalesPersonID = E.BusinessEntityID
		INNER JOIN Purchasing.ShipMethod AS S
			ON O.ShipMethodID = S.ShipMethodID
	WHERE O.orderdate >= @DateFrom 
		AND O.orderdate < @DateTo 
		--AND (@Country IS NULL OR C.Country = @Country)
		AND (@EmpName IS NULL OR E.firstname + ' ' + E.lastname = @EmpName)
		AND DATEDIFF (DAY, O.DueDate , O.orderdate) < @Days
END


-- Test PROC
EXEC Sales.OrderReport  @DateFrom = '2014-08-06', -- date
                         @DateTo = '2014-09-04',   -- date
                         @Country = NULL,          -- nvarchar(15)
                         @EmpName = NULL,          -- nvarchar(30)
                         @Days = 30                -- int

GO;
