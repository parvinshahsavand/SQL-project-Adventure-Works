-- solutions for TSQLV4 database

USE TSQLV4

-- Solution 1

SELECT country, region, city 
FROM  
(
	SELECT country, region, city, 0 AS orderid
	FROM HR.Employees

	UNION ALL

	SELECT country, region, city, 1 AS orderid
	FROM Production.Suppliers
) AS Persons
ORDER BY orderid, country, region, city;

----------------------------------------------------------------------------------

-- Solution 2

SELECT DISTINCT val, DENSE_RANK() OVER(ORDER BY val) AS rownum
FROM Sales.OrderValues
GROUP BY val;


----------------------------------------------------------------------------------

--Solution 3

;WITH DIFDAYOrders
AS
(
SELECT custid, orderdate , 
		ABS (DATEDIFF (DAY, orderdate, LAG(orderdate) OVER (PARTITION BY custid
														ORDER BY orderdate))) AS DifDay
FROM Sales.Orders
WHERE custid IN (
	SELECT custid
	FROM Sales.Orders
	WHERE orderdate >= '20150101' AND orderdate < '20160101'
	GROUP BY custid
	HAVING COUNT(*) >=10
	) 
)
SELECT D.custid, C.contactname, AVG(D.DifDay) AS AVGDifDay
FROM	DIFDAYOrders AS D
		INNER JOIN Sales.Customers AS C
			ON D.custid = C.custid
GROUP BY D.custid, C.contactname 
ORDER BY AVGDifDay DESC

----------------------------------------------------------------------------------

--Solution 4

;WITH OrdersCTE
AS
(
SELECT	custid, orderdate, 
		ABS (DATEDIFF (DAY, orderdate, LAG (orderdate,1) OVER (PARTITION BY custid
															  ORDER BY orderdate))) AS DiffDay
FROM Sales.Orders
)
SELECT C.custid, C.contactname, O.orderdate, O.DiffDay
FROM OrdersCTE AS O
		INNER JOIN Sales.Customers AS C 
			ON O.custid = C.custid
WHERE O.DiffDay>15


----------------------------------------------------------------------------------

--Solution 5

;WITH OrdersCTE
AS
(
SELECT	empid, orderdate, 
		ABS (DATEDIFF (DAY, orderdate, LAG (orderdate) OVER (PARTITION BY empid
															  ORDER BY orderdate))) AS DiffDay
FROM Sales.Orders
)
SELECT	E.empid, E.firstname + ' ' + E.lastname AS EmployeeName, 
		O.orderdate, O.DiffDay
FROM OrdersCTE AS O
		INNER JOIN HR.Employees AS E 
			ON O.empid = E.empid
WHERE O.DiffDay>15
ORDER BY E.empid, O.orderdate 


----------------------------------------------------------------------------------

-- Solution 6
CREATE OR ALTER PROCEDURE Sales.OrderReport2 
	@DateFrom date, -- Orderdate
	@DateTo date, -- Orderdate
	@Country nvarchar(15) = NULL, -- Customer Country
	@EmpName nvarchar(30) = NULL, -- Employee Full Name
	@Days int -- difference between requireddate and orderdate less than @Days
AS

--DECLARE @DateFrom date = '2014-08-06',
--                       @DateTo date = '2014-09-04',   -- date
--                       @Country nvarchar(15) = NULL,          -- nvarchar(15)
--                       @EmpName nvarchar(30) = NULL,          -- nvarchar(30)
--                       @Days int= 30                -- int

BEGIN
	SELECT 
	O.orderdate --Sales.Orders: orderdate
	, O.requireddate -- Sales.Orders: requireddate
	, O.shipname -- Sales.Orders: shipname
	, O.shipcountry -- Sales.Orders: shipcountry
	, O.shipcity -- Sales.Orders: shipcity
	, C.contactname -- Sales.Customers: contactname
	, C.country -- Sales.Customers: country
	, E.firstname + ' ' + E.lastname AS FullName -- HR.Employees: Employee Full Name
	, S.companyname -- Sales.Shippers: companyname
	FROM 
		Sales.Orders AS O
		INNER JOIN Sales.Customers AS C
			ON O.custid = C.custid
		INNER JOIN HR.Employees AS E
			ON O.empid = E.empid
		INNER JOIN Sales.Shippers AS S
			ON O.shipperid = S.shipperid
	WHERE O.orderdate >= @DateFrom 
		AND O.orderdate < @DateTo 
		AND (@Country IS NULL OR C.Country = @Country)
		AND (@EmpName IS NULL OR E.firstname + ' ' + E.lastname = @EmpName)
		AND DATEDIFF (DAY, O.requireddate , O.orderdate) < @Days
END


-- Test PROC
EXEC Sales.OrderReport2  @DateFrom = '2014-08-06', -- date
                         @DateTo = '2014-09-04',   -- date
                         @Country = NULL,          -- nvarchar(15)
                         @EmpName = NULL,          -- nvarchar(30)
                         @Days = 30                -- int

GO;
