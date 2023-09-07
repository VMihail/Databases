-- 1 Найти название продуктов и название подкатегорий этих продуктов, у которых отпускная цена больше 100,
-- не включая случаи, когда продукт не относится ни к какой подкатегории.
select first.Name, second.Name, first.ListPrice from Production.Product as first
inner join Production.ProductSubcategory as second
    on first.ProductSubcategoryID = second.ProductSubcategoryID
where ListPrice > 100;

-- 2 Найти название продуктов и название подкатегорий этих продуктов, у которых отпускная цена больше 100,
-- включая случаи, когда продукт не относится ни к какой категории.
select first.Name, second.Name, first.ListPrice from Production.Product as first
left join Production.ProductSubcategory as second
    on first.ProductSubcategoryID = second.ProductSubcategoryID
where ListPrice > 100;

-- 3 Найти название продуктов и название категорий из таблицы ProductCategory, с которой связан этот продукт,
-- не включая случаи, когда у продукта нет подкатегории.
select first.Name, second.Name from Production.Product as first
inner join Production.ProductCategory as second
    on first.ProductSubcategoryID = second.ProductCategoryID;

-- 4 Найти название продукта, отпускную цену продукта, а также последнюю отпускную цену этого продукта
-- (LAStReceiptCost), которую можно узнать из таблицы ProductVendor.
select first.Name, first.ListPrice, second.LAStReceiptCost from Production.Product as first
inner join Purchasing.ProductVendor as second on first.ProductID = second.ProductID;

-- 5 Найти название продукта, отпускную цену продукта, а также последнюю отпускную цену этого продукта
-- (LAStReceiptCost), которую можно узнать из таблицы ProductVendor, для таких продуктов,
-- у которых отпускная цена оказалась ниже последней отпускной цены у поставщика,
-- исключив те товары, для которых отпускная цена равна нулю.
select first.Name, first.ListPrice, second.LAStReceiptCost from Production.Product as first
inner join Purchasing.ProductVendor as second on first.ProductID = second.ProductID
where ListPrice > 0 and ListPrice < LAStReceiptCost;

-- 6 Найти количество товаров, которые поставляют поставщики с самым низким кредитным рейтингом
-- (CreditRatINg принимает целые значение от минимального, равного 1, до максимального, равного 5).
select count(distinct tmp.ProductID) from Production.Product as first
inner join Purchasing.ProductVendor as tmp on first.ProductID = tmp.ProductID
inner join Purchasing.Vendor as second
    on second.BusinessEntityID = tmp.BusinessEntityID
where CreditRating = 1;

-- 7 Найти, сколько товаров приходится на каждый кредитный рейтинг, т.е. сформировать таблицу,
-- первая колонка которой будет содержать номер кредитного рейтинга, вторая – количество товаров,
-- поставляемых всеми поставщиками, имеющими соответствующий кредитный рейтинг.
-- Необходимо сформировать универсальный запрос, который будет валидным и в случае появления
-- новых значений кредитного рейтинга.
select V.CreditRating, count(distinct ProductID) as cnt from Purchasing.ProductVendor as first
inner join Purchasing.Vendor as V on V.BusinessEntityID = first.BusinessEntityID
group by V.CreditRating
order by cnt;

-- 8 Найти номера первых трех подкатегорий (ProductSubcategoryID) с наибольшим количеством наименований товаров.
select top 3 first.ProductSubcategoryID, count(distinct first.Name) as cnt from Production.Product as first
inner join Production.ProductSubcategory as second on first.ProductSubcategoryID = second.ProductSubcategoryID
where first.ProductSubcategoryID is not null
group by first.ProductSubcategoryID
order by cnt desc;

-- 9 Получить названия первых трех подкатегорий с наибольшим количеством наименований товаров.
select top 3 second.Name, count(distinct first.Name) as cnt from Production.Product as first
inner join Production.ProductSubcategory as second on first.ProductSubcategoryID = second.ProductSubcategoryID
where first.ProductSubcategoryID is not null
group by second.Name
order by cnt desc;

