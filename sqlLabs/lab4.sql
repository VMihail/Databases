-- 1 Найти название подкатегории с наибольшим количеством продуктов, без учета продуктов,
-- для которых подкатегория не определена (еще одна возможная реализация).
select
    sub.Name,
    count(distinct ProductID) as cnt
from
    Production.ProductSubcategory as sub
    join Production.Product as pr on pr.ProductSubcategoryID = sub.ProductSubcategoryID
where pr.ProductSubcategoryID is not null
group by sub.Name
having count(distinct ProductID) = (
    select top 1
        count(distinct ProductID) as cnt
    from
        Production.ProductSubcategory as sub
        join Production.Product as pr on pr.ProductSubcategoryID = sub.ProductSubcategoryID
    where pr.ProductSubcategoryID is not null
    group by sub.Name
    order by cnt desc
);

select
    Name
from Production.ProductSubcategory as sub
where ProductSubcategoryID in (
    select
        ProductSubcategoryID
    from Production.Product as pr
    where pr.ProductSubcategoryID is not null
    group by pr.ProductSubcategoryID
    having count(distinct ProductID) = (
        select
            top 1 count(ProductID)
        from Production.Product as pr
        where pr.ProductSubcategoryID is not null
        group by pr.ProductSubcategoryID
        order by count(distinct pr.ProductID) desc
        )
    );

-- 2 Вывести на экран такого покупателя, который каждый раз покупал только одну
-- номенклатуру товаров, не обязательно в одинаковых количествах,
-- т.е. у него всегда был один и тот же «список покупок».
select
    CustomerID, count(*)
from Sales.SalesOrderHeader as main
group by CustomerID
having count(*) = all (
    select
        count(*)
    from Sales.SalesOrderHeader as notMain
    where main.CustomerID = notMain.CustomerID
    group by CustomerID
    );

-- 3 Вывести на экран следующую информацию: название товара (первая колонка),
-- количество покупателей, покупавших этот товар (вторая колонка),
-- количество покупателей, совершавших покупки, но не покупавших товар из первой колонки (третья колонка).
select distinct
    product.ProductID,
    (
        select
            count(distinct headerImpl.CustomerID)
        from Sales.SalesOrderHeader as headerImpl
        join Sales.SalesOrderDetail as detailImpl on headerImpl.SalesOrderID = detailImpl.SalesOrderID
        where detailImpl.ProductID = detailMain.ProductID
        ) as cntCustomer,
    (
        select
            count(distinct headerI.CustomerID)
        from Sales.SalesOrderHeader as headerI
        where headerI.CustomerID not in (
            select
                headerImpl.CustomerID
            from Sales.SalesOrderHeader as headerImpl
            join Sales.SalesOrderDetail as detailImpl on headerImpl.SalesOrderID = detailImpl.SalesOrderID
            where detailImpl.ProductID = detailMain.ProductID
            )
        ) as cntNotCustomer
from Sales.SalesOrderHeader as headerMain
join Sales.SalesOrderDetail as detailMain on headerMain.SalesOrderID = detailMain.SalesOrderID
join Production.Product as product on product.ProductID = detailMain.ProductID
order by product.ProductID;

-- 4 Найти такие товары, которые были куплены более чем одним покупателем,
-- при этом все покупатели этих товаров покупали товары только из одной подкатегории.
select
    p.Name
from Sales.SalesOrderHeader as header
join Sales.SalesOrderDetail as detail on header.SalesOrderID = detail.SalesOrderID
join Production.Product as p on p.ProductID = detail.ProductID
where CustomerID in (
    select
        CustomerID
    from Sales.SalesOrderHeader as header
    join Sales.SalesOrderDetail as detail on header.SalesOrderID = detail.SalesOrderID
    join Production.Product as product on detail.ProductID = product.ProductID
    where product.ProductSubcategoryID is not null
    group by CustomerID
    having count(distinct product.ProductSubcategoryID) = 1
    )
group by p.Name
having count(distinct CustomerID) > 1
order by p.Name;

-- 5 Найти покупателя, который каждый раз имел разный список товаров в чеке (по номенклатуре).
select
    CustomerID
from Sales.SalesOrderHeader as mainHeader
where CustomerID not in (
    select
        CustomerID
    from Sales.SalesOrderHeader as main
    group by CustomerID
    having count(*) = all (
        select
            count(*)
        from Sales.SalesOrderHeader as notMain
        where main.CustomerID = notMain.CustomerID
        group by CustomerID
        )
    );

-- 6 Найти такого покупателя, что все купленные им товары были куплены только им
-- и никогда не покупались другими покупателями.
select
    CustomerID
