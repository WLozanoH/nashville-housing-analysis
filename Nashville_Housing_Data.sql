-- 📌"Limpieza y Transformación de Datos Inmobiliarios: Proyecto de Optimización de la Base de Datos de Propiedades de Nashville"

--Puedes descargar la data aquí:👉 https://github.com/WLozanoH/nashville-housing-analysis/blob/main/Nashville%20Housing%20Data.zip

DROP TABLE IF EXISTS  Nashville_Housing;

CREATE TABLE Nashville_Housing(

	UniqueID INT PRIMARY KEY,  -- Identificador único
    ParcelID VARCHAR(20),      -- Identificador de la parcela
    LandUse VARCHAR(50),       -- Tipo de uso del suelo
    PropertyAddress VARCHAR(150),  -- Dirección de la propiedad
    SaleDate TIMESTAMP,             -- Fecha de la venta
    SalePrice NUMERIC(15,2),   -- Precio de venta
    LegalReference VARCHAR(50),   -- Referencia legal
    SoldAsVacant BOOLEAN,      -- Indica si la propiedad se vendió como vacía
    OwnerName VARCHAR(100),    -- Nombre del propietario
    OwnerAddress VARCHAR(150), -- Dirección del propietario
    Acreage DECIMAL(10,2),     -- Tamaño del terreno
    TaxDistrict VARCHAR(100), -- Distrito tributario
    LandValue NUMERIC(15,2),   -- Valor del terreno
    BuildingValue NUMERIC(15,2), -- Valor de la construcción
    TotalValue NUMERIC(15,2),   -- Valor total
    YearBuilt NUMERIC,             -- Año de construcción
    Bedrooms NUMERIC,              -- Número de habitaciones
    FullBath NUMERIC,              -- Número de baños completos
    HalfBath NUMERIC               -- Número de baños medio
	
);

--Importando la data Nashville housing.csv
COPY nashville_housing
FROM 'C:\Users\LENOVO\Desktop\Projects\Nashville_housing_db\Nashville Housing Data.csv'
DELIMITER ','
HEADER CSV;


--Limpieza de datos en consultas SQL
--Cleaning data in SQL Queries

SELECT 
	* 
FROM nashville_housing;
----------------------------------------------

--Standarized Date format

SELECT 
	saledate,
	saledate::date
FROM nashville_housing;

--Actualizando el tipo de dato para 'saledate'
ALTER TABLE nashville_housing
ALTER COLUMN saledate TYPE DATE USING saledate::date;

SELECT
	saledate
FROM nashville_housing;

--Completar los datos de la dirección de la propiedad
--Populate property Address data

SELECT 
	uniqueid,
	parcelid,
	propertyaddress
FROM nashville_housing
ORDER BY parcelid;

--parcelid : tiene el Identificador de la parcela
-- completando valores nulos para 'propertyaddress' usando 'parcelid'
-- y diferenciandola por 'uniqueid'

SELECT
	a.parcelid, a.propertyaddress,
	b.parcelid, b.propertyaddress,
	--Usamos la función 'COALESCE' para poblar los valores nulos de 'a.property' con los valores de 'b.property'
	COALESCE(a.propertyaddress, b.propertyaddress) AS change_address
FROM 
nashville_housing a
	JOIN  
nashville_housing b
ON a.parcelid = b.parcelid
AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress IS NULL;

-- Rellenando los valores nulos en la tabla
--Populating null values
UPDATE nashville_housing a
SET propertyaddress = COALESCE(a.propertyaddress, b.propertyaddress)
FROM nashville_housing b
WHERE a.parcelid = b.parcelid
AND a.uniqueid <> b.uniqueid
AND a.propertyaddress IS NULL;

--Verificando que los datos se hayan unido correctamente
--checking data have been correct cross join

SELECT
	a.parcelid,
	a.propertyaddress AS old_propertyaddress,
	COALESCE(a.propertyaddress, b.propertyaddress) AS new_propertyaddress
FROM 
nashville_housing a
	JOIN  
nashville_housing b
ON a.parcelid = b.parcelid
AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress IS NULL;
-- Se unieron todos los valores correctamente!

----------------------------------
--Dividir la dirección en columnas individuales (Dirección, ciudad)
--breaking out address into Individual columns(Address, city)
--Usamos la función 'Split_Part'

SELECT
	propertyaddress,
	SPLIT_PART(propertyaddress, ',',1) AS Address,
	SPLIT_PART(propertyaddress, ',',2) AS City
FROM nashville_housing;

--Agregando las nuevas columnas a la base de datos
--Add new columns to database

--Agregando 'address'
ALTER TABLE nashville_housing
ADD COLUMN address VARCHAR(100);

--Actualizando los valores de 'address'
UPDATE nashville_housing
SET address = SPLIT_PART(propertyaddress, ',',1);

--Agregando 'city'
ALTER TABLE nashville_housing
ADD COLUMN city VARCHAR(100);

--Actualizando los valores de 'city'
UPDATE nashville_housing
SET city = SPLIT_PART(propertyaddress, ',',2);

--Verificando las nuevas columnas añadidas a la BD
SELECT
	*
FROM nashville_housing;

--Eliminando las direcciones'address' donde sea '0'
DELETE FROM nashville_housing
WHERE address = '0';

--Separando en columnas el atributo 'owneraddress'
--Breaking out Address into individual Columns (Adress, city, State)

