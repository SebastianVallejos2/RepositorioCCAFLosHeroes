--SEBASTI�N VALLEJOS M.
----------------ITEM 1-------------
--indicar cuales arrendatarios sus arriendos vencen el pr�ximo mes.
SELECT 
	A.rutArrendatario 'RUT', 
	A.nombre 'NOMBRE'
FROM Arrendatario A
INNER JOIN Arriendos Ar on Ar.idArrendatario = A.idArrendatario 
			AND DATEPART(MM,Ar.fechaFin) = DATEPART(MM, DATEADD(MM,1,GETDATE())) AND DATEPART(YY,Ar.fechaFin) = DATEPART(YY,GETDATE())
 
 ----------------------------------
 --Indicar cu�les propietarios tienen al menos una propiedad sin arrendar.
SELECT 
	P.rutPropietario 'RUT', 
	P.nombre 'NOMBRE',
	RTRIM(LTRIM(PRO.calle)) + ' ' + RTRIM(LTRIM(PRO.numero)) 'DIRECCION',
	PRO.comuna 'COMUNA',
	PRO.pais	'PAIS' 
FROM Propietarios P
INNER JOIN Propiedad PRO ON PRO.idPropietario = P.idPropietario
--LEFT JOIN Arriendos Ar	 ON Ar.idPropietarios = P.idPropietario	
WHERE PRO.idPropiedad NOT IN (Select AUX.ididPropiedad FROM Arriendos AUX)
OR max(CONVERT(date, PRO.fechaFin)) < CONVERT(date,getdate())
group by P.rutPropietario


----------------------------------
--Indicar cu�ntas propiedades tiene cada propietario por cada pa�s.  
SELECT 
	P.rutPropietario 'RUT', 
	P.nombre 'NOMBRE',
	PRO.pais  'PA�S',	 
	COUNT(Ar.idArriendos) 'CANTIDAD_PROPIEDADES'
FROM Propietarios P
INNER JOIN Propiedad PRO ON PRO.idPropietario = P.idPropietario
INNER JOIN Arriendos Ar	 ON Ar.idPropietarios = P.idPropietario
GROUP BY P.rutPropietario, PRO.pais


----------------------------------
--Indicar cu�les propietarios son tambi�n arrendatarios.
SELECT 
	P.rutPropietario 'RUT', 
	P.nombre 'NOMBRE'
FROM Propietarios P
INNER JOIN Arrendatario A ON A.rutArrendatario = P.rutPropietario


----------------------------------
--Indicar cuales arrendatarios arriendan fuera de Chile.
SELECT 
	A.rutArrendatario 'RUT', 
	A.nombre 'NOMBRE'
FROM Arrendatario A
INNER JOIN Arriendos Ar	 ON Ar.idArrendatario = A.idArrendatario
INNER JOIN Propiedad PRO ON PRO.idPropiedad = A.idPropiedad AND PRO.pais <>  'Chile'


----------------------------------
--Indicar cuales son los 3 pa�ses que el monto promedio de arriendo son los m�s altos.
SELECT 
	AVG(all Ar.monto) 'MONTO_PROMEDIO',
	PRO.pais	'PAIS'
INTO #PromPais
FROM Arriendos Ar		
INNER JOIN Propiedad PRO ON PRO.idPropiedad = Ar.idPropiedad
GROUP BY PRO.pais

SELECT TOP 3 PAIS 
FROM #PromPais
ORDER BY MONTO_PROMEDIO DESC


--Indicar el monto promedio, m�nimo y m�ximo que pagan arrendatarios que tambi�n son propietarios.
SELECT 
	P.rutPropietario 'RUT', 
	P.nombre 'NOMBRE'
	AVG(all Ar.monto) 'MONTO_PROMEDIO',
	MIN(Ar.monto) 'MONTO_MINIMO',
	MAX(Ar.monto) 'MONTO_MAXIMO'
FROM Propietarios P
INNER JOIN Arrendatario A ON A.rutArrendatario = P.rutPropietario
INNER JOIN Arriendos Ar	 ON Ar.idArendatario = A.idArendatario
group by P.rutPropietario, Ar.monto