from Sales.SalesOrderHeader
where CustomerID not in (
    select
        CustomerID
    from Sales.SalesOrderHeader as mainHeader
    join Sales.SalesOrderDetail as mainDetail on mainHeader.SalesOrderID = mainDetail.SalesOrderID
    where mainDetail.ProductID not in (
        select
            detail.ProductID
        from Sales.SalesOrderHeader as header
        join Sales.SalesOrderDetail as detail on header.SalesOrderID = detail.SalesOrderID
        where detail.ProductID in (
            select
                detail.ProductID
            from Sales.SalesOrderHeader as header
            join Sales.SalesOrderDetail as detail on header.SalesOrderID = detail.SalesOrderID
            group by detail.ProductID
            having count(distinct CustomerID) = 1
            )
        group by detail.ProductID
        having count(distinct CustomerID) = 1
        )
    );


-- home task

-- 1 Найти название самого продаваемого продукта.
select
    product.Name
from Sales.SalesOrderDetail as detail
join Production.Product as product on detail.ProductID = product.ProductID
group by product.Name
having count(distinct SalesOrderID) = (
    select
        top 1 count(distinct SalesOrderID) as cnt
    from Sales.SalesOrderDetail
    group by ProductID
    order by cnt desc
    );

-- 2 Найти покупателя, совершившего покупку на самую большую сумм, считая сумму
-- покупки исходя из цены товара без скидки (UnitPrice).
select
    CustomerID
from Sales.SalesOrderHeader as header
join Sales.SalesOrderDetail as detail on header.SalesOrderID = detail.SalesOrderID
group by CustomerID
having sum(UnitPrice * OrderQty) = (
    select top 1
        sum(UnitPrice * OrderQty) as totalSum
    from Sales.SalesOrderHeader as header
    join Sales.SalesOrderDetail as detail on header.SalesOrderID = detail.SalesOrderID
    group by CustomerID
    order by totalSum desc
    );

-- 3 Найти такие продукты, которые покупал только один покупатель.
select
    ProductID
from Sales.SalesOrderHeader as header
join Sales.SalesOrderDetail as detail on header.SalesOrderID = detail.SalesOrderID
group by ProductID
having count(distinct CustomerID) = 1;

-- 4 Вывести список продуктов, цена которых выше средней цены товаров в подкатегории,
-- к которой относится товар.
select
    avg(ListPrice)
from Production.Product as productImpl
where ProductSubcategoryID is not null
group by ProductSubcategoryID;

select
    Name
from Production.Product as product
where ListPrice > (
    select
        avg(ListPrice)
    from Production.Product as productImpl
    where productImpl.ProductSubcategoryID is not null
      and productImpl.ProductSubcategoryID = product.ProductSubcategoryID
    group by productImpl.ProductSubcategoryID
    );

-- 5 Найти такие товары, которые были куплены более чем одним покупателем,
-- при этом все покупатели этих товаров покупали товары только одного цвета
-- и товары не входят в список покупок покупателей, купивших товары только двух цветов.

-- Найти такие товары, которые были куплены более чем одним покупателем
select
    detail.ProductID
from Sales.SalesOrderHeader as header
join Sales.SalesOrderDetail as detail on header.SalesOrderID = detail.SalesOrderID
join Production.Product as product on detail.ProductID = product.ProductID
where CustomerID in (
    select
        CustomerID
    from Sales.SalesOrderHeader as headerImpl
    join Sales.SalesOrderDetail as detailImpl on headerImpl.SalesOrderID = detailImpl.SalesOrderID
    join Production.Product as product on detailImpl.ProductID = product.ProductID
    where Color is not null
    group by CustomerID, detailImpl.ProductID
    having count(distinct Color) = 1
    )
    and detail.ProductID not in (
    select
        detailImpl.ProductID
    from Sales.SalesOrderHeader as headerImpl
    join Sales.SalesOrderDetail as detailImpl on headerImpl.SalesOrderID = detailImpl.SalesOrderID
    join Production.Product as product on detailImpl.ProductID = product.ProductID
    where Color is not null
    group by CustomerID, detailImpl.ProductID
    having count(distinct Color) = 2
    )
group by detail.ProductID
having count(distinct CustomerID) > 1;

-- 6 Найти такие товары, которые были куплены такими покупателями,
-- у которых они присутствовали в каждой их покупке.
select distinct
    ProductID
