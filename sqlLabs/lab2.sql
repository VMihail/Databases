-- 1 Найти и вывести на экран количество товаров каждого цвета, исключив из поиска товары, цена которых меньше 30.
select Color, count(*) from Production.Product
where ListPrice >= 30
group by Color;

-- 2 Найти и вывести на экран список, состоящий из цветов товаров, таких,
-- что минимальная цена товара данного цвета более 100.
select Color from Production.Product
group by Color
having min(ListPrice) > 100;

-- 3 Найти и вывести на экран номера подкатегорий товаров и количество товаров в каждой категории.
select ProductCategoryID, count(*) from Production.ProductSubcategory
group by ProductCategoryID;

-- 4 Найти и вывести на экран номера товаров и количество фактов продаж
-- данного товара (используется таблица SalesORDERDetail).
select ProductID, count(*) from Sales.SalesOrderDetail
group by ProductID;

-- 5 Найти и вывести на экран номера товаров, которые были куплены более пяти раз.
select ProductID from Sales.SalesOrderDetail
group by ProductID
having count(*) > 5;

-- 6 Найти и вывести на экран номера покупателей, CustomerID, у которых существует более одного чека,
-- SalesORDERID, с одинаковой датой
select CustomerID from Sales.SalesOrderHeader
group by CustomerID
having count(*) > 1;

-- 7 Найти и вывести на экран все номера чеков, на которые приходится более трех продуктов.
select SalesOrderID from Sales.SalesOrderDetail
group by SalesOrderID
having count(*) > 3;

-- 8 Найти и вывести на экран все номера продуктов, которые были куплены более трех раз.
select ProductID, count(*) from Sales.SalesOrderDetail
group by ProductID
having count(*) > 3;

-- 9 Найти и вывести на экран все номера продуктов, которые были куплены или три или пять раз.
select ProductID from Sales.SalesOrderDetail
group by ProductID
having count(*) in (3, 5);

-- 10 Найти и вывести на экран все номера подкатегорий, в которым относится более десяти товаров.
select ProductSubcategoryID from Production.Product
group by ProductSubcategoryID
having count(*) > 10;

-- 11 Найти и вывести на экран номера товаров, которые всегда покупались в одном экземпляре за одну покупку.
select ProductID from Sales.SalesOrderDetail
group by ProductID
having max(OrderQty) = 1;

-- 12 Найти и вывести на экран номер чека, SalesORDERID, на который приходится с наибольшим
-- разнообразием товаров купленных на этот чек.
select SalesOrderID from Sales.SalesOrderDetail
group by SalesOrderID
having count(ProductID) =
(select top 1 count(ProductID) from Sales.SalesOrderDetail
group by SalesOrderID
order by count(ProductID) desc);

-- 13 Найти и вывести на экран номер чека, SalesORDERID с наибольшей суммой покупки, исходя из того,
-- что цена товара – это UnitPrice, а количество конкретного товара в чеке – это ORDERQty.
select top 1 SalesOrderID, sum(OrderQty * UnitPrice) as s from Sales.SalesOrderDetail
group by SalesOrderID
order by s desc;

-- 14 Определить количество товаров в каждой подкатегории, исключая товары, для которых подкатегория
-- не определена, и товары, у которых не определен цвет.
select ProductSubcategoryID, count(*) as cnt from Production.Product
where ProductSubcategoryID is not null and Color is not null
group by ProductSubcategoryID;

-- 15 Получить список цветов товаров в порядке убывания количества товаров данного цвета.
select Color, count(*) as cnt from Production.Product
group by Color
order by count(*) desc;

-- 16 Вывести на экран ProductID тех товаров, что всегда покупались в количестве более
-- 1 единицы на один чек, при этом таких покупок было более двух.
select ProductID from Sales.SalesOrderDetail
group by ProductID
having min(OrderQty) > 1 and count(*) > 2;
