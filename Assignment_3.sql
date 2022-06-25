USE Northwind
GO

-- 1. Create a view named “view_product_order_[your_last_name]”, list all products and total ordered quantity for that product.
CREATE VIEW view_product_order_Jing
AS
SELECT P.ProductID, ProductName, COUNT(OD.Quantity) CountQuantity
FROM Products P JOIN [Order Details] OD ON OD.ProductID = P.ProductID
GROUP BY P.ProductID, P.ProductName

SELECT *
FROM view_product_order_Jing

-- 2. Create a stored procedure “sp_product_order_quantity_[your_last_name]” that accept product id as an input and total quantities of order as output parameter.
CREATE PROC sp_product_order_quantity_Jing
@id int,
@total int out
AS
BEGIN
SELECT @id = view_product_order_Jing.ProductID, @total = view_product_order_Jing.CountQuantity
FROM view_product_order_Jing
WHERE view_product_order_Jing.ProductID = @id
END

DECLARE @id int, @total int
EXEC sp_product_order_quantity_Jing 2, @total out
PRINT @total

-- 3. Create a stored procedure “sp_product_order_city_[your_last_name]” that accept product name as an input and top 5 cities that ordered most that product combined with the total quantity of that product ordered from that city as output.
CREATE PROC sp_product_order_city_Jing
@name varchar(20),
@cities varchar(20) out
AS
BEGIN
SELECT @name=T1.productname 
FROM (
SELECT TOP 5 d.ProductID, d.ProductName
FROM (
SELECT p.ProductID,p.ProductName,SUM(od.quantity) TotalQuantity 
FROM Products p inner join [Order Details] od ON p.ProductID = od.ProductID
GROUP BY p.ProductID, p.ProductName) AS D
ORDER BY D.TotalQuantity DESC) T1
LEFT JOIN(
SELECT * 
FROM (SELECT T2.productid, T2.city, RANK() OVER (partition by
productid ORDER BY TotalQuantity2 DESC) RK 
FROM
(SELECT p.ProductID, c.city, SUM(od.quantity) TotalQuantity2
FROM Customers c JOIN orders o ON c.CustomerID= o.CustomerID LEFT JOIN [Order Details] od ON o.OrderID=od.OrderID LEFT JOIN Products p ON od.ProductID=p.ProductID
GROUP BY p.ProductID, c.City ) T2 ) T3
WHERE T3.RK =1 ) T4
ON T1.productid= T4.productid
where T4.city =@cities
end

-- 4. Create 2 new tables “people_your_last_name” “city_your_last_name”. City table has two records: {Id:1, City: Seattle}, {Id:2, City: Green Bay}. People has three records: {id:1, Name: Aaron Rodgers, City: 2}, {id:2, Name: Russell Wilson, City:1}, {Id: 3, Name: Jody Nelson, City:2}. Remove city of Seattle. If there was anyone from Seattle, put them into a new city “Madison”. Create a view “Packers_your_name” lists all people from Green Bay. If any error occurred, no changes should be made to DB. (after test) Drop both tables and view.
CREATE TABLE people_jing(
id int,
name varchar(20),
cityId int
)
INSERT INTO people_jing VALUES(1, 'Aaron Rodgers', 2)
INSERT INTO people_jing VALUES(2, 'Russell Wilson', 1)
INSERT INTO people_jing VALUES(3, ' Jody Nelson', 2)
CREATE TABLE city_jing(
cityId int,
city varchar(20),
)
INSERT INTO city_jing VALUES(1, 'Settle')
INSERT INTO city_jing VALUES(2, 'Green Bay')

CREATE VIEW Packers_jing
AS 
SELECT P.id, P.name
FROM people_jing P JOIN city_jing C ON P.cityId = C.cityId
WHERE C.city = 'Green Bay'
BEGIN TRAN
ROLLBACK
DROP TABLE people_jing
DROP TABLE city_jing
DROP VIEW Packers_jing

-- 5. Create a stored procedure “sp_birthday_employees_[you_last_name]” that creates a new table “birthday_employees_your_last_name” and fill it with all employees that have a birthday on Feb. (Make a screen shot) drop the table. Employee table should not be affected.
CREATE TABLE birthday_employees_jing(
id int,
firstname varchar(20),
lastname varchar(20),
title varchar(30),
titleofcourtesy varchar(25),
birthdate datetime,
hiredate datetime,
photo image
)
CREATE PROC sp_birthday_employees_jing
AS
BEGIN
SELECT EmployeeID, LastName, FirstName, Title, TitleOfCourtesy, BirthDate, HireDate, Photo INTO birthday_employees_jing
FROM Employees
WHERE MONTH(BirthDate) = 2
END
DROP TABLE birthday_employees_jing

-- 6. How do you make sure two tables have the same data?
-- I will store the total data count of the two tables and do a union and check that if the data count of the two tables is different than the union table, their data is not the same.
