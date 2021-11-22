--Data Cleaning with SQL


--Converting SaleDate from Datetime to Date
Select SaleDate, CONVERT(Date, SaleDate)
From PortfolioProjects.dbo.NashvilleHousing




--Creating a Column to convert Saledate from Datetime to date
Alter Table NashvilleHousing
Add Saledateconverted Date

--Updating the Column by extracting Date from Datetime
Update  PortfolioProjects.dbo.NashvilleHousing
SET  Saledateconverted =  CONVERT(Date, SaleDate)




--Altering the table to insert propertysplitAddress column
Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

--Updating the new column by seperating the address from the city
Update  PortfolioProjects.dbo.NashvilleHousing
Set PropertySplitAddress =  Substring(PropertyAddress,1,Charindex(',',PropertyAddress)-1)




--Altering Nashvilletable to create a seperate column for the City
Alter Table PortfolioProjects.dbo.NashvilleHousing
Add PropertyCity nvarchar(255);

--Updating the Column to contain the property city address
Update  PortfolioProjects.dbo.NashvilleHousing
Set PropertyCity =  Substring(PropertyAddress,Charindex(',',PropertyAddress)+1,Len(PropertyAddress))




--Parsing the Owneraddress to replace the comma's with fullstop
Select 
Parsename(Replace(OwnerAddress,',','.'),3)as OwnerAddress ,
Parsename(Replace(OwnerAddress,',','.'),2)as OwnerCity,
Parsename(Replace(OwnerAddress,',','.'),1)as OwnerState
from PortfolioProjects.dbo.NashvilleHousing




--Altering the table to create an owner'address Column
Alter Table  PortfolioProjects.dbo.NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

--Updating the table with
Update  PortfolioProjects.dbo.NashvilleHousing
Set OwnerSplitAddress= Parsename(Replace(OwnerAddress,',','.'),3)




--Altering and Updating the Table to create an Owner's City Colum

Alter Table  PortfolioProjects.dbo.NashvilleHousing
Add OwnerCity nvarchar(255);


Update  PortfolioProjects.dbo.NashvilleHousing
Set OwnerCity= Parsename(Replace(OwnerAddress,',','.'),2)




--Altering and updating the table to create an OwnerState Column
Alter Table  PortfolioProjects.dbo.NashvilleHousing
Add OwnerState nvarchar(255);

Update  PortfolioProjects.dbo.NashvilleHousing
Set OwnerState= Parsename(Replace(OwnerAddress,',','.'),1)



--Using Case Statement to Regroup 
Update PortfolioProjects.dbo.NashvilleHousing
Set SoldasVacant = Case When SoldasVacant= 'Y' Then 'Yes'
                        When SoldasVacant = 'N' Then 'No'
						Else SoldasVacant



-- Removing Duplicates
With RownumCTE as(
Select *,
ROW_NUMBER() OVER(Partition By ParcelId,
                               PropertyAddress,
							   SalePrice,
							   SaleDate,
							   LegalReference
							   ORDER By
							   UniqueId) Row_Num

From  PortfolioProjects.dbo.NashvilleHousing)

Delete 
from RownumCTE
Where Row_Num > 1


--Deleting the Unused Columns

Alter Table PortfolioProjects.dbo.NashvilleHousing
Drop Column OwnerAddress, PropertyAddress, taxDistrict,Saledate

Select * from PortfolioProjects.dbo.NashvilleHousing