/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [Portfolio Project].[dbo].[NashvilleHousingData]



--Cleaning Data in SQL


Select*
FROM [Portfolio Project].[dbo].[NashvilleHousingData]



--Standardize Date Format


Select SaleDate, CONVERT(Date,SaleDate)
FROM dbo.NashvilleHousingData

Update NashvilleHousingData
SET SaleDate = CONVERT(Date,SaleDate)


ALTER TABLE NashvilleHousingData
Add SaleDateConverted Date;


Update NashvilleHousingData
SET SaleDateConverted = CONVERT(Date,SaleDate)





--Populate the property address data

Select *
From dbo.NashvilleHousingData
--Where PropertyAddress is null
Order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From dbo.NashvilleHousingData a
JOIN dbo.NashvilleHousingData b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From dbo.NashvilleHousingData a
JOIN dbo.NashvilleHousingData b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null




--Breaking out Address into Individual Columns (Address, City, State)

Select *
From dbo.NashvilleHousingData
--Where PropertyAddress is null
--Order by ParcelID


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From dbo.NashvilleHousingData


ALTER TABLE NashvilleHousingData
Add PropertySplitAddress Nvarchar(225);


Update NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousingData
Add PropertySplitCity Nvarchar(225);

Update NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *

From dbo.NashvilleHousingData


---Alternatively

Select *

From dbo.NashvilleHousingData

Select OwnerAddress
From dbo.NashvilleHousingData

Select
PARSENAME(REPLACE(OwnerAddress, ',','.') ,3)
,PARSENAME(REPLACE(OwnerAddress, ',','.') ,2)
,PARSENAME(REPLACE(OwnerAddress, ',','.') ,1)
From dbo.NashvilleHousingData


ALTER TABLE NashvilleHousingData
Add OwnerSplitAddress Nvarchar(225);

Update NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.') , 3)

ALTER TABLE NashvilleHousingData
Add OwnerSplitCity Nvarchar(225);

Update NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.') , 2)

ALTER TABLE NashvilleHousingData
Add OwnerSplitState Nvarchar(225);

Update NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.') , 1)


Select *
From dbo.NashvillehousingData


-- Change Y and N to Yes and No in 'sold as Vacant' field

Select DISTINCT(SoldAsVacant), Count(SoldAsVacant)
From dbo.NashvilleHousingData
Group by SoldAsVacant
order by 2

---Change to Yes and No


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   END
From dbo.NashvilleHousingData


Update NashvilleHousingData
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   END
From dbo.NashvilleHousingData




--Remove Duplicates

WITH RowNumCTE AS(
Select *,
     ROW_NUMBER() OVER (
	 Partition by ParcelID,
	              PropertyAddress,
				  SalesPrice,
				  SaleDate,
				  LegalReference
				  ORDER BY
				     UniqueID
					 ) row_num

From dbo.NashvilleHousingData
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
order by PropertyAddress


Select *
From dbo.NashvilleHousingData




----delete unused Columns


Select *
From dbo.NashvilleHousingData

ALTER TABLE dbo.NashvilleHousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE dbo.NashvilleHousingData
DROP COLUMN SaleDate

