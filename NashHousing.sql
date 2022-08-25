SELECT * FROM PortfolioProject.nashhouse;

-- Standardize saledate

SELECT SaleDate, str_to_date(saledate, '%m/%d/%Y')
FROM nashhouse;

-- Populate Property Address data

SELECT *
FROM nashhouse
-- WHERE PropertyAddress is not null;
order by ParcelID;

SELECT a.ParcelID, a.propertyaddress, b.ParcelID, b.propertyaddress, ISNULL(a.propertyaddress,b.propertyaddress)
FROM nashhouse a
JOIN nashhouse b
	on a.ParcelID = b.ParcelID
    AND a.uniqueID <> b.uniqueID
WHERE a.propertyaddress is null;

Update a
SET propertyaddress = ISNULL(a.propertyaddress,b.propertyaddress)
FROM nashhouse a
JOIN nashhouse b
	on a.ParcelID = b.ParcelID
    AND a.uniqueID <> b.uniqueID
WHERE a.propertyaddress is null;

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM nashhouse;
-- WHERE PropertyAddress is not null;
-- order by ParcelID;

SELECT 
SUBSTR(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1) as Address,
SUBSTR(PropertyAddress, LOCATE(',', PropertyAddress) +1) as City
FROM nashhouse;

ALTER TABLE nashhouse
ADD propertysplitaddress nvarchar(255);

UPDATE nashhouse
SET propertysplitaddress = SUBSTR(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1);

ALTER TABLE nashhouse
ADD propertysplitcity nvarchar(255);

UPDATE nashhouse
SET propertysplitcity = SUBSTR(PropertyAddress, LOCATE(',', PropertyAddress) +1);

SELECT * FROM nashhouse;

SELECT owneraddress FROM nashhouse;

SELECT
SUBSTRING_index(Owneraddress, ',', 1),
SUBSTRING_index(Owneraddress, ',', 2),
SUBSTRING_index(Owneraddress, ',', -1)
FROM nashhouse;

ALTER TABLE nashhouse
ADD almost nvarchar(255);

UPDATE nashhouse
SET almost = SUBSTRING_index(Owneraddress, ',', 2);

SELECT almost FROM nashhouse;

SELECT almost, substring_index(almost, ',', -1)
FROM nashhouse;
 
 SELECT
SUBSTRING_index(Owneraddress, ',', 1),
substring_index(almost, ',', -1),
SUBSTRING_index(Owneraddress, ',', -1)
FROM nashhouse;

ALTER TABLE nashhouse
ADD ownersplitaddress nvarchar(255);

UPDATE nashhouse
SET ownersplitaddress = SUBSTRING_index(Owneraddress, ',', 1);

ALTER TABLE nashhouse
ADD ownersplitcity nvarchar(255);

UPDATE nashhouse
SET ownersplitcity = substring_index(almost, ',', -1);

ALTER TABLE nashhouse
ADD ownersplitstate nvarchar(255);

UPDATE nashhouse
SET ownersplitstate = SUBSTRING_index(Owneraddress, ',', -1);

SELECT * FROM nashhouse;

Select soldasvacant
, Case When Soldasvacant = 'Y' THEN 'Yes'
	When soldasvacant = 'N' THEN 'No'
    Else soldasvacant
    END
FROM nashhouse;

Update nashhouse
SET soldasvacant = Case When Soldasvacant = 'Y' THEN 'Yes'
	When soldasvacant = 'N' THEN 'No'
    Else soldasvacant
    END;

-- Change Y and N to Yes and No in "Sold as vacant" field

SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM nashhouse
Group by Soldasvacant
Order by 2;

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			PropertyAddress,
            Saleprice,
            Saledate,
            legalreference
            ORDER BY
            UniqueID
            ) row_num
 FROM nashhouse
 -- ORDER BY ParcelID;
 )
Delete FROM RowNumCTE Where row_num > 1;
 -- Order by propertyaddress;
    
    
-- Delete unused columns

SELECT * FROM nashhouse;

ALTER TABLE nashhouse
DROP COLUMN TaxDistrict, DROP COLUMN PropertyAddress;