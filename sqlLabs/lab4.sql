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