-- 10 Высчитать среднее количество товаров, приходящихся на одну подкатегорию, с точностью минимум до одной десятой.
select round(1.0 * sum(cnt) / count(cnt), 5) as result from (
    select count(distinct ProductID) as cnt from Production.Product as first
    inner join Production.ProductSubcategory as second on first.ProductSubcategoryID = second.ProductSubcategoryID
    group by second.ProductSubcategoryID
                     ) as fsc;

-- 11 Вычислить среднее количество товаров, приходящихся на одну категорию, в целых числах.
select sum(cnt) / count(cnt) from (
    select count(distinct first.Name) as cnt from Production.Product as first
    inner join Production.ProductSubcategory as second on first.ProductSubcategoryID = second.ProductSubcategoryID
    inner join Production.ProductCategory as therd on second.ProductCategoryID = therd.ProductCategoryID
    group by therd.ProductCategoryID
                     ) as fstc;

-- 12 Найти количество цветов товаров, приходящихся на каждую категорию,
-- без учета товаров, для которых цвет не определен.
select therd.ProductCategoryID, count(distinct Color) as cnt from Production.Product as first
inner join Production.ProductSubcategory as second on first.ProductSubcategoryID = second.ProductSubcategoryID
inner join Production.ProductCategory as therd on second.ProductCategoryID = therd.ProductCategoryID
where Color is not null
group by therd.ProductCategoryID;

-- 13 Найти средний вес продуктов. Просмотреть таблицу продуктов и убедиться, что есть продукты,
-- для которых вес не определен. Модифицировать запрос так, чтобы при нахождении среднего веса
-- продуктов те продукты, для которых вес не определен, считались как продукты с весом 10.
select avg(iif (Weight is null, 10, Weight)) from Production.Product;

-- 14 Вывести названия продуктов и период их активных продаж (период между SellStartDate и SellEndDate)
-- в днях, отсортировав по уменьшению времени продаж. Если продажи идут до сих пор и SellEndDate не определен,
-- то считать периодом продаж число дней с начала продаж и по текущие сутки.

select Name, iif (SellEndDate is null,
    datediff(day, SellStartDate, getdate()),
    datediff(day, SellStartDate, SellEndDate)) from Production.Product;

-- 15 Разбить продукты по количеству символов в названии, и для каждой группы определить количество продуктов.
select len(Name), count(distinct ProductID) from Production.Product
group by len(Name);

-- 16 Найти для каждого поставщика количество подкатегорий продуктов, к которым относится продукты,
-- поставляемые им, без учета ситуации, когда продукт не относится ни к какой подкатегории.
select first.BusinessEntityID, count(distinct ProductSubcategoryID) from Purchasing.ProductVendor as first
inner join Production.Product as second on first.ProductID = second.ProductID
where ProductSubcategoryID is not null
group by first.BusinessEntityID;

-- 17 Проверить, есть ли продукты с одинаковым названием, если есть, то вывести эти названия.
select first.Name from Production.Product as first, Production.Product as second
where first.ProductID != second.ProductID and first.Name = second.Name;

-- 18 Найти первые 10 самых дорогих товаров, с учетом ситуации,
-- когда цена цены у некоторых товаров могут совпадать.
select top 10 Name, ListPrice from Production.Product
order by ListPrice desc;

-- 19 Найти первые 10 процентов самых дорогих товаров, с учетом ситуации,
-- когда цены у некоторых товаров могут совпадать.
select top 10 percent Name, ListPrice from Production.Product
order by ListPrice desc;

-- 20 Найти первых трех поставщиков, отсортированных по количеству поставляемых товаров,
-- с учетом ситуации, что количество поставляемых товаров может совпадать для разных поставщиков.
select top 3 with ties BusinessEntityID, count(distinct first.ProductID) as cnt from Purchasing.ProductVendor as first
inner join Production.Product as second on first.ProductID = second.ProductID
group by BusinessEntityID
order by cnt desc;