from Sales.SalesOrderHeader as header
join Sales.SalesOrderDetail as detail on header.SalesOrderID = detail.SalesOrderID
where CustomerID in (
    select
        headerImpl.CustomerID
    from Sales.SalesOrderHeader as headerImpl
    join Sales.SalesOrderDetail as detailImpl on headerImpl.SalesOrderID = detailImpl.SalesOrderID
    where detailImpl.ProductID = detail.ProductID
    group by headerImpl.CustomerID
    having count(*) = (
        select
            count(*)
        from Sales.SalesOrderHeader as headerImplImpl
        join Sales.SalesOrderDetail as detailImplImpl on headerImplImpl.SalesOrderID = detailImplImpl.SalesOrderID
        where headerImplImpl.CustomerID = header.CustomerID
        group by headerImplImpl.CustomerID
        )
    );

-- 7 Найти покупателей, у которых есть товар, присутствующий в каждой покупке/чеке.

-- 8 Найти такой товар или товары, которые были куплены не более чем тремя различными покупателями.
select
    ProductID, count(distinct CustomerID) as cnt
from Sales.SalesOrderHeader as header
join Sales.SalesOrderDetail as detail on header.SalesOrderID = detail.SalesOrderID
group by ProductID
having count(distinct CustomerID) <= 3;

-- 9 Найти все товары, такие что их покупали всегда с товаром, цена которого максимальна в своей категории.
select distinct
    ProductID
from Sales.SalesOrderDetail
where SalesOrderID in (
    select distinct
        SalesOrderID
    from Sales.SalesOrderDetail as detail
    join Production.Product as pr on detail.ProductID = pr.ProductID
    where pr.ListPrice = (
        select max(ListPrice) from Production.Product
        where ProductSubcategoryID = pr.ProductSubcategoryID
        )
    );

-- 10 Найти номера тех покупателей, у которых есть как минимум два чека, и каждый из этих чеков содержит
-- как минимум три товара, каждый из которых как минимум был куплен другими покупателями три раза.
select distinct
    CustomerID
from Sales.SalesOrderDetail as detail
join Sales.SalesOrderHeader as header on detail.SalesOrderID = header.SalesOrderID
where CustomerID in (
        select
            CustomerID
        from Sales.SalesOrderHeader as headerImpl
        join Sales.SalesOrderDetail as detailImpl on headerImpl.SalesOrderID = detailImpl.SalesOrderID
        group by CustomerID
        having count(distinct detailImpl.SalesOrderID) >= 2
    )
    and detail.SalesOrderID in (
        select
            detailImpl.SalesOrderID
        from Sales.SalesOrderHeader as headerImpl
        join Sales.SalesOrderDetail as detailImpl on headerImpl.SalesOrderID = detailImpl.SalesOrderID
        group by detailImpl.SalesOrderID
        having count(detailImpl.ProductID) >= 3
    )
    and ProductID in (
        select
            ProductID
        from Sales.SalesOrderDetail as detailImpl
        join Sales.SalesOrderHeader as headerImpl on detailImpl.SalesOrderID = headerImpl.SalesOrderID
        where CustomerID != header.CustomerID
        group by ProductID
        having count(*) >= 3
    );

-- 11 Найти все чеки, в которых каждый товар был куплен дважды этим же покупателем.
select
    detail.SalesOrderID, CustomerID, ProductID
from Sales.SalesOrderHeader as header
join Sales.SalesOrderDetail as detail on header.SalesOrderID = detail.SalesOrderID
order by ProductID;

-- 12 Найти товары, которые были куплены минимум три раза различными покупателями.
select distinct
    ProductID
from Sales.SalesOrderHeader as header
join Sales.SalesOrderDetail as detail on header.SalesOrderID = detail.SalesOrderID
group by ProductID
having count(distinct CustomerID) >= 3;

-- 13 Найти такую подкатегорию или подкатегории товаров, которые содержат более трех товаров,
-- купленных более трех раз.
select distinct
    subC.ProductSubcategoryID
from Sales.SalesOrderDetail as detail
join Production.Product on detail.ProductID = Product.ProductID
join Production.ProductSubcategory as subC on Product.ProductSubcategoryID = subC.ProductSubcategoryID
where subC.ProductSubcategoryID in (
    select
        pr.ProductSubcategoryID
    from Production.ProductSubcategory as sub
    join Production.Product as pr on pr.ProductSubcategoryID = sub.ProductSubcategoryID
    group by pr.ProductSubcategoryID
    having count(distinct ProductID) > 3
    )
    and detail.ProductID in (
    select distinct
        ProductID
    from Sales.SalesOrderHeader as headerImpl
    join Sales.SalesOrderDetail as detailImpl on headerImpl.SalesOrderID = detailImpl.SalesOrderID
    group by ProductID
    having count(*) > 3
    );

-- 14 Найти те товары, которые не были куплены более трех раз, и как минимум дважды одним и тем же покупателем.
