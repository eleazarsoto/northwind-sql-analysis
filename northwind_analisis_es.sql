-- ============================================================
-- ANÁLISIS DE LA BASE DE DATOS NORTHWIND
-- Eleazar Soto | Portafolio de Análisis de Datos
-- github.com/eleazarsoto
-- ============================================================
-- Base de datos: Northwind (SQLite)
-- Tablas: Customers, Orders, Products, Categories, Suppliers,
--         Employees, Shippers, Order Details
-- Registros: 830 pedidos | 93 clientes | 77 productos | 9 empleados
-- ============================================================


-- ============================================================
-- NIVEL 1 — SELECT + FROM + WHERE + IS NULL
-- ============================================================

-- 01.
-- Muestra una tabla con todas las categorías y sus descripciones [8 filas].
SELECT CategoryName, Description
FROM Categories;


-- 02.
-- Muestra los nombres de contacto, IDs de cliente y nombres de compañía
-- de todos los clientes de Londres [6 filas].
SELECT ContactName, CustomerID, CompanyName
FROM Customers
WHERE City = 'London';


-- 03.
-- Muestra todas las columnas disponibles de los proveedores que tienen número de FAX [13 filas].
SELECT *
FROM Suppliers
WHERE Fax IS NOT NULL;


-- 04.
-- Cuenta el número total de pedidos realizados en 1997 [Resultado: 408].
SELECT COUNT(*) AS Total_Orders_1997
FROM Orders
WHERE OrderDate LIKE '1997%';


-- 05.
-- Muestra todos los contactos que son dueños de negocio de México, Noruega y Alemania [5 filas].
SELECT ContactName, ContactTitle, Country
FROM Customers
WHERE ContactTitle = 'Owner'
AND Country IN ('Mexico', 'Norway', 'Germany');


-- 06.
-- Muestra la lista de productos descontinuados [8 filas].
SELECT ProductName, UnitPrice, Discontinued
FROM Products
WHERE Discontinued = '1';


-- 07.
-- Muestra las categorías que empiezan con 'Co' [2 filas].
SELECT CategoryName
FROM Categories
WHERE CategoryName LIKE 'Co%';


-- 08.
-- Muestra los nombres de compañía, ciudades, países y códigos postales de los proveedores
-- cuya dirección contiene la palabra 'rue', ordenados alfabéticamente por nombre de compañía [5 filas].
SELECT CompanyName, City, Country, PostalCode
FROM Suppliers
WHERE Address LIKE '%rue%'
ORDER BY CompanyName ASC;


-- 09.
-- Muestra los 10 pedidos principales junto con su total de unidades vendidas [10 filas].
SELECT OrderID, SUM(Quantity) AS Total_Units
FROM 'Order Details'
GROUP BY OrderID
ORDER BY SUM(Quantity) DESC
LIMIT 10;


-- 10.
-- Muestra la lista de productos dentro de la categoría 'Condiments' [12 filas].
SELECT p.ProductName, c.CategoryName
FROM Products p
JOIN Categories c ON p.CategoryID = c.CategoryID
WHERE c.CategoryName = 'Condiments';


-- ============================================================
-- NIVEL 2 — JOINS + LEFT JOIN + FUNCIONES DE FECHA
-- ============================================================

-- 11.
-- Muestra todos los empleados que tenían 40 años o más al momento de su contratación [3 filas].
SELECT FirstName || ' ' || LastName AS FullName,
       BirthDate,
       HireDate
FROM Employees
WHERE date(BirthDate, '+40 years') <= date(HireDate);


-- 12.
-- Muestra los productos con un total de unidades en inventario mayor a 100.
-- Nombra el campo total como 'TotalUnits' [10 filas].
SELECT ProductName, UnitsInStock AS TotalUnits
FROM Products
WHERE UnitsInStock > 100;