-- 1 Найти и вывести на экран название продуктов и название категорий товаров,
-- к которым относится этот продукт, с учетом того, что в выборку попадут только
-- товары с цветом Red и ценой не менее 100.
select first.Name, threrd.Name from Production.Product as first
inner join Production.ProductSubcategory as second on first.ProductSubcategoryID = second.ProductSubcategoryID
inner join Production.ProductCategory as threrd on second.ProductCategoryID = threrd.ProductCategoryID
where Color = 'Red' and ListPrice >= 100;

-- 2 Вывести на экран названия подкатегорий с совпадающими именами.
select * from Production.ProductSubcategory as first, Production.ProductSubcategory as second
where first.Name = second.Name and first.ProductSubcategoryID != second.ProductSubcategoryID;

-- 3 Вывести на экран название категорий и количество товаров в данной категории.
select first.Name, count(distinct threrd.Name) as result from Production.ProductCategory as first
inner join Production.ProductSubcategory as second on first.ProductCategoryID = second.ProductCategoryID
inner join Production.Product as threrd on second.ProductSubcategoryID = threrd.ProductSubcategoryID
group by first.Name;

-- 4 Вывести на экран название подкатегории, а также количество товаров в данной подкатегории
-- с учетом ситуации, что могут существовать подкатегории с одинаковыми именами.
select first.Name, count(distinct second.name) as result from Production.ProductSubcategory as first
inner join Production.Product as second on first.ProductSubcategoryID = second.ProductSubcategoryID
group by first.Name;

-- 5 Вывести на экран название первых трех подкатегорий с небольшим количеством товаров.
select top 3 first.Name, count(distinct second.name) as result from Production.ProductSubcategory as first
inner join Production.Product as second on first.ProductSubcategoryID = second.ProductSubcategoryID
group by first.Name
order by result;

-- 6 Вывести на экран название подкатегории и максимальную цену продукта с цветом Red в этой подкатегории.
select first.Name, second.ListPrice from Production.ProductSubcategory as first
inner join Production.Product as second on first.ProductSubcategoryID = second.ProductSubcategoryID
where Color = 'Red' and ListPrice =
(select max(ListPrice)from Production.ProductSubcategory as f
inner join Production.Product as ss on f.ProductSubcategoryID = ss.ProductSubcategoryID
where Color = 'Red' and f.name = first.Name
group by f.Name)
group by first.Name, second.ListPrice;

-- 7 Вывести на экран название поставщика и количество товаров, которые он поставляет.
select second.Name, count(distinct first.ProductID) as result from Purchasing.ProductVendor as first
inner join Purchasing.Vendor as second on first.BusinessEntityID = second.BusinessEntityID
group by second.Name;

-- 8 Вывести на экран название товаров, которые поставляются более чем одним поставщиком.
select first.ProductID, second.Name from Purchasing.ProductVendor as first
inner join Production.Product as second on first.ProductID = second.ProductID
group by first.ProductID, second.Name
having count(distinct BusinessEntityID) > 1;

-- 9 Вывести на экран название самого продаваемого товара.
select ProductID, sum(OrderQty) as cnt from Purchasing.PurchaseOrderDetail
group by ProductID
order by sum(OrderQty) desc;

-- 10 Вывести на экран название категории, товары из которой продаются наиболее активно.
select Name from Production.Product
where ProductID = (
    select top 1 ProductID as cnt from Purchasing.PurchaseOrderDetail
    group by ProductID
    order by sum(OrderQty) desc
);

-- 11 Вывести на экран названия категорий, количество подкатегорий и количество товаров в них.
select first.Name, count(distinct second.Name), count(distinct therd.ProductID) from Production.ProductCategory as first
inner join Production.ProductSubcategory as second on first.ProductCategoryID = second.ProductCategoryID
inner join Production.Product as therd on second.ProductSubcategoryID = therd.ProductSubcategoryID
group by first.Name;

-- 12 Вывести на экран номер кредитного рейтинга и количество товаров,
-- поставляемых компаниями, имеющими этот кредитный рейтинг.
select CreditRating, count(distinct ProductID) as result from Purchasing.Vendor as first
inner join Purchasing.ProductVendor as second on first.BusinessEntityID = second.BusinessEntityID
group by CreditRating;