SELECT
	owneraddress,
	SPLIT_PART(owneraddress, ',',1) AS ownerSplitAddress,
	SPLIT_PART(owneraddress, ',',2) AS ownerSplitCity,
	SPLIT_PART(owneraddress, ',',3) AS ownerSplitState
FROM nashville_housing;

--Agregando 'ownerSplitAddress'
ALTER TABLE nashville_housing
ADD COLUMN ownerSplitAddress VARCHAR(50);

--Actualizando los datos de 'ownerSplitAddress'
UPDATE nashville_housing
SET ownerSplitAddress = SPLIT_PART(owneraddress, ',',1);

-- Agregando 'ownerSplitCity'
ALTER TABLE nashville_housing
ADD COLUMN ownerSplitCity VARCHAR(50);

--Actualizando los datos de 'ownerSplitCity'
UPDATE nashville_housing
SET ownerSplitCity = SPLIT_PART(owneraddress, ',',2);

-- Agregando 'ownerSplitState'
ALTER TABLE nashville_housing
ADD COLUMN ownerSplitState VARCHAR(50);

--Actualizando los datos de 'ownerSplitState'
UPDATE nashville_housing
SET ownerSplitState = SPLIT_PART(owneraddress, ',',3);

--Verificando las nuevas columnas añadidas a la BD
SELECT
	owneraddress,
	ownerSplitAddress,
	ownerSplitCity,
	ownerSplitState
FROM nashville_housing;
--Se agregó correctamente!
--------------------------------------------------
--Change 'Y' and 'N' to 'yes' and 'No' in "Sold as Vacant" field
--If we'd differents values to 'Yes' and 'No' usamos 'Case - When'

SELECT 
	DISTINCT(soldasvacant)
FROM nashville_housing;

--Cambiando los valores 'true' and 'false' por 'yes' and 'no'
SELECT
	CASE
	WHEN soldasvacant = true THEN 'yes'
	WHEN soldasvacant = false THEN 'no'
	END AS change_soldasvacant
FROM nashville_housing;

--Cambiando el tipo de dato 'soldasvacant' de 'boolean' a 'text'
ALTER TABLE nashville_housing
ALTER COLUMN soldasvacant TYPE TEXT USING soldasvacant::text;

--Actualizando los valores en la base de datos
UPDATE nashville_housing
SET soldasvacant =
	CASE
	WHEN soldasvacant = 'true' THEN 'yes'
	WHEN soldasvacant = 'false' THEN 'no'
	END
WHERE soldasvacant IS NOT NULL;

--VERIFICANDO LOS VALORES EN 'soldasvacant'
SELECT
	DISTINCT(soldasvacant),
	COUNT(*)
FROM nashville_housing
GROUP BY soldasvacant;
--Se registraron correctamente los valores

--Eliminando filas duplicadas
---Remove Duplicates rows

WITH filas_numeradas AS (
SELECT
	ctid,
	ROW_NUMBER() OVER (PARTITION BY 
	parcelid, propertyaddress, saleprice, saledate,legalreference
	ORDER BY ctid
	) row_num
FROM nashville_housing
)

--Eliminando filas duplicadas
DELETE FROM nashville_housing
WHERE ctid IN (
	SELECT ctid
	FROM filas_numeradas
	WHERE row_num > 1
);

--Verificando los valores

WITH filas_numeradas AS (
SELECT
	ctid,
	ROW_NUMBER() OVER (PARTITION BY 
	parcelid, propertyaddress, saleprice, saledate,legalreference
	ORDER BY ctid
	) row_num
FROM nashville_housing
)

SELECT 
	*
FROM filas_numeradas
WHERE row_num > 1;
--Se eliminó correctamente los duplicados
-------------------------------------------
--Lastly, 
--delete unused columns
--DELETE: 'owneraddress', 'propertyaddress', 'legalreference'

ALTER TABLE nashville_housing
DROP COLUMN propertyaddress,
DROP COLUMN legalreference,
DROP COLUMN owneraddress;

--Actualizar tipo de dato 'saleprice' de 'NUMERIC' a 'INT'
ALTER TABLE nashville_housing
ALTER COLUMN saleprice TYPE INT USING saleprice::INT;
--Verificando la data
SELECT
	*
FROM nashville_housing;

--pasamos al Análisis de Tendencias y Distribución del Mercado Inmobiliario: 2013-2016
--para esto limpiamos el año analizado mayor a 2016
SELECT
	*
FROM nashville_housing
WHERE saledate > '2016-12-31';

--actualizamos la data
DELETE FROM nashville_housing
WHERE saledate > '2016-12-31';

--that's it

--Exportando la data para un análisis visual
COPY (SELECT * FROM nashville_housing) 
TO 'C:\Users\LENOVO\Desktop\Projects\Nashville_housing_db\housing data cleaned.csv'
WITH (FORMAT CSV, HEADER);

--Puedes descargar la data procesada y limpia aquí: 👉https://github.com/WLozanoH/nashville-housing-analysis/blob/main/housing%20data%20cleaned.zip
--✅Link Dashboard visualización del Ánalisis de mercado inmobiliario 👇👇 
--👉👉 https://public.tableau.com/app/profile/wilmer.lozano/viz/Analisis_Mercado_Inmobiliario_2013_2016/Dashboard1?publish=yes