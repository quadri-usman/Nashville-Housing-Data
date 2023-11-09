/*
Data Cleaning using Nashville Housing Data
*/

select *
from ProjectPortfolio..Nashville_housing_data_2013_201

-- Standardize Data Format
select [Sale Date], CONVERT(date, [Sale Date]) as SaleDate
from ProjectPortfolio..Nashville_housing_data_2013_201;

update ProjectPortfolio..Nashville_housing_data_2013_201
set [Sale Date] = CONVERT(date, [Sale Date]);

Alter table ProjectPortfolio..Nashville_housing_data_2013_201
add saleDateConverted Date;

update ProjectPortfolio..Nashville_housing_data_2013_201
set saleDateConverted = CONVERT(date, [Sale Date]);

select saleDateConverted
from ProjectPortfolio..Nashville_housing_data_2013_201;

-- Populate Property Address Data
select [Property Address]
from ProjectPortfolio..Nashville_housing_data_2013_201
where [Property Address] is null;
select *
from ProjectPortfolio..Nashville_housing_data_2013_201
where [Property Address] is null;

select *
from ProjectPortfolio..Nashville_housing_data_2013_201
where [Property Address] is not null
order by [Parcel ID];

select a.[Parcel ID], a.[Property Address], b.[Parcel ID], b.[Property Address],
ISNULL(a.[Property Address], b.[Property Address])
from ProjectPortfolio..Nashville_housing_data_2013_201 a
join ProjectPortfolio..Nashville_housing_data_2013_201 b
on a.[Parcel ID] = b.[Parcel ID] 
AND
a.[Unnamed: 0] <> b.[Unnamed: 0]
where a.[Property Address] is null;

update a
set [Property Address] = ISNULL(a.[Property Address], b.[Property Address])
from ProjectPortfolio..Nashville_housing_data_2013_201 a
join ProjectPortfolio..Nashville_housing_data_2013_201 b
on a.[Parcel ID] = b.[Parcel ID] 
AND
a.[Unnamed: 0] <> b.[Unnamed: 0]
where a.[Property Address] is null and b.[Property Address] != 'null';
--where a.[Property Address] is null;

-- Breaking Address into Individual Columns (Address, City, State)
	-- Propert Address
select [Property Address]
from ProjectPortfolio..Nashville_housing_data_2013_201
where [Property Address] is not null and [Parcel ID] is not null
order by [Parcel ID];

select SUBSTRING([Property Address], 1, CHARINDEX(' ', [Property Address])) as AddressNo,
SUBSTRING([Property Address], CHARINDEX(' ', [Property Address]) +1, len([Property Address])) as Address
from ProjectPortfolio..Nashville_housing_data_2013_201;

Alter table ProjectPortfolio..Nashville_housing_data_2013_201
add PropertySplitAddress Nvarchar(255);

update ProjectPortfolio..Nashville_housing_data_2013_201
set PropertySplitAddress = SUBSTRING([Property Address], 1, 
CHARINDEX(' ', [Property Address]));

Alter table ProjectPortfolio..Nashville_housing_data_2013_201
add PropertySplitCity Nvarchar(255);

update ProjectPortfolio..Nashville_housing_data_2013_201
set PropertySplitCity = SUBSTRING([Property Address], 
CHARINDEX(' ', [Property Address]) +1, len([Property Address]));

select PropertySplitAddress, PropertySplitCity
from ProjectPortfolio..Nashville_housing_data_2013_201;

	-- Owners Adress
select Address
from ProjectPortfolio..Nashville_housing_data_2013_201;

select 
PARSENAME(replace(Address, ' ', '.'), 1),
PARSENAME(replace(Address, ' ', '.'), 2),
PARSENAME(replace(Address, ' ', '.'), 4)
from ProjectPortfolio..Nashville_housing_data_2013_201;

Alter table ProjectPortfolio..Nashville_housing_data_2013_201
add OwnerAddressNo Nvarchar(255);

update ProjectPortfolio..Nashville_housing_data_2013_201
set OwnerAddressNo = PARSENAME(replace(Address, ' ', '.'), 4);

Alter table ProjectPortfolio..Nashville_housing_data_2013_201
add OwnerAddressCity Nvarchar(255);

update ProjectPortfolio..Nashville_housing_data_2013_201
set OwnerAddressCity = PARSENAME(replace(Address, ' ', '.'), 2);

Alter table ProjectPortfolio..Nashville_housing_data_2013_201
add OwnerAddressState Nvarchar(255);

update ProjectPortfolio..Nashville_housing_data_2013_201
set OwnerAddressState = PARSENAME(replace(Address, ' ', '.'), 1);

select OwnerAddressNo, OwnerAddressCity, OwnerAddressState
from ProjectPortfolio..Nashville_housing_data_2013_201;

-- Change Y and N to Yes and No in 'Sold as Vacant' field
select [Sold As Vacant], COUNT([Sold As Vacant])
from ProjectPortfolio..Nashville_housing_data_2013_201
--where [Sold As Vacant] is null
group by [Sold As Vacant];

select [Sold As Vacant],
case when [Sold As Vacant] = 'Y' then 'Yes'
	when [Sold As Vacant] = 'N' then 'No'
	else [Sold As Vacant] end
from ProjectPortfolio..Nashville_housing_data_2013_201;

update ProjectPortfolio..Nashville_housing_data_2013_201
set [Sold As Vacant] = 
case when [Sold As Vacant] = 'Y' then 'Yes'
	when [Sold As Vacant] = 'N' then 'No'
	else [Sold As Vacant] end

-- Remove Duplicate
-- Using CTE
WITH row_numCTE as(
select *,
ROW_NUMBER() over (
partition by 
[Parcel ID], 
[Property Address],
[Sale Price],
[Sale Date],
[Legal Reference]
order by 
[Unnamed: 0]) as row_num
from ProjectPortfolio..Nashville_housing_data_2013_201
-- ORDER by [Parcel ID]
)
-- delete
-- from row_numCTE
-- where row_num >1
select*
from row_numCTE
--where row_num >1
order by [Property Address];

-- Removing Unused Columns
select *
from ProjectPortfolio.dbo.Nashville_housing_data_2013_201;

alter table ProjectPortfolio.dbo.Nashville_housing_data_2013_201
drop column Address, [Property Address], [Tax District];

alter table ProjectPortfolio.dbo.Nashville_housing_data_2013_201
drop column [Sale Date];