-- 13.
-- Muestra los nombres de contacto y direcciones de los clientes
-- cuyos pedidos fueron enviados vía 'Speedy Express' [249 filas].
SELECT c.ContactName, c.Address
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN Shippers sh ON o.ShipVia = sh.ShipperID
WHERE sh.CompanyName = 'Speedy Express';


-- 14.
-- Muestra la lista de clientes que nunca han realizado un pedido [4 filas].
SELECT c.ContactName
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderID IS NULL;


-- 15.
-- Muestra los empleados y clientes involucrados en pedidos enviados a Bruselas
-- vía 'Speedy Express' [2 filas].
SELECT DISTINCT e.FirstName, e.LastName, c.ContactName
FROM Employees e
JOIN Orders o ON e.EmployeeID = o.EmployeeID
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN Shippers sh ON o.ShipVia = sh.ShipperID
WHERE o.ShipCity = 'Bruxelles'
AND sh.CompanyName = 'Speedy Express';


-- 16.
-- Muestra el puesto y el nombre completo de los empleados que vendieron
-- al menos una unidad de 'Queso Cabrales' o 'Tofu' [9 filas].
SELECT DISTINCT e.Title, e.FirstName || ' ' || e.LastName AS FullName
FROM Employees e
JOIN Orders o ON e.EmployeeID = o.EmployeeID
JOIN 'Order Details' od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
WHERE p.ProductName IN ('Queso Cabrales', 'Tofu');


-- 17.
-- Muestra el nombre completo de los empleados y el apellido de su gerente.
-- Incluye a los empleados sin gerente (valores NULL) [9 filas].
SELECT e.FirstName || ' ' || e.LastName AS FullName,
       m.LastName AS ManagerLastName
FROM Employees e
LEFT JOIN Employees m ON e.ReportsTo = m.EmployeeID;


-- 18.
-- Muestra los nombres de contacto, nombres de producto y compañías proveedoras (sin duplicados)
-- de los clientes de Londres que compraron productos de 'Karkki Oy' o 'Pavlova, Ltd.' [9 filas].
SELECT DISTINCT c.ContactName, p.ProductName, s.CompanyName
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN 'Order Details' od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
JOIN Suppliers s ON p.SupplierID = s.SupplierID
WHERE c.City = 'London'
AND s.CompanyName IN ('Karkki Oy', 'Pavlova, Ltd.');


-- 19.
-- Muestra los nombres de producto (sin duplicados) de los pedidos donde el cliente
-- o el empleado involucrado es de Londres [76 filas].
SELECT DISTINCT p.ProductName
FROM Products p
JOIN 'Order Details' od ON p.ProductID = od.ProductID
JOIN Orders o ON od.OrderID = o.OrderID
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN Employees e ON o.EmployeeID = e.EmployeeID
WHERE c.City = 'London' OR e.City = 'London';


-- 20.
-- Muestra todos los clientes que han comprado productos con precio unitario menor a 3 [26 filas].
SELECT DISTINCT c.ContactName
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN 'Order Details' od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
WHERE p.UnitPrice < 3;


-- ============================================================
-- NIVEL 3 — SUBCONSULTAS + SELF JOIN + FILTROS AVANZADOS
-- ============================================================

-- 21.
-- Muestra los nombres completos de los empleados con mayor antigüedad
-- que cualquier empleado con sede en Londres [4 filas].
SELECT FirstName || ' ' || LastName AS FullName
FROM Employees
WHERE date(HireDate) < (
    SELECT MIN(date(HireDate))
    FROM Employees
    WHERE City = 'London'
);


-- 22.
-- Muestra el nombre completo y la ciudad de los empleados que han vendido
-- a clientes de su misma ciudad [6 filas].
SELECT DISTINCT e.FirstName || ' ' || e.LastName AS FullName, e.City
FROM Employees e
JOIN Orders o ON e.EmployeeID = o.EmployeeID
JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE e.City = c.City;


