--Cleaning Data in SQL Queries

Select *
From [Portfolio Project].dbo.[dbo.NashvilleHousing]

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- STANDARDIZE DATE FORMAT

Select SaleDateConverted, CONVERT (Date, SaleDate)
From [Portfolio Project].dbo.[dbo.NashvilleHousing]

UPDATE dbo.[dbo.NashvilleHousing]
SET SaleDate = CONVERT (Date, SaleDate)

Alter Table dbo.[dbo.NashvilleHousing]
Add SaleDateConverted Date;

UPDATE dbo.[dbo.NashvilleHousing]
SET SaleDateConverted = CONVERT (Date, SaleDate)


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- POPULATE PROPERTY ADDRESS DATA

Select *
From [Portfolio Project].dbo.[dbo.NashvilleHousing]
--Where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress) 
From [Portfolio Project].dbo.[dbo.NashvilleHousing] a
JOIN [Portfolio Project].dbo.[dbo.NashvilleHousing] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress) 
From [Portfolio Project].dbo.[dbo.NashvilleHousing] a
JOIN [Portfolio Project].dbo.[dbo.NashvilleHousing] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE) 

Select PropertyAddress
From [Portfolio Project].dbo.[dbo.NashvilleHousing]
--Where PropertyAddress is null
--order by ParcelID

SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX (',' , PropertyAddress) -1 ) as Address
	, SUBSTRING (PropertyAddress, CHARINDEX (',', PropertyAddress) + 1, LEN (PropertyAddress)) as Address

From [Portfolio Project].dbo.[dbo.NashvilleHousing]

Alter Table dbo.[dbo.NashvilleHousing]
Add PropertySplitAddress Nvarchar (255);

UPDATE dbo.[dbo.NashvilleHousing]
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX (',' , PropertyAddress) -1 )

Alter Table dbo.[dbo.NashvilleHousing]
Add PropertySplitCity Nvarchar (255);

UPDATE dbo.[dbo.NashvilleHousing]
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX (',', PropertyAddress) + 1, LEN (PropertyAddress))

Select * 

From [Portfolio Project].dbo.[dbo.NashvilleHousing]





Select OwnerAddress
From [Portfolio Project].dbo.[dbo.NashvilleHousing]

Select 
PARSENAME (REPLACE (OwnerAddress, ',',',.') , 3) 
,PARSENAME (REPLACE (OwnerAddress, ',',',.') , 2) 
,PARSENAME (REPLACE (OwnerAddress, ',',',.') , 1) 
From [Portfolio Project].dbo.[dbo.NashvilleHousing]


Alter Table dbo.[dbo.NashvilleHousing]
Add OwnerSplitAddress Nvarchar (255);

UPDATE dbo.[dbo.NashvilleHousing]
SET OwnerSplitAddress = PARSENAME (REPLACE (OwnerAddress, ',',',.') , 3)

Alter Table dbo.[dbo.NashvilleHousing]
Add OwnerSplitCity Nvarchar (255);

UPDATE dbo.[dbo.NashvilleHousing]
SET OwnerSplitCity = PARSENAME (REPLACE (OwnerAddress, ',',',.') , 2)

Alter Table dbo.[dbo.NashvilleHousing]
Add OwnerSplitState Nvarchar (255);

UPDATE dbo.[dbo.NashvilleHousing]
SET OwnerSplitState = PARSENAME (REPLACE (OwnerAddress, ',',',.') , 1) 


Select * 
From [Portfolio Project].dbo.[dbo.NashvilleHousing]


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- CHANGE Y & N TO Yes & No IN "SOLD AS VACANT" FIELD 

Select Distinct (SoldAsVacant), Count (SoldAsVacant)
From [Portfolio Project].dbo.[dbo.NashvilleHousing]
Group by SoldAsVacant
order by 2 


Select SoldAsVacant
,	CASE When SoldAsVacant = 'Y' THEN 'Yes'
		 When SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END		
From [Portfolio Project].dbo.[dbo.NashvilleHousing]


UPDATE dbo.[dbo.NashvilleHousing] 
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		 When SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END	

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--REMOVING DUPLICATES

WITH RowNumCTE AS (
Select *,
	ROW_NUMBER () OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num



From [Portfolio Project].dbo.[dbo.NashvilleHousing]
--order by ParcelID
)

Select * 
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- DELETE UNUSED COLUMNS

Select * 
From [Portfolio Project].dbo.[dbo.NashvilleHousing]

ALTER TABLE [Portfolio Project].dbo.[dbo.NashvilleHousing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [Portfolio Project].dbo.[dbo.NashvilleHousing]
DROP COLUMN SaleDate