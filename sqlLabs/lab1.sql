-- 1
select Name, Color, Size from Production.Product
where Color is not null and Size is not null;

-- 2
select Name, Color, Size from Production.Product
where ListPrice > 100;

-- 3
select Name, Color, Size from Production.Product
where ListPrice < 100 and Color = 'Black';

-- 4
select Name, Color, Size from Production.Product
where ListPrice < 100 and Color = 'Black'
order by ListPrice;

-- 5
select top 3 Name, Size from Production.Product
where Color = 'Black'
order by ListPrice desc;

-- 6
select Name, Color from Production.Product
where Color is not null and Size is not null;

-- 7
select distinct Color from Production.Product
where Color is not null and ListPrice >= 10 and ListPrice <= 50;

-- 8
select distinct Color from Production.Product
where Name like 'L_N%';

-- 9
select Name from Production.Product
where Name like '[DM]%' and len(Name) > 3;

-- 10
select Name from Production.Product
where year(SellStartDate) >= 2012;

-- 11
select Name from Production.ProductCategory;

-- 12
select Name from Production.ProductSubcategory;

-- 13
select FirstName, MiddleName, LastName from Person.Person
where title = 'Mr.';

-- 14
select FirstName, MiddleName, LastName from Person.Person
where title is null;
