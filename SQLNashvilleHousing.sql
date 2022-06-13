select *
from PortfolioProjects..NashvilleHousing

-------------------------------------------------------------------------------------
--Standardise Data Format

select SaleDateConverted, convert(date,saledate)
from PortfolioProjects..NashvilleHousing

update NashvilleHousing
set SaleDate = convert(date,saledate)

alter table NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted = convert(date,SaleDate)

-------------------------------------------------------------------------------------
--Populate Property Address Data

select *
from PortfolioProjects..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProjects..NashvilleHousing a
join PortfolioProjects..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a 
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProjects..NashvilleHousing a
join PortfolioProjects..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-------------------------------------------------------------------------------------
--Breaking Out Address Into Individial Columns (Address, City, State)

select PropertyAddress
from PortfolioProjects..NashvilleHousing

select
substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1) as Address,
substring(PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress))
as Address
from PortfolioProjects..NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1,
charindex(',', PropertyAddress) - 1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress,
charindex(',', PropertyAddress) + 1, len(PropertyAddress))

select *
from PortfolioProjects..NashvilleHousing

select OwnerAddress
from PortfolioProjects..NashvilleHousing

select
parsename(replace(OwnerAddress, ',', '.') ,3),
parsename(replace(OwnerAddress, ',', '.') ,2),
parsename(replace(OwnerAddress, ',', '.') ,1)
from PortfolioProjects..NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.') ,3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.') ,2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress, ',', '.') ,1)

select *
from PortfolioProjects..NashvilleHousing

-------------------------------------------------------------------------------------
--Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProjects..NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant
,case when SoldAsVacant = 'Y' then 'Yes'
      when SoldAsVacant = 'N' then 'No'
	  else SoldAsVacant
	  end
from PortfolioProjects..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
      when SoldAsVacant = 'N' then 'No'
	  else SoldAsVacant
	  end

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProjects..NashvilleHousing
group by SoldAsVacant
order by 2

-------------------------------------------------------------------------------------
--Remove Duplicates

with RowNumCTE as(
select *,
	row_number() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by UniqueID
	) row_num
from PortfolioProjects..NashvilleHousing
--order by ParcelID
)

select *
from RowNumCTE
where row_num > 1
order by PropertyAddress

-------------------------------------------------------------------------------------
--Delete Unused Columns

select *
from PortfolioProjects..NashvilleHousing

alter table PortfolioProjects..NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table PortfolioProjects..NashvilleHousing
drop column SaleDate