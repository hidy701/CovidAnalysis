/* 

Cleaning Data in SQL Queries

*/

SELECT *
FROM PortfolioProject.NashvilleHousing

------------------------------------------------------------
-- Populate Property Address data

SELECT *
FROM PortfolioProject.NashvilleHousing
WHERE PropertyAddress IS NULL 
ORDER BY ParcelID ;


SELECT a.ParcelID , a.PropertyAddress, b.ParcelID, b.PropertyAddress ,  COALESCE(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID 
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;


UPDATE PortfolioProject.NashvilleHousing a
JOIN PortfolioProject.NashvilleHousing b
	ON a.ParcelID = b.ParcelID 
	AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = COALESCE(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;

------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress 
FROM PortfolioProject.NashvilleHousing
-- WHERE PropertyAddress IS NULL 
-- ORDER BY ParcelID ;

SELECT 
    SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress, ',') - 1) AS Address
    , SUBSTRING(PropertyAddress, INSTR(PropertyAddress, ',') +1, LENGTH(PropertyAddress)) AS Address 
FROM 
    PortfolioProject.NashvilleHousing;

   
ALTER TABLE NashvilleHousing 
ADD PropertySplitAddress Nvarchar(255);
 
UPDATE NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress, ',') - 1)

ALTER TABLE NashvilleHousing 
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, INSTR(PropertyAddress, ',') +1, LENGTH(PropertyAddress))

SELECT *
FROM NashvilleHousing 


SELECT OwnerAddress 
FROM NashvilleHousing 

SELECT 
TRIM(SUBSTRING_INDEX(OwnerAddress, ',', 1)) 
,TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)) 
,TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1)) 
FROM NashvilleHousing

ALTER TABLE NashvilleHousing 
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing 
SET OwnerSplitAddress = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', 1)) 

ALTER TABLE NashvilleHousing 
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing 
SET OwnerSplitCity = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)) 

ALTER TABLE NashvilleHousing 
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing 
SET OwnerSplitState = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1)) 

SELECT *
FROM NashvilleHousing 

------------------------------------------------------------

-- Change Y and N to YES and NO in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM NashvilleHousing 
GROUP BY SoldAsVacant 
ORDER BY 2


SELECT SoldAsVacant 
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant 
		END
FROM NashvilleHousing 

UPDATE NashvilleHousing 
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant 
		END

------------------------------------------------------------

-- Remove Duplicates


WITH RowNumCTE AS (
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
FROM NashvilleHousing 
-- ORDER BY ParcelID
)
SELECT * 
FROM RowNumCTE
WHERE row_num > 1
-- ORDER BY PropertyAddress



DELETE FROM NashvilleHousing
WHERE UniqueID IN (
    SELECT UniqueID FROM (
        SELECT UniqueID,
            ROW_NUMBER() OVER (
                PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
                ORDER BY UniqueID
            ) AS row_num
        FROM NashvilleHousing
    ) AS subquery
    WHERE row_num > 1
);

SELECT *
FROM NashvilleHousing 

ALTER TABLE NashvilleHousing 
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress;

ALTER TABLE NashvilleHousing 
DROP COLUMN SaleDate;