-- 23.
-- Muestra el precio unitario promedio por categoría de producto [8 filas].
SELECT c.CategoryName, AVG(p.UnitPrice) AS AvgPrice
FROM Products p
JOIN Categories c ON p.CategoryID = c.CategoryID
GROUP BY c.CategoryName;


-- 24.
-- Muestra las compañías proveedoras que suministran más de 4 productos [2 filas].
SELECT s.CompanyName, COUNT(*) AS TotalProductos
FROM Suppliers s
JOIN Products p ON s.SupplierID = p.SupplierID
GROUP BY s.CompanyName
HAVING COUNT(*) > 4;


-- 25.
-- Muestra los IDs de empleado, nombres completos y el conteo de productos distintos vendidos.
-- Ordena por ID de empleado de forma ascendente [9 filas].
SELECT e.EmployeeID,
       e.FirstName || ' ' || e.LastName AS FullName,
       COUNT(DISTINCT od.ProductID) AS TotalProducts
FROM Employees e
JOIN Orders o ON e.EmployeeID = o.EmployeeID
JOIN 'Order Details' od ON o.OrderID = od.OrderID
GROUP BY e.EmployeeID
ORDER BY e.EmployeeID ASC;


-- 26.
-- Muestra los IDs de empleado, nombres completos y el ingreso total generado por cada uno.
-- Ordena por ID de empleado de forma ascendente [9 filas].
SELECT e.EmployeeID,
       e.FirstName || ' ' || e.LastName AS FullName,
       SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalSales
FROM Employees e
JOIN Orders o ON e.EmployeeID = o.EmployeeID
JOIN 'Order Details' od ON o.OrderID = od.OrderID
GROUP BY e.EmployeeID
ORDER BY e.EmployeeID ASC;


-- ============================================================
-- NIVEL 4 — RANKING + TOP N + ANÁLISIS DE NEGOCIO
-- ============================================================

-- 27.
-- Muestra las 5 ciudades de envío con mayores ingresos totales [5 filas].
SELECT o.ShipCity,
       SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalSales
FROM Orders o
JOIN 'Order Details' od ON o.OrderID = od.OrderID
GROUP BY o.ShipCity
ORDER BY TotalSales DESC
LIMIT 5;


-- 28.
-- Muestra los 5 productos con más unidades vendidas [5 filas].
SELECT p.ProductName, SUM(od.Quantity) AS TotalUnits
FROM Products p
JOIN 'Order Details' od ON p.ProductID = od.ProductID
GROUP BY p.ProductName
ORDER BY TotalUnits DESC
LIMIT 5;


-- 29.
-- Muestra los clientes (sin duplicados) que han comprado productos
-- de la categoría 'Beverages' [83 filas].
SELECT DISTINCT c.ContactName
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN 'Order Details' od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
JOIN Categories ca ON p.CategoryID = ca.CategoryID
WHERE ca.CategoryName = 'Beverages';


-- 30.
-- Muestra un ranking de proveedores por número de productos distintos vendidos [29 filas].
SELECT s.CompanyName, COUNT(DISTINCT od.ProductID) AS TotalProductos
FROM Suppliers s
JOIN Products p ON s.SupplierID = p.SupplierID
JOIN 'Order Details' od ON p.ProductID = od.ProductID
GROUP BY s.CompanyName
ORDER BY TotalProductos DESC;


-- ============================================================
-- NIVEL 5 — ANÁLISIS DE FECHAS + PREGUNTAS DE NEGOCIO
-- ============================================================

-- 31.
-- ¿Cuántos pedidos se realizaron en junio de 1997?
SELECT COUNT(*) AS TotalOrdenes
FROM Orders
WHERE strftime('%Y-%m', OrderDate) = '1997-06';


-- 32.
-- ¿Qué día tuvo el mayor número de pedidos en 1998?
SELECT OrderDate, COUNT(*) AS TotalOrdenes
FROM Orders
WHERE strftime('%Y', OrderDate) = '1998'
GROUP BY OrderDate
ORDER BY TotalOrdenes DESC
LIMIT 1;


