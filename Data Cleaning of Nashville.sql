select *
from ProtfolioProject.dbo.Sheet1$


-- Detect Null Values in Property Address and populate it 

select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, IsNull(A.PropertyAddress, B.PropertyAddress)
from ProtfolioProject.dbo.Sheet1$ as A

join ProtfolioProject.dbo.Sheet1$ as B
on A.ParcelID = B.ParcelID
   And A.UniqueID <> B.UniqueID

where A.PropertyAddress is Null

--Update Column with New Results
Update A
Set PropertyAddress = 
               IsNull(A.PropertyAddress, B.PropertyAddress)
               from ProtfolioProject.dbo.Sheet1$ as A
               join ProtfolioProject.dbo.Sheet1$ as B
               on A.ParcelID = B.ParcelID
               And A.UniqueID <> B.UniqueID
               where A.PropertyAddress is Null




--                          (------------------------------)

--Splitting PropertyAddress in (Address, city, state)

select
SUBSTRING(PropertyAddress, 1, charindex(',' , PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 ,LEN(PropertyAddress)) as Address2
--PARSENAME(Replace(PropertyAddress, ',', '.'), 1)
--, PARSENAME(Replace(PropertyAddress, ',', '.'), 2)
from ProtfolioProject.dbo.Sheet1$



Alter Table Sheet1$
Add PropertySplitAddress  Nvarchar(255);

update Sheet1$
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, charindex(',' , PropertyAddress)-1)



Alter Table Sheet1$
Add PropertySplitCity  Nvarchar(255);

update Sheet1$
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 ,LEN(PropertyAddress))











--                                 (--------------------------)









-- Splitting OwnerAddress in (Address, city, state) with different way of split


select 
PARSENAME(Replace(OwnerAddress, ',', '.'), 1) 
, PARSENAME(Replace(OwnerAddress, ',', '.'), 2)
, PARSENAME(Replace(OwnerAddress, ',', '.'), 3)
from ProtfolioProject.dbo.Sheet1$


-- Alter and Update Table


Alter Table Sheet1$
Add OwnerSplitState Nvarchar(255);

update Sheet1$
set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1) 


Alter Table Sheet1$
Add OwnerSplitCity Nvarchar(255);

update Sheet1$
set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)


Alter Table Sheet1$
Add OwnerSplitAddress Nvarchar(255);

Update Sheet1$
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)



Select *
from ProtfolioProject.dbo.Sheet1$











--                                                 (----------------------------)










-- In the SoldAsVacant column map N to Now and Y to Yes


select Distinct(SoldAsVacant) , count(SoldAsVacant)
from ProtfolioProject.dbo.Sheet1$
group by SoldAsVacant
order by 2


select SoldAsVacant,
        Case When SoldAsVacant = 'N' Then 'No'
		     When SoldAsVacant = 'Y' Then 'Yes'
			 Else SoldAsVacant
			 End
From ProtfolioProject.dbo.Sheet1$


Alter Table Sheet1$
Add SoldAsVacant Nvarchar(255)


update Sheet1$
set SoldAsVacant =
        Case When SoldAsVacant = 'N' Then 'No'
		     When SoldAsVacant = 'Y' Then 'Yes'
			 Else SoldAsVacant
			 End









--                                              (----------------------------)










-- Remove Duplicates using Row_Number

With RowNumCte As(
select *,
      ROW_NUMBER() over( 
	                     Partition by
						 ParcelID,
						 PropertyAddress,
						 SaleDate,
						 SalePrice,
						 LegalReference
						 order by 
						    UniqueID
							) row_num
								
from ProtfolioProject.dbo.Sheet1$ 
)

Select *
from RowNumCte
where row_num > 1










--                                                      (------------------------------)








--Remove unusable columns 

Alter Table Sheet1$
Drop Column SoldAsVacant, OwnerAddress, PropertyAddress, TaxDistrict	





Select *
from ProtfolioProject.dbo.Sheet1$