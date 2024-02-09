
/* Cleaning the Nashville Housing Data using SQL# */

--------------------------------------------------------------------------

-- Changing SaleDate to Date format

Select *
FROM PortfolioProject.dbo.NashvilleHousingData

ALTER TABLE NashvilleHousingData
Add SaleDateConvered Date;

Update NashvilleHousingData
SET SaleDateConvered = CONVERT(Date, SaleDate)

--------------------------------------------------------------------------

-- Populating Property Address Data using ParcelID

Select HousingDataA.ParcelID, HousingDataA.PropertyAddress, HousingDataB.ParcelID, HousingDataB.PropertyAddress, ISNULL(HousingDataB.PropertyAddress, HousingDataA.PropertyAddress) 
From PortfolioProject.dbo.NashvilleHousingData as HousingDataA
JOIN PortfolioProject.dbo.NashvilleHousingData as HousingDataB
	on HousingDataA.ParcelID = HousingDataB.ParcelID
	AND HousingDataA.[UniqueID ] <> HousingDataB.[UniqueID ]
WHERE HousingDataB.PropertyAddress is null 

UPDATE HousingDataB
SET PropertyAddress = ISNULL(HousingDataB.PropertyAddress, HousingDataA.PropertyAddress) 
From PortfolioProject.dbo.NashvilleHousingData as HousingDataA
JOIN PortfolioProject.dbo.NashvilleHousingData as HousingDataB
	on HousingDataA.ParcelID = HousingDataB.ParcelID
	AND HousingDataA.[UniqueID ] <> HousingDataB.[UniqueID ]
WHERE HousingDataB.PropertyAddress is null 

--------------------------------------------------------------------------

-- Breaking PropertyAddress into seperate columns (Address, City)

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM PortfolioProject.dbo.NashvilleHousingData

ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
ADD PropertyAddressLine1 Nvarchar(255);

UPDATE NashvilleHousingData
SET PropertyAddressLine1 = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
ADD PropertyCity Nvarchar(255);

UPDATE NashvilleHousingData
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

--------------------------------------------------------------------------

--Breaking OwnerAddress into seperate columns (Address, City, State)

SELECT PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3) as OwnerAddressLine1,
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2) as OwnerCity,
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1) as OwnerState
FROM NashvilleHousingData
WHERE OwnerAddress is not null

ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
ADD OwnerAddressLine1 Nvarchar(255);

UPDATE NashvilleHousingData
SET OwnerAddressLine1 = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3)

ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
ADD OwnerCity Nvarchar(255);

UPDATE NashvilleHousingData
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
ADD OwnerState Nvarchar(255);

UPDATE NashvilleHousingData
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)

--------------------------------------------------------------------------

-- Changing Y and N to Yes and No in SoldAsVacant

Select Distinct SoldAsVacant, COUNT(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousingData
Group by SoldAsVacant
order by 2 desc

Select SoldAsVacant, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' WHEN SoldAsVacant = 'N' Then 'No' Else SoldAsVacant END
From PortfolioProject.dbo.NashvilleHousingData

UPDATE NashvilleHousingData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' WHEN SoldAsVacant = 'N' Then 'No' Else SoldAsVacant END

--------------------------------------------------------------------------

-- Removing Duplicates

WITH RowNumCTE as (
SELECT *, ROW_NUMBER() OVER ( PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID ) as RowNum
From NashvilleHousingData
)

DELETE
From RowNumCTE
WHERE RowNum > 1

--------------------------------------------------------------------------

-- Deleting Unused Columns

Select * 
From PortfolioProject.dbo.NashvilleHousingData

ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
DROP COLUMN SaleDate, PropertyAddress, OwnerAddress
