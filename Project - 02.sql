-- Restore the AdventureWorks2017.bak backup file (that exist in the project folder) on your local database server 
-- and answer the following questions on both the TSQLV4 and AdventureWorks2017 databases.
-- at first, you need to know the AdventureWorks2017 database data model to be able to answer the questions.

USE AdventureWorks2017

-- 1
-- You are given the following query:
SELECT * --country, region, city
FROM HumanResources.Employee

UNION ALL

SELECT country, region, city
FROM Production.Suppliers;

-- You are asked to add logic to the query 
-- such that it would guarantee that the rows from Employees
-- would be returned in the output before the rows from Suppliers,
-- and within each segment, the rows should be sorted
-- by country, region, city
-- Tables involved: TSQLV4 database, Employees and Suppliers tables

--Desired output
country         region          city
--------------- --------------- ---------------
UK              NULL            London
UK              NULL            London
UK              NULL            London
UK              NULL            London
USA             WA              Kirkland
USA             WA              Redmond
USA             WA              Seattle
USA             WA              Seattle
USA             WA              Tacoma
Australia       NSW             Sydney
Australia       Victoria        Melbourne
Brazil          NULL            Sao Paulo
Canada          Québec          Montréal
Canada          Québec          Ste-Hyacinthe
Denmark         NULL            Lyngby
Finland         NULL            Lappeenranta
France          NULL            Annecy
France          NULL            Montceau
France          NULL            Paris
Germany         NULL            Berlin
Germany         NULL            Cuxhaven
Germany         NULL            Frankfurt
Italy           NULL            Ravenna
Italy           NULL            Salerno
Japan           NULL            Osaka
Japan           NULL            Tokyo
Netherlands     NULL            Zaandam
Norway          NULL            Sandvika
Singapore       NULL            Singapore
Spain           Asturias        Oviedo
Sweden          NULL            Göteborg
Sweden          NULL            Stockholm
UK              NULL            London
UK              NULL            Manchester
USA             LA              New Orleans
USA             MA              Boston
USA             MI              Ann Arbor
USA             OR              Bend

(38 row(s) affected)

-- 2
-- The following query against the Sales.OrderValues view returns
-- distinct values and their associated row numbers
USE TSQLV4;

SELECT val, ROW_NUMBER() OVER(ORDER BY val) AS rownum
FROM Sales.OrderValues
GROUP BY val;

-- Can you think of an alternative way to achieve the same task?
-- Tables involved: TSQLV4 database, Sales.OrderValues view

-- Desired output:
val       rownum
--------- -------
12.50     1
18.40     2
23.80     3
28.00     4
30.00     5
33.75     6
36.00     7
40.00     8
45.00     9
48.00     10
...
12615.05  793
15810.00  794
16387.50  795

(795 row(s) affected)

-- 3
-- میانگین فاصله زمانی بین تمام سفارش های هر مشتری که حداقل درسال 2015 تعداد 10 سفارش ثبت کرده باشد را به روز حساب کنید

-- Desired output:
custid		contactname				AVGDifDay
----------- ----------------------- ---------
87			Ludwig, Michael			44
35			Langohr, Kris			38
37			Óskarsson, Jón Harry	33
5			Higginbotham, Tom		33
51			Taylor, Maurice			31
63			Veronesi, Giorgio		22
20			Kane, John				22
71			Navarro, Tomás			19

(8 row(s) affected)

-- 4
-- سفارشات مشتریانی را برگردانید که اختلاف بین سفارشاتشان بیشتر از 15 روز است

-- Desired output:
custid		contactname				orderdate		DiffDay
----------- ----------------------- -------------- ------------
1			Allen, Michael			2015-10-03		39
1			Allen, Michael			2016-01-15		94
1			Allen, Michael			2016-03-16		61
1			Allen, Michael			2016-04-09		24
2			Hassall, Mark			2015-08-08		324
2			Hassall, Mark			2015-11-28		112
2			Hassall, Mark			2016-03-04		97
3			Strome, David			2015-04-15		139
3			Strome, David			2015-05-13		28
3			Strome, David			2015-06-19		37
3			Strome, David			2015-09-22		95
3			Strome, David			2016-01-28		125
4			Cunningham, Conor		2014-12-16		31
4			Cunningham, Conor		2015-02-21		67
4			Cunningham, Conor		2015-06-04		103
4			Cunningham, Conor		2015-10-16		134
4			Cunningham, Conor		2015-11-14		29
4			Cunningham, Conor		2015-12-08		21
4			Cunningham, Conor		2015-12-24		16
4			Cunningham, Conor		2016-02-02		40
...

(544 row(s) affected)

-- 5
-- سفارشات کارمندانی را برگردانید که اختلاف بین سفارشاتشان بیشتر از 15 روز است

-- Desired output:
empid		EmployeeName		orderdate		DiffDay
----------- ------------------- -------------- ------------
1			Sara Davis			2014-10-29		20
1			Sara Davis			2015-02-21		46
1			Sara Davis			2015-04-16		21
1			Sara Davis			2015-09-02		20
1			Sara Davis			2015-12-11		22
2			Don Funk			2014-09-02		19
2			Don Funk			2014-10-11		17
2			Don Funk			2014-10-28		17
2			Don Funk			2014-11-29		25
2			Don Funk			2015-02-25		34
2			Don Funk			2015-05-19		25
2			Don Funk			2015-06-30		20
2			Don Funk			2015-07-30		20
2			Don Funk			2015-09-04		30
2			Don Funk			2015-11-03		31
2			Don Funk			2015-12-16		22
2			Don Funk			2016-02-26		24
3			Judy Lew			2014-09-19		34
3			Judy Lew			2014-11-05		19
3			Judy Lew			2015-01-09		17
...