-- 33.
-- ¿Qué empleado generó el mayor ingreso total?
SELECT e.EmployeeID,
       e.FirstName || ' ' || e.LastName AS FullName,
       SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalVentas
FROM Employees e
JOIN Orders o ON e.EmployeeID = o.EmployeeID
JOIN 'Order Details' od ON o.OrderID = od.OrderID
GROUP BY e.EmployeeID
ORDER BY TotalVentas DESC
LIMIT 1;


-- 34.
-- ¿Qué país de envío generó el mayor ingreso por fletes?
SELECT ShipCountry, SUM(Freight) AS TotalFlete
FROM Orders
GROUP BY ShipCountry
ORDER BY TotalFlete DESC
LIMIT 1;


-- ============================================================
-- NIVEL 6 — SERIES DE TIEMPO + CASE + VISUALIZACIONES
-- ============================================================

-- 35.
-- Calcula las ventas totales por año.
-- Presentado en formato tabular y gráfica de columnas (ver charts/).
SELECT strftime('%Y', o.OrderDate) AS Year,
       SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalSales
FROM Orders o
JOIN 'Order Details' od ON o.OrderID = od.OrderID
GROUP BY Year
ORDER BY Year ASC;


-- 36.
-- Calcula las ventas totales por mes para 1997.
-- Presentado en formato tabular y gráfica de líneas (ver charts/).
SELECT strftime('%m', o.OrderDate) AS Month,
       SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalSales
FROM Orders o
JOIN 'Order Details' od ON o.OrderID = od.OrderID
WHERE strftime('%Y', o.OrderDate) = '1997'
GROUP BY Month
ORDER BY Month ASC;


-- 37.
-- Calcula las ventas totales por año para la categoría 'Condiments'.
-- Presentado en formato tabular y gráfica de barras (ver charts/).
SELECT strftime('%Y', o.OrderDate) AS Year,
       SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalSales
FROM Orders o
JOIN 'Order Details' od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
JOIN Categories ca ON p.CategoryID = ca.CategoryID
WHERE ca.CategoryName = 'Condiments'
GROUP BY Year
ORDER BY Year ASC;


-- 38.
-- Muestra cuántos pedidos envió cada transportista: Speedy Express,
-- United Package y Federal Shipping.
-- Presentado en formato tabular y gráfica de pastel (ver charts/).
SELECT sh.CompanyName, COUNT(*) AS TotalPedidos
FROM Shippers sh
JOIN Orders o ON sh.ShipperID = o.ShipVia
GROUP BY sh.CompanyName
ORDER BY TotalPedidos DESC;


-- 39.
-- Muestra los ingresos mensuales de 1997 comparando las categorías
-- 'Beverages' y 'Confections'. Cada fila representa un mes,
-- cada columna una categoría.
-- Presentado en formato tabular y gráfica de líneas (ver charts/).
SELECT strftime('%m', o.OrderDate) AS Month,
       SUM(CASE WHEN ca.CategoryName = 'Beverages'
           THEN od.UnitPrice * od.Quantity * (1 - od.Discount)
           ELSE 0 END) AS Beverages,
       SUM(CASE WHEN ca.CategoryName = 'Confections'
           THEN od.UnitPrice * od.Quantity * (1 - od.Discount)
           ELSE 0 END) AS Confections
FROM Orders o
JOIN 'Order Details' od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
JOIN Categories ca ON p.CategoryID = ca.CategoryID
WHERE strftime('%Y', o.OrderDate) = '1997'
AND ca.CategoryName IN ('Beverages', 'Confections')
GROUP BY Month
ORDER BY Month ASC;


-- ============================================================
-- FIN DEL ANÁLISIS NORTHWIND
-- Eleazar Soto | github.com/eleazarsoto
-- ============================================================
