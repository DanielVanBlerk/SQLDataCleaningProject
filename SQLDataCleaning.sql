#Standardize Date Format
SELECT SaleDateConverted, CONVERT(SaleDate,Date)
FROM housingdata;

UPDATE housingdata
SET SaleDate = CONVERT(SaleDate,Date);


#Populate Property Address data
SELECT *
FROM housingdata
WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM housingdata a
JOIN housingdata b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM housingdata a
JOIN housingdata b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL


#Breaking out Address into Individual Columns (Address, City, State)
SELECT PropertyAddress
FROM housingdata
WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) AS Address
FROM housingdata;

ALTER TABLE housingdata
ADD PropertySplitAddress NVARCHAR(255);

UPDATE housingdata
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 );

ALTER TABLE housingdata
ADD PropertySplitCity NVARCHAR(255);

UPDATE housingdata
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress));

SELECT *
FROM housingdata;

SELECT OwnerAddress
FROM housingdata;

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM housingdata;

ALTER TABLE housingdata
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE housingdata
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3);

ALTER TABLE housingdata
ADD OwnerSplitCity NVARCHAR(255);

UPDATE housingdata
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2);

ALTER TABLE housingdata
ADD OwnerSplitState NVARCHAR(255);

UPDATE housingdata
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);

SELECT *
FROM housingdata;


#Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM housingdata
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM housingdata;

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END;


#Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM housingdata
ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

SELECT *
FROM housingdata;


#Delete Unused Columns
SELECT *
FROM housingdata;

ALTER TABLE housingdata
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;
