use SQLPORTFOLIO
select *
from HousingData$

-- Standardize date format

select SaleDate, convert(Date,SaleDate)  from HousingData$

update HousingData$
set SaleDate = convert(Date,SaleDate)

select SaleDate 
from HousingData$

Alter table HousingData$ 
add SaleDateconverted Date;


update HousingData$
set SaleDateconverted = convert(Date,SaleDate)


update HousingData$
set SaleDateconverted = convert(Date,SaleDate)


select SaleDateconverted, convert(Date,SaleDate)  from HousingData$

-- populate property address data

select *
from HousingData$
--where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress , ISNULL(a.PropertyAddress , b.PropertyAddress) 
 from HousingData$ a
 join  HousingData$ b
 on a.[ParcelID]= b.[ParcelID] and
 a.[UniqueID ]<> b.[UniqueID ]
 where a.PropertyAddress is null


 update a 
 set PropertyAddress =ISNULL(a.PropertyAddress , b.PropertyAddress)
 from HousingData$ a
 join  HousingData$ b
 on a.[ParcelID]= b.[ParcelID] and
 a.[UniqueID ]<> b.[UniqueID ]
 where a.PropertyAddress is null

 --Breaking down property  address into Address,city, state

 select PropertyAddress
from HousingData$



SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
from HousingData$

ALTER TABLE HousingData$
Add PropertySplitAddress Nvarchar(255);

Update HousingData$
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE HousingData$
Add PropertySplitCity Nvarchar(255);

Update HousingData$
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

select *
from HousingData$

select OwnerAddress 
from HousingData$
select
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
from HousingData$

ALTER TABLE HousingData$
Add OwnerSplitAddress Nvarchar(255);

Update HousingData$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)


ALTER TABLE HousingData$
Add OwnerSplitCity Nvarchar(255);

Update HousingData$
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE HousingData$
Add OwnerSplitState Nvarchar(255);

Update HousingData$
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

select * from HousingData$

--change y and N as YES AND NO in SoldAsVacant

select Distinct(SoldAsVacant) , count(SoldAsVacant) 
from HousingData$
group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From HousingData$

update HousingData$
set SoldAsVacant= CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
	  

 --removing duplicates
with rownum_cte AS(
	  select *, 
	  ROW_NUMBER() over (
	  partition by ParcelID,
	              PropertyAddress,
				  SaleDate,
				  SalePrice, 
	      LegalReference
		  order by 
		  UniqueID
		  ) row_num
from SQLPORTFOLIO.dbo.HousingData$
)
--delete
--from rownum_cte
--where row_num >1
select *
from rownum_cte
where row_num >1
order by PropertyAddress



--Delete unused columns
select *
from HousingData$

alter table HousingData$
drop column SaleDate,PropertyAddress,OwnerAddress,TaxDistrict