(86 row(s) affected)

-- 6
-- CREATE a Stored Procedure that return Orders and user can filter on these fields:
-- Orderdate Between @DateFrom and @DateTo (required),
-- Customer Country = @Country (Optional),
-- Employee Full Name = @EmpName (Optional),
-- difference between requireddate and orderdate less than @Days (required),
-- and return these fields:
-- Sales.Orders: orderdate, requireddate, shipname, shipcountry, shipcity
-- Sales.Customers: contactname, country
-- HR.Employees: Employee Full Name
-- Sales.Shippers: companyname

-- Desired output for this Execute:
-- EXEC Sales.OrderReport @DateFrom = '2014-08-06', -- date
--                       @DateTo = '2014-09-04',   -- date
--                       @Country = NULL,          -- nvarchar(15)
--                       @EmpName = NULL,          -- nvarchar(30)
--                       @Days = 30                -- int

orderdate	requireddate	shipname			shipcountry	shipcity		contactname			country		FullName		companyname
----------- --------------- ------------------- ----------- --------------- ------------------- ----------- --------------- ------------
2014-08-06	2014-09-03		Ship to 85-B		France		Reims			Elliott, Patrick	France		Paul Suurs		Shipper GVSUA
2014-08-07	2014-09-04		Ship to 49-A		Italy		Bergamo			Duerr, Bernard		Italy		Sara Davis		Shipper GVSUA
2014-08-08	2014-08-22		Ship to 80-C		Mexico		México D.F.		Toh, Karen			Mexico		Maria Cameron	Shipper ZHISN
2014-08-09	2014-09-06		Ship to 52-A		Germany		Leipzig			Natarajan, Mrina	Germany		Don Funk		Shipper ZHISN
2014-08-12	2014-09-09		Ship to 5-C			Sweden		Luleå			Higginbotham, Tom	Sweden		Maria Cameron	Shipper ETYNR
2014-08-13	2014-09-10		Ship to 44-A		Germany		Frankfurt a.M.	Louverdis, George	Germany		Maria Cameron	Shipper ETYNR
2014-08-14	2014-09-11		Ship to 5-B			Sweden		Luleå			Higginbotham, Tom	Sweden		Don Funk		Shipper GVSUA
2014-08-14	2014-08-28		Ship to 69-A		Spain		Madrid			Troup, Carol		Spain		Yael Peled		Shipper GVSUA
2014-08-15	2014-09-12		Ship to 69-B		Spain		Madrid			Troup, Carol		Spain		Yael Peled		Shipper GVSUA
2014-08-16	2014-09-13		Ship to 46-A		Venezuela	Barquisimeto	Neves, Paulo		Venezuela	Judy Lew		Shipper ZHISN
2014-08-19	2014-09-16		Ship to 44-A		Germany		Frankfurt a.M.	Louverdis, George	Germany		Yael Peled		Shipper GVSUA
2014-08-20	2014-09-17		Ship to 63-B		Germany		Cunewalde		Veronesi, Giorgio	Germany		Sara Davis		Shipper ETYNR
2014-08-21	2014-09-18		Ship to 63-B		Germany		Cunewalde		Veronesi, Giorgio	Germany		Maria Cameron	Shipper ZHISN
2014-08-22	2014-09-19		Ship to 67-A		Brazil		Rio de Janeiro	Garden, Euan		Brazil		Maria Cameron	Shipper ZHISN
2014-08-23	2014-09-20		Ship to 66-C		Italy		Reggio Emilia	Voss, Florian		Italy		Yael Peled		Shipper GVSUA
2014-08-26	2014-09-23		Destination DLEUN	UK			London			Jaffe, David		UK			Russell King	Shipper ZHISN
2014-08-27	2014-09-24		Destination HQZHO	Brazil		Sao Paulo		Richardson, Shawn	Brazil		Maria Cameron	Shipper GVSUA
2014-08-27	2014-09-24		Ship to 61-A		Brazil		Rio de Janeiro	Meisels, Josh		Brazil		Paul Suurs		Shipper ETYNR
2014-08-28	2014-09-25		Ship to 81-A		Brazil		Sao Paulo		Edwards, Josh		Brazil		Sara Davis		Shipper ETYNR
2014-08-29	2014-09-26		Ship to 80-B		Mexico		México D.F.		Toh, Karen			Mexico		Sara Davis		Shipper ZHISN
2014-08-30	2014-09-27		Ship to 65-A		USA			Albuquerque		Moore, Michael		USA			Yael Peled		Shipper ETYNR
2014-09-02	2014-09-30		Ship to 85-C		France		Reims			Elliott, Patrick	France		Don Funk		Shipper ETYNR
2014-09-03	2014-10-01		Ship to 46-C		Venezuela	Barquisimeto	Neves, Paulo		Venezuela	Paul Suurs		Shipper GVSUA

(23 row(s) affected)
