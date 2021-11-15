--SEBASTI�N VALLEJOS M.

use LicenciasMedicas
go
--Top de empresas que sus trabajadores presenten m�s licencias.
SELECT
	 E.nombre 'EMPRESA',
	 COUNT(L.idLicencia) 'CANTIDAD_LICENCIAS'
INTO #TempLicencias
FROM LicenciasMedicas.dbo.Licencias L
INNER JOIN LicenciasMedicas.dbo.Empresa	E ON E.idEmpresa = L.idEmpresa
GROUP BY L.idEmpresa, E.nombre

SELECT EMPRESA,CANTIDAD_LICENCIAS
FROM #TempLicencias 
ORDER BY CANTIDAD_LICENCIAS DESC
--Las sucursales que reciben m�s documentaci�n, segmentados por regi�n o comuna, as� como sucursales que no est�n aptas para recibir documentaci�n.
SELECT 
	S.nombre 'SUCURSAL',
	S.region 'REGION',
	COUNT(idDocumentacion) 'CANTIDAD_DOCUMENTOS'
INTO #TEMP_POR_REGION
FROM LicenciasMedicas.dbo.Sucursales S
GROUP BY  S.region, S.nombre

--POR REGION
SELECT 
	SUCURSAL,
	REGION
FROM #TEMP_POR_REGION
ORDER BY CANTIDAD_DOCUMENTOS DESC

SELECT 
	S.nombre 'SUCURSAL',
	S.Comuna 'COMUNA',
	COUNT(idDocumentacion) 'CANTIDAD_DOCUMENTOS'
INTO #TEMP_POR_COMUNA
FROM LicenciasMedicas.dbo.Sucursales S
GROUP BY  S.Comuna, S.nombre

--POR COMUNA
SELECT 
	SUCURSAL,
	COMUNA
FROM #TEMP_POR_COMUNA
ORDER BY CANTIDAD_DOCUMENTOS DESC

--SUCURSALES NO APTAS
SELECT 
	nombre,
	region,
	comuna
from LicenciasMedicas.dbo.Sucursales
WHERE aptaDocumentacion = 'N'


--Top de documentos que hacen que la licencia reinicie su flujo.
SELECT L.idLicencia
FROM LicenciasMedicas.dbo.Licencias L
INNER JOIN LicenciasMedicas.dbo.Sucursales S ON S.idSucursal = L.idSucursal
INNER JOIN LicenciasMedicas.dbo.Documentacion D ON D.idDocumentacion = S.idDocumentacion AND D.EstadoDocumentacion = 0


--Tiempos promedios, m�nimos y m�ximos, desde el inicio del proceso hasta el c�lculo del monto a pagar por cada licencia
SELECT 
	FechaInicioProceso 'FECHA_INICIO',
	FechaFinProceso 'FECHA_TERMINO',
	DATEDIFF(DD,FechaInicioProceso,FechaFinProceso) 'PLAZO_PROCESO'
INTO #TEMP_PLAZO
FROM LicenciasMedicas.dbo.Licencias
WHERE idestadoProceso = 0


SELECT 
	MIN(PLAZO_PROCESO) 'PLAZO_MINIMO',
	MAX(PLAZO_PROCESO) 'PLAZO_MAXIMO' 
FROM  #TEMP_PLAZO


--Estad�sticas de licencias manuales o electr�nicas vs mixtas
SELECT 
	COUNT(idLicencia) 'MANUALES_ELECTRONICAS',
	0 'MIXTAS'	
INTO #TEMP_FORMA_LICENCIAS	
FROM LicenciasMedicas.dbo.Licencias 
WHERE idForma IN (0,1)

UPDATE #TEMP_FORMA_LICENCIAS 
SET MIXTAS = (SELECT COUNT(idLicencia) FROM LicenciasMedicas.dbo.Licencias WHERE idForma = 2)

SELECT MANUALES_ELECTRONICAS, MIXTAS
FROM #TEMP_FORMA_LICENCIAS

--Los estados del proceso que almacenan la mayor cantidad de licencias as� como los cambios de estado que tardan m�s tiempo en ser modificados
SELECT 
	COUNT(L.idLicencia) 'CANTIDAD_LICENCIAS',
	E.Descripcion 'ESTADO'
INTO #CANT_LICENCIAS	
FROM LicenciasMedicas.dbo.Licencias L
INNER JOIN LicenciasMedicas.dbo.EstadosLicencia E ON E.idestadoProceso = L.idestadoProceso 
GROUP BY E.Descripcion

--ESTADOS CON MAYOR CANTIDAD DE LICENCIAS
SELECT CANTIDAD_LICENCIAS, ESTADO
FROM #CANT_LICENCIAS
ORDER BY CANTIDAD_LICENCIAS DESC


SELECT 
	DATEDIFF(DD,L.FechaInicioProceso, L.FechaActualizaEstado) 'CAMBIO_ESTADO',
	E.Descripcion 'ESTADO'
INTO #TEMP_ESTADO	
FROM LicenciasMedicas.dbo.Licencias L
INNER JOIN LicenciasMedicas.dbo.EstadosLicencia E ON E.idestadoProceso = L.idestadoProceso 
GROUP BY E.Descripcion, L.FechaInicioProceso, L.FechaActualizaEstado

SELECT ESTADO, CAMBIO_ESTADO
FROM #TEMP_ESTADO
ORDER BY CAMBIO_ESTADO DESC

--Trabajadores que tienen licencia y son desafiliados
SELECT 
	T.Rut 'RUT',
	T.Nombre 'NOMBRE'
FROM LicenciasMedicas.dbo.Trabajador T												---QUE EL TRABAJADOR TENGA LICENCIA + QUE LA FECHA DE HOY SEA INFERIOR AL PLAZO TOTAL DE LICENCIA	
INNER JOIN LicenciasMedicas.dbo.Licencias L ON L.idTrabajador = T.idTrabajador AND CONVERT(DATE,GETDATE()) < CONVERT(DATE,L.FechaInicioLicencia + L.PlazoLicencia) 
WHERE T.idEstadoAfiliacion = 0 
go

--Manejo de data hist�rica de validaci�n de procesos y log�s de cambios de estado o actualizaci�n de data relevante.
insert into LogProcesos
values
(GETDATE(),'Insercion Licencia Medica ' + CONVERT(VARCHAR(200), (SELECT MAX(idLicencia) FROM LicenciasMedicas.dbo.Licencias)) ),
(GETDATE(),'CAMBIO ESTADO ' + CONVERT(VARCHAR(200), (SELECT MAX(idestadoProceso) FROM LicenciasMedicas.dbo.Licencias WHERE FechaActualizaEstado = GETDATE())))

