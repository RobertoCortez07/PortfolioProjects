/*

Cleaning Data in SQL Queries using Data Grip IDE

*/



--------------------------------------------------------------------------------------------------------------------------

-- Standardize Sales Date Format


select "SaleDate"
FROM nashville_housing;

ALTER TABLE nashville_housing
ADD SaleDateConverted DATE;


Update nashville_housing
SET saledateconverted = to_date(nashville_housing."SaleDate", 'Month DD YYYY');


SELECT "SaleDate" ,saledateconverted from nashville_housing;


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data where address is null

SELECT a."ParcelID", a."PropertyAddress", b."ParcelID", b."PropertyAddress"
FROM nashville_housing a
JOIN nashville_housing b
    ON a."ParcelID" = b."ParcelID"
    and a."UniqueID " <> b."UniqueID "
where a."PropertyAddress" is null;

update nashville_housing
SET "PropertyAddress" = COALESCE(a."PropertyAddress", b."PropertyAddress")
FROM nashville_housing a
JOIN nashville_housing b
    ON a."ParcelID" = b."ParcelID"
    and a."UniqueID " <> b."UniqueID "
where a."PropertyAddress" is null;


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT "PropertyAddress"
FROM nashville_housing;


SELECT
    SUBSTRING(nashville_housing."PropertyAddress", 1, strpos(nashville_housing."PropertyAddress", ',')-1 ) As Address,
    SUBSTRING(nashville_housing."PropertyAddress", strpos(nashville_housing."PropertyAddress", ',') + 1, length(nashville_housing."PropertyAddress")) As City
FROM nashville_housing;


ALTER TABLE nashville_housing
ADD PropertySplitAddress varchar(255);


Update nashville_housing
SET PropertySplitAddress = SUBSTRING(nashville_housing."PropertyAddress", 1, strpos(nashville_housing."PropertyAddress", ',')-1 );

ALTER TABLE nashville_housing
ADD PropertySplitCity varchar(255);


Update nashville_housing
SET PropertySplitCity = SUBSTRING(nashville_housing."PropertyAddress", strpos(nashville_housing."PropertyAddress", ',') + 1, length(nashville_housing."PropertyAddress"));

SELECT nashville_housing."OwnerAddress"
FROM nashville_housing;

-- Splits the owner address into address, city and state

SELECT nashville_housing."OwnerAddress",
       split_part(nashville_housing."OwnerAddress", ',', 1) as Address,
       split_part(nashville_housing."OwnerAddress", ',', 2) as City,
       split_part(nashville_housing."OwnerAddress", ',', 3) as State
FROM nashville_housing;


ALTER TABLE nashville_housing
ADD OwnerSplitAddress varchar(255);


Update nashville_housing
SET ownersplitaddress = split_part(nashville_housing."OwnerAddress", ',', 1);

ALTER TABLE nashville_housing
ADD OwnerSplitCity varchar(255);


Update nashville_housing
SET ownersplitcity = split_part(nashville_housing."OwnerAddress", ',', 2);

ALTER TABLE nashville_housing
ADD OwnerSplitState varchar(255);


Update nashville_housing
SET ownersplitstate = split_part(nashville_housing."OwnerAddress", ',', 3);


SELECT nashville_housing."OwnerAddress",
       nashville_housing."ownersplitaddress",
       nashville_housing."ownersplitcity",
       nashville_housing."ownersplitstate"
from nashville_housing;



--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT("SoldAsVacant"), COUNT(nashville_housing."SoldAsVacant")
FROM nashville_housing
GROUP BY nashville_housing."SoldAsVacant"
order by 2;

SELECT "SoldAsVacant",
       CASE WHEN "SoldAsVacant" = 'Y'then 'Yes'
       WHEN "SoldAsVacant" = 'N' then 'No'
       ELSE "SoldAsVacant"
       END
FROM nashville_housing;

Update nashville_housing
SET "SoldAsVacant" =
       CASE WHEN "SoldAsVacant" = 'Y'then 'Yes'
       WHEN "SoldAsVacant" = 'N' then 'No'
       ELSE "SoldAsVacant"
       END;




-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
WITH RowNumCTE AS (
    SELECT "ParcelID"
    FROM (
        SELECT *,
               row_number() over (
           PARTITION BY "ParcelID",
           "PropertyAddress",
           "SalePrice",
           "SaleDate",
           "LegalReference"
           ORDER BY "ParcelID"
           ) row_num
            FROM nashville_housing
         ) s
    WHERE row_num > 1
)

DELETE FROM nashville_housing
WHERE "ParcelID" in (SELECT * FROM RowNumCTE)


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Alter Table nashville_housing
DROP COLUMN "SaleDate",
DROP COLUMN "OwnerAddress",
DROP COLUMN "TaxDistrict",
DROP COLUMN "PropertyAddress";

SELECT *
FROM nashville_housing;

















