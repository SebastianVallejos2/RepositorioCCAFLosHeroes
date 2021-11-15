--SEBASTIAN VALLEJOS M.

use master
go
IF EXISTS (SELECT * FROM sysdatabases WHERE (name = 'LicenciasMedicas')) 
BEGIN
	drop database LicenciasMedicas
end
go

CREATE DATABASE LicenciasMedicas
go

use  LicenciasMedicas
go
---------------------------------------
create table Empresa
(
	idEmpresa int identity (1,1),
	nombre	varchar(45) not null
)
go
ALTER TABLE Empresa
ADD CONSTRAINT PK_EmpresaID PRIMARY KEY CLUSTERED (idEmpresa)
go
--PARAMETRIA
create table FormaLicencia
(
	idForma int identity (1,1) , --0 ELECTRONICAS / 1 MANUAL / 2 MIXTA
	Descripcion varchar(45) not null 
)
go
ALTER TABLE FormaLicencia
ADD CONSTRAINT PK_FormaID PRIMARY KEY CLUSTERED (idForma)
go
create table TipoLicencia
(
	idTipo int identity (1,1),
	Descripcion varchar(45) not null --MATERNAL / SANNA / ETC..
) 
go
ALTER TABLE TipoLicencia
ADD CONSTRAINT PK_TipoID PRIMARY KEY CLUSTERED (idTipo)
go

--------------------------------------
create table Documentacion
(
	idDocumentacion int identity (1,1),
	Documento image NOT NULL,
	EstadoDocumentacion int not null -- 0 incompleta / 1 completa
)
ALTER TABLE Documentacion
ADD CONSTRAINT PK_DocumentacionID PRIMARY KEY CLUSTERED (idDocumentacion)
create table Sucursales
(
	idSucursal int identity (1,1),
	Comuna varchar(45) not null,
	nombre	varchar (100) not null,
	region int not null,
	aptaDocumentacion char(1), --S / N
	idDocumentacion int not null
)
go
ALTER TABLE Sucursales
ADD CONSTRAINT PK_SucursalesID PRIMARY KEY CLUSTERED (idSucursal)
ALTER TABLE Sucursales ADD CONSTRAINT FK_Documentacion FOREIGN KEY (idDocumentacion) REFERENCES Documentacion(idDocumentacion)
go
create table EstadosLicencia
(
	idestadoProceso int identity (1,1), --0 CERRADA / 1 VIGENTE 
	Descripcion varchar(45)	not null  
)
go
ALTER TABLE EstadosLicencia
ADD CONSTRAINT PK_EstadoID PRIMARY KEY CLUSTERED (idestadoProceso)
go
create table EstadosAfiliacion
(
	idEstadoAfiliacion int identity (1,1), --0 NO AFILIADO / 1 AFILIADO
	Descripcion varchar(45)	not null
)
go
ALTER TABLE EstadosAfiliacion
ADD CONSTRAINT PK_EstadoAfiliacionID PRIMARY KEY CLUSTERED (idEstadoAfiliacion)
go

---------------------------------------
create table Trabajador
(
	idTrabajador int identity (1,1),
	Rut	varchar(12) not null,
	Nombre varchar(45) not null,
	idEstadoAfiliacion int not null
)
go
ALTER TABLE Trabajador
ADD CONSTRAINT PK_TrabajadorID PRIMARY KEY CLUSTERED (idTrabajador)
ALTER TABLE Trabajador ADD CONSTRAINT FK_EstadoAfiliacion FOREIGN KEY (idEstadoAfiliacion) REFERENCES EstadosAfiliacion(idEstadoAfiliacion)
go
---------------------------------------
create table Licencias
(
	idLicencia int identity (1,1),
	idestadoProceso int not null,
	idTipo	int not null,
	idForma int not null,
	FechaInicioProceso datetime not null,
	FechaFinProceso datetime null,
	FechaInicioLicencia datetime not null,
	FechaActualizaEstado datetime null,
	PlazoLicencia int not null,
	idTrabajador int not null,
	idEmpresa	int not null,
	idSucursal	int not null
)
go
ALTER TABLE Licencias ADD CONSTRAINT PK_LicenciaID PRIMARY KEY CLUSTERED (idLicencia)
ALTER TABLE Licencias ADD CONSTRAINT FK_Trabajador FOREIGN KEY (idTrabajador) REFERENCES Trabajador(idTrabajador)
ALTER TABLE Licencias ADD CONSTRAINT FK_Empresa FOREIGN KEY (idEmpresa) REFERENCES Empresa(idEmpresa)
ALTER TABLE Licencias ADD CONSTRAINT FK_Forma FOREIGN KEY (idForma) REFERENCES FormaLicencia(idForma)
ALTER TABLE Licencias ADD CONSTRAINT FK_Tipo FOREIGN KEY (idTipo) REFERENCES TipoLicencia(idTipo)
ALTER TABLE Licencias ADD CONSTRAINT FK_Sucursal FOREIGN KEY (idSucursal) REFERENCES Sucursales(idSucursal)
ALTER TABLE Licencias ADD CONSTRAINT FK_EstadoProceso FOREIGN KEY (idestadoProceso) REFERENCES EstadosLicencia(idestadoProceso)
go

CREATE TABLE LogProcesos
(
	Fecha datetime,
	descripcion varchar(500)
)
