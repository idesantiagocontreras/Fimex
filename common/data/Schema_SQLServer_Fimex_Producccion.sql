USE [master]
GO
/****** Object:  Database [FIMEX_Produccion]    Script Date: 30/10/2014 11:43:43 a.m. ******/
CREATE DATABASE [FIMEX_Produccion]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'FIMEX_Produccion', FILENAME = N'c:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\FIMEX_Produccion.mdf' , SIZE = 51200KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'FIMEX_Produccion_log', FILENAME = N'c:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\FIMEX_Produccion_log.ldf' , SIZE = 15040KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [FIMEX_Produccion] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [FIMEX_Produccion].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [FIMEX_Produccion] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [FIMEX_Produccion] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [FIMEX_Produccion] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [FIMEX_Produccion] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [FIMEX_Produccion] SET ARITHABORT OFF 
GO
ALTER DATABASE [FIMEX_Produccion] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [FIMEX_Produccion] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [FIMEX_Produccion] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [FIMEX_Produccion] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [FIMEX_Produccion] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [FIMEX_Produccion] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [FIMEX_Produccion] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [FIMEX_Produccion] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [FIMEX_Produccion] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [FIMEX_Produccion] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [FIMEX_Produccion] SET  DISABLE_BROKER 
GO
ALTER DATABASE [FIMEX_Produccion] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [FIMEX_Produccion] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [FIMEX_Produccion] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [FIMEX_Produccion] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [FIMEX_Produccion] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [FIMEX_Produccion] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [FIMEX_Produccion] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [FIMEX_Produccion] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [FIMEX_Produccion] SET  MULTI_USER 
GO
ALTER DATABASE [FIMEX_Produccion] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [FIMEX_Produccion] SET DB_CHAINING OFF 
GO
ALTER DATABASE [FIMEX_Produccion] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [FIMEX_Produccion] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [FIMEX_Produccion]
GO
/****** Object:  StoredProcedure [dbo].[p_SetAleacion]    Script Date: 30/10/2014 11:43:43 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jesus Huante>
-- Create date: <20/10/2014>
-- Description:	<Procedimiento que permite la sincronizacion de Aleaciones>
-- =============================================
CREATE PROCEDURE [dbo].[p_SetAleacion] @Identificador varchar(5), @Descripcion varchar(30), @IdAleacion int OUT
AS
BEGIN
	SET @Identificador = LTRIM(RTRIM(@Identificador));
	SET @Descripcion = LTRIM(RTRIM(@Descripcion));
	IF NOT EXISTS (SELECT * FROM Aleaciones WHERE Descripcion = @Descripcion) 
	BEGIN
		INSERT INTO Aleaciones (Identificador, Descripcion) VALUES (@Identificador , @Descripcion);
		SELECT @IdAleacion = @@identity 
	END
	ELSE
	BEGIN
		SELECT @IdAleacion = IdAleacion FROM Aleaciones WHERE Descripcion = @Descripcion;
	END
END
GO
/****** Object:  StoredProcedure [dbo].[p_SetAlmacen]    Script Date: 30/10/2014 11:43:43 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jesus Huante>
-- Create date: <21/10/2014>
-- Description:	<Procedimiento que permite la sincronizacion de los almacenes >
-- =============================================
CREATE PROCEDURE [dbo].[p_SetAlmacen] @Identificador varchar(5), @Descripcion varchar(50), @IdAlmacen int OUT
AS
BEGIN
	SET @Identificador = LTRIM(RTRIM(@Identificador));
	SET @Descripcion = LTRIM(RTRIM(@Descripcion));
	IF NOT EXISTS (SELECT * FROM Almacenes WHERE Identificador = @Identificador) 
	BEGIN
		INSERT INTO Almacenes (Identificador, Descripcion) VALUES (@Identificador , @Descripcion);
		SELECT @IdAlmacen = @@identity;
	END
	ELSE
	BEGIN
		SELECT @IdAlmacen = IdAlmacen FROM Almacenes WHERE Identificador = @Identificador;
	END
END
GO
/****** Object:  StoredProcedure [dbo].[p_SetAlmacenFromDUX]    Script Date: 30/10/2014 11:43:43 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jesus Huante>
-- Create date: <21/10/2014>
-- Description:	<Procedimiento que permite la sincronizacion de Almacenes>
-- =============================================
CREATE PROCEDURE [dbo].[p_SetAlmacenFromDUX]
AS
BEGIN
	DECLARE @IdAlmacen int;
	DECLARE @IDENTIFICACION varchar(5);
	DECLARE @DESCRIPCION varchar(50);
	-- 
    DECLARE almacen_cursor CURSOR FOR 
	SELECT IDENTIFICACION, DESCRIPCION FROM DUX_ALMACEN
	ORDER BY IDENTIFICACION
    OPEN almacen_cursor
    FETCH NEXT FROM almacen_cursor INTO @IDENTIFICACION, @DESCRIPCION
    WHILE @@FETCH_STATUS = 0
    BEGIN
		EXECUTE [p_SetAlmacen] @IDENTIFICACION, @DESCRIPCION, @IdAlmacen OUT;
	    FETCH NEXT FROM almacen_cursor INTO @IDENTIFICACION, @DESCRIPCION
    END
    CLOSE almacen_cursor
    DEALLOCATE almacen_cursor
END
GO
/****** Object:  StoredProcedure [dbo].[p_SetAlmacenProducto]    Script Date: 30/10/2014 11:43:43 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jesus Huante>
-- Create date: <21/10/2014>
-- Description:	<Procedimiento que permite la sincronizacion de las existencias de productos en los almacenes>
-- =============================================
CREATE PROCEDURE [dbo].[p_SetAlmacenProducto] @Almacen varchar(20), @Producto varchar(20), @Existencia decimal(15,4),
@IdAlmacenProducto int OUT
AS
BEGIN
	DECLARE @IdAlmacen int = 1; 
	DECLARE @IdProducto int = 1; 
	-- Elimina Espacios
	SET @Almacen = LTRIM(RTRIM(@Almacen));
	SET @Producto = LTRIM(RTRIM(@Producto));
	-- Identifica el almacen
	EXECUTE p_SetAlmacen @Almacen, @Almacen, @IdAlmacen OUT;
	-- Identifica el producto
	SELECT @IdProducto = IdProducto FROM Productos WHERE Identificacion = @Producto
	-- Si el producto no fue encontrado no se efectua operacion alguna debido a que no todos los productos seran importados
	IF @IdProducto IS NOT NULL
	BEGIN
		IF NOT EXISTS (SELECT * FROM AlmacenesProducto WHERE IdAlmacen = @IdAlmacen AND IdProducto = @IdProducto) 
		BEGIN
			INSERT INTO AlmacenesProducto
					   ([IdAlmacen]
					   ,[IdProducto]
					   ,[Existencia])
				 VALUES
					   (@IdAlmacen
					   ,@IdProducto
					   ,@Existencia);
			SELECT @IdAlmacenProducto = @@identity 
		END
		ELSE
		BEGIN
			UPDATE AlmacenesProducto
			   SET [Existencia] = @Existencia
			WHERE IdAlmacen = @IdAlmacen AND IdProducto = @IdProducto
			SELECT @IdAlmacenProducto = IdAlmacenProducto FROM AlmacenesProducto WHERE IdAlmacen = @IdAlmacen AND IdProducto = @IdProducto;
		END
	END
END
GO
/****** Object:  StoredProcedure [dbo].[p_SetAlmacenProductoFromDUX]    Script Date: 30/10/2014 11:43:43 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jesus Huante>
-- Create date: <21/10/2014>
-- Description:	<Procedimiento que permite la sincronizacion de AlmacenesProducto>
-- =============================================
CREATE PROCEDURE [dbo].[p_SetAlmacenProductoFromDUX]
AS
BEGIN
	DECLARE @IdAlmacenProducto int
	DECLARE @Almacen varchar(20)
	DECLARE @Producto varchar(20)
	DECLARE @Existencia decimal(15,4)
	-- 
    DECLARE almacen_cursor CURSOR FOR 
	SELECT ALMACEN, PRODUCTO, EXISTENCIA FROM DUX_ALMPROD
    OPEN almacen_cursor
    FETCH NEXT FROM almacen_cursor INTO @Almacen, @Producto, @Existencia
    WHILE @@FETCH_STATUS = 0
    BEGIN
		EXECUTE p_SetAlmacenProducto @Almacen, @Producto, @Existencia, @IdAlmacenProducto OUT;
		FETCH NEXT FROM almacen_cursor INTO @Almacen, @Producto, @Existencia
    END
    CLOSE almacen_cursor
    DEALLOCATE almacen_cursor
END
GO
/****** Object:  StoredProcedure [dbo].[p_SetMarca]    Script Date: 30/10/2014 11:43:43 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jesus Huante>
-- Create date: <20/10/2014>
-- Description:	<Procedimiento que permite la sincronizacion de Marcas >
-- =============================================
CREATE PROCEDURE [dbo].[p_SetMarca] @Identificador varchar(5), @Descripcion varchar(30), @IdMarca int OUT
AS
BEGIN
	SET @Identificador = LTRIM(RTRIM(@Identificador));
	SET @Descripcion = LTRIM(RTRIM(@Descripcion));
	IF NOT EXISTS (SELECT * FROM Marcas WHERE Descripcion = @Descripcion) 
	BEGIN
		INSERT INTO Marcas (Identificador, Descripcion) VALUES (@Identificador , @Descripcion);
		SELECT @IdMarca = @@identity;
	END
	ELSE
	BEGIN
		SELECT @IdMarca = IdMarca FROM Marcas WHERE Descripcion = @Descripcion;
	END
END
GO
/****** Object:  StoredProcedure [dbo].[p_SetPedido]    Script Date: 30/10/2014 11:43:43 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jesus Huante>
-- Create date: <23/10/2014>
-- Description:	<Procedimiento que permite la actualizacion de los pedidos de produccion>
-- =============================================
CREATE PROCEDURE [dbo].[p_SetPedido] @Almacen varchar(5), @Producto varchar(20), @Codigo int, @Numero int, @Fecha date, @Cliente varchar(15), 
@OrdenCompra varchar(20), @Estatus int, @Cantidad decimal(15,6), @SaldoCantidad decimal(15,6), @FechaEmbarque date, @NivelRiesgo int,
@Observaciones text, @IdPedido int OUT
AS
BEGIN
	-- Constantes
	DECLARE @DefIdAlmacen int = 1; 
	DECLARE @DefIdProducto int = 1; 
	-- Variables
	DECLARE @IdAlmacen int; 
	DECLARE @IdProducto int; 
	-- Elimina Espacios
	SET @Almacen = LTRIM(RTRIM(@Almacen));
	SET @Producto = LTRIM(RTRIM(@Producto));
	-- Identifica el almacen
	SELECT @IdAlmacen = IdAlmacen FROM Almacenes WHERE Identificador = @Almacen;
	IF @IdAlmacen IS NULL SET @IdAlmacen = @DefIdAlmacen;
	-- Identifica el producto
	SELECT @IdProducto = IdProducto FROM Productos WHERE Identificacion = @Producto;
	IF @IdProducto IS NULL SET @IdProducto = @DefIdProducto;
	-- Si el producto no fue encontrado no se efectua operacion alguna debido a que no todos los productos seran importados
	IF NOT EXISTS (SELECT * FROM Pedidos WHERE Codigo = @Codigo AND Numero = @Numero) 
	BEGIN
		INSERT INTO Pedidos
				   ([IdAlmacen]
				   ,[IdProducto]
				   ,[Codigo]
				   ,[Numero]
				   ,[Fecha]
				   ,[Cliente]
				   ,[OrdenCompra]
				   ,[Estatus]
				   ,[Cantidad]
				   ,[SaldoCantidad]
				   ,[FechaEmbarque]
				   ,[NivelRiesgo]
				   ,[Observaciones]
				   ,[TotalProgramado])
			 VALUES
				   (@IdAlmacen
				   ,@IdProducto
				   ,@Codigo
				   ,@Numero
				   ,@Fecha
				   ,@Cliente
				   ,@OrdenCompra
				   ,@Estatus
				   ,@Cantidad
				   ,@SaldoCantidad
				   ,@FechaEmbarque
				   ,@NivelRiesgo
				   ,@Observaciones
				   ,0);
		SELECT @IdPedido = @@identity;
	END
	ELSE
	BEGIN
		UPDATE Pedidos
		   SET [IdAlmacen] = @IdAlmacen
			  ,[IdProducto] = @IdProducto
			  ,[Codigo] = @Codigo
			  ,[Numero] = @Numero
			  ,[Fecha] = @Fecha
			  ,[Cliente] = @Cliente
			  ,[OrdenCompra] = @OrdenCompra
			  ,[Estatus] = @Estatus
			  ,[Cantidad] = @Cantidad
			  ,[SaldoCantidad] = @SaldoCantidad
			  ,[FechaEmbarque] = @FechaEmbarque
			  ,[NivelRiesgo] = @NivelRiesgo
			  ,[Observaciones] = @Observaciones
		 WHERE Codigo = @Codigo AND Numero = @Numero;
		SELECT @IdPedido = IdPedido FROM Pedidos WHERE Codigo = @Codigo AND Numero = @Numero;
	END
END
GO
/****** Object:  StoredProcedure [dbo].[p_SetPedidosFromDUX]    Script Date: 30/10/2014 11:43:43 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jesus Huante>
-- Create date: <23/10/2014>
-- Description:	<Procedimiento que permite la sincronizacion de Pedidos desde DUX>
-- =============================================
CREATE PROCEDURE [dbo].[p_SetPedidosFromDUX]
AS
BEGIN
	DECLARE @Almacen varchar(5)
	DECLARE @Producto varchar(20)
	DECLARE @Codigo int
	DECLARE @Numero int
	DECLARE @Fecha date
	DECLARE @Cliente varchar(15)
	DECLARE @OrdenCompra varchar(20)
	DECLARE @Estatus int
	DECLARE @Cantidad decimal(15,6)
	DECLARE @SaldoCantidad decimal(15,6)
	DECLARE @FechaEmbarque date
	DECLARE @NivelRiesgo int
	DECLARE @Observaciones varchar(MAX)
	DECLARE @IdPedido int
	-- 
    DECLARE pedido_cursor CURSOR FOR 
	SELECT OE.ALMACEN, POE.PRODUCTO, POE.CODIGO, POE.NUMERO, OE.FECHA, OE.CLIENTE, 
	OE.DOCUMENTO1, OE.STATUS, POE.CANTIDAD, POE.SALDOCANTIDAD, POE.DOCTOADICIONALFECHA, 
	C.NIVELRIESGO, POE.OBSERVACIONES
	FROM DUX_PAROEN POE
	INNER JOIN DUX_OENTREGA OE ON POE.CODIGO = OE.CODIGO 
	INNER JOIN DUX_CLIENTES C ON OE.CLIENTE = C.CODIGO
    OPEN pedido_cursor
    FETCH NEXT FROM pedido_cursor INTO @Almacen, @Producto, @Codigo, @Numero, @Fecha, @Cliente, 
	@OrdenCompra, @Estatus, @Cantidad, @SaldoCantidad, @FechaEmbarque, @NivelRiesgo, @Observaciones
    WHILE @@FETCH_STATUS = 0
    BEGIN
		EXECUTE p_SetPedido @Almacen, @Producto, @Codigo, @Numero, @Fecha, @Cliente, 
		@OrdenCompra, @Estatus, @Cantidad, @SaldoCantidad, @FechaEmbarque, @NivelRiesgo, @Observaciones, @IdPedido OUT;
		FETCH NEXT FROM pedido_cursor INTO @Almacen, @Producto, @Codigo, @Numero, @Fecha, @Cliente, 
		@OrdenCompra, @Estatus, @Cantidad, @SaldoCantidad, @FechaEmbarque, @NivelRiesgo, @Observaciones
    END
    CLOSE pedido_cursor
    DEALLOCATE pedido_cursor
END
GO
/****** Object:  StoredProcedure [dbo].[p_SetProductoFromDUX]    Script Date: 30/10/2014 11:43:43 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jesus Huante>
-- Create date: <20/10/2014>
-- Description:	<Procedimiento que permite la sincronizacion de Marcas >
-- =============================================
CREATE PROCEDURE [dbo].[p_SetProductoFromDUX]
AS
BEGIN
	DECLARE @SeVende int
	DECLARE @Marca varchar(20)
	DECLARE @Presentacion varchar(30)
	DECLARE @Aleacion varchar(50)
	DECLARE @ProductoCasting varchar(50)
	DECLARE @Identificacion varchar(20)
	DECLARE @Descripcion varchar(60)
	DECLARE @CAMPOUSUARIO1 varchar(50)
	DECLARE @CAMPOUSUARIO2 varchar(50)
	DECLARE @CAMPOUSUARIO4 varchar(50)
	DECLARE @PiezasMolde int
	DECLARE @CiclosMolde int
	DECLARE @PesoCasting decimal(15,4)
	DECLARE @PesoArania decimal(15,4)
	DECLARE @IdProducto int
	-- Primero se generan los productos casting, que es la base
    DECLARE product_cursor CURSOR FOR 
	SELECT ORDEN, PRESENTACION, CAMPOUSUARIO3, CAMPOUSUARIO5,
	Identificacion, Descripcion, TIEMPOSURTIDO, 
	CAMPOUSUARIO4, CAMPOUSUARIO1, CAMPOUSUARIO2 FROM DUX_PRODUCTO
	WHERE SEVENDE = 1
	AND IDENTIFICACION = CAMPOUSUARIO5
	ORDER BY Identificacion
    OPEN product_cursor
    FETCH NEXT FROM product_cursor INTO @Marca,@Presentacion,@Aleacion,@ProductoCasting,
	@Identificacion,@Descripcion, @PiezasMolde, @CAMPOUSUARIO4,@CAMPOUSUARIO1,@CAMPOUSUARIO2
    WHILE @@FETCH_STATUS = 0
    BEGIN
		IF TRY_CAST(@CAMPOUSUARIO4 AS int) IS NULL SET @CiclosMolde = -1 ELSE SET @CiclosMolde = CAST(@CAMPOUSUARIO4 AS int)
		IF ISNUMERIC(@CAMPOUSUARIO1) = 1  SET @PesoCasting = @CAMPOUSUARIO1; ELSE SET @PesoCasting = -1
		IF ISNUMERIC(@CAMPOUSUARIO2) = 1  SET @PesoArania = @CAMPOUSUARIO2; ELSE SET @PesoArania = -1
		EXECUTE [p_SetProductos] @Marca,@Presentacion,@Aleacion,@ProductoCasting,@Identificacion,@Descripcion,
		@PiezasMolde,@CiclosMolde,@PesoCasting,@PesoArania,@IdProducto OUT;
		FETCH NEXT FROM product_cursor INTO @Marca,@Presentacion,@Aleacion,@ProductoCasting,
		@Identificacion,@Descripcion, @PiezasMolde, @CAMPOUSUARIO4,@CAMPOUSUARIO1,@CAMPOUSUARIO2
    END
    CLOSE product_cursor
    DEALLOCATE product_cursor
	-- Posteriormente se adicionan los productos restantes
    DECLARE product_cursor CURSOR FOR 
	SELECT ORDEN, PRESENTACION, CAMPOUSUARIO3, CAMPOUSUARIO5,
	Identificacion, Descripcion, TIEMPOSURTIDO, 
	CAMPOUSUARIO4, CAMPOUSUARIO1, CAMPOUSUARIO2 FROM DUX_PRODUCTO
	WHERE SEVENDE = 1
	AND IDENTIFICACION <> CAMPOUSUARIO5
	ORDER BY Identificacion
    OPEN product_cursor
    FETCH NEXT FROM product_cursor INTO @Marca,@Presentacion,@Aleacion,@ProductoCasting,
	@Identificacion,@Descripcion, @PiezasMolde, @CAMPOUSUARIO4,@CAMPOUSUARIO1,@CAMPOUSUARIO2
    WHILE @@FETCH_STATUS = 0
    BEGIN
		IF TRY_CAST(@CAMPOUSUARIO4 AS int) IS NULL SET @CiclosMolde = -1 ELSE SET @CiclosMolde = CAST(@CAMPOUSUARIO4 AS int)
		IF ISNUMERIC(@CAMPOUSUARIO1) = 1  SET @PesoCasting = @CAMPOUSUARIO1; ELSE SET @PesoCasting = -1
		IF ISNUMERIC(@CAMPOUSUARIO2) = 1  SET @PesoArania = @CAMPOUSUARIO2; ELSE SET @PesoArania = -1
		EXECUTE [p_SetProductos] @Marca,@Presentacion,@Aleacion,@ProductoCasting,@Identificacion,@Descripcion,
		@PiezasMolde,@CiclosMolde,@PesoCasting,@PesoArania,@IdProducto OUT;
		FETCH NEXT FROM product_cursor INTO @Marca,@Presentacion,@Aleacion,@ProductoCasting,
		@Identificacion,@Descripcion, @PiezasMolde, @CAMPOUSUARIO4,@CAMPOUSUARIO1,@CAMPOUSUARIO2
    END
    CLOSE product_cursor
    DEALLOCATE product_cursor
END


GO
/****** Object:  StoredProcedure [dbo].[p_SetProductos]    Script Date: 30/10/2014 11:43:43 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jesus Huante>
-- Create date: <20/10/2014>
-- Description:	<Procedimiento que permite la sincronizacion de Productos>
-- =============================================
CREATE PROCEDURE [dbo].[p_SetProductos] @Marca varchar(20), @Presentacion varchar(30), 
@Aleacion varchar(50), @ProductoCasting varchar(50), @Identificacion varchar(20),
@Descripcion varchar(60), @PiezasMolde int, @CiclosMolde int, @PesoCasting decimal(15,4), @PesoArania decimal(15,4),
--@DUXCiclosMolde varchar(50), @DUXPesoCasting varchar(50), @DUXPesoArania varchar(50),
@IdProducto int OUT
AS
BEGIN
	DECLARE @IdMarca int = 1; 
	DECLARE @IdPresntacion int = 1; 
	DECLARE @IdAleacion int = 1; 
	DECLARE @IdProductoCasting int = 1; 
	--DECLARE @CiclosMolde int
	--DECLARE @PesoCasting decimal(15,4)
	--DECLARE @PesoArania decimal(15,4)
	-- Elimina Espacios
	SET @Marca = LTRIM(RTRIM(@Marca));
	SET @Presentacion = LTRIM(RTRIM(@Presentacion));
	SET @Aleacion = LTRIM(RTRIM(@Aleacion));
	SET @ProductoCasting = LTRIM(RTRIM(@ProductoCasting));
	SET @Identificacion = LTRIM(RTRIM(@Identificacion));
	SET @Descripcion = LTRIM(RTRIM(@Descripcion));
	-- Identifica la marca del producto
	EXECUTE p_SetMarca @Marca, @Marca, @IdMarca OUT;
	-- Identifica la Presntecion
	IF @Presentacion = 'ACE' SET @IdPresntacion = 2;
	IF @Presentacion = 'BRO' SET @IdPresntacion = 3;
	-- Identifica la aleacion del producto
	EXECUTE p_SetAleacion @Aleacion, @Aleacion, @IdAleacion OUT;
	--Obtiene el casting del producto
	SELECT @IdProductoCasting = IdProducto FROM Productos WHERE Identificacion = @ProductoCasting
	---- Valida variables tipo varchar
	--IF TRY_CAST(@DUXCiclosMolde AS int) IS NULL SET @CiclosMolde = -1 ELSE SET @CiclosMolde = CAST(@DUXCiclosMolde AS int)
	--IF ISNUMERIC(@DUXPesoCasting) = 1  SET @PesoCasting = @DUXPesoCasting; ELSE SET @PesoCasting = -1
	--IF ISNUMERIC(@DUXPesoArania) = 1  SET @PesoArania = @DUXPesoArania; ELSE SET @PesoArania = -1
	-- Identidica si se agrega o se actualiza el producto
	IF NOT EXISTS (SELECT * FROM Productos WHERE Identificacion = @Identificacion) 
	BEGIN
		INSERT INTO Productos
				   ([IdMarca]
				   ,[IdPresentacion]
				   ,[IdAleacion]
				   ,[IdProductoCasting]
				   ,[Identificacion]
				   ,[Descripcion]
				   ,[PiezasMolde]
				   ,[CiclosMolde]
				   ,[PesoCasting]
				   ,[PesoArania])
			 VALUES
				   (@IdMarca
				   ,@IdPresntacion
				   ,@IdAleacion
				   ,@IdProductoCasting
				   ,@Identificacion
				   ,@Descripcion
				   ,@PiezasMolde
				   ,@CiclosMolde
				   ,@PesoCasting
				   ,@PesoArania);
		SELECT @IdProducto = @@identity 
	END
	ELSE
	BEGIN
		UPDATE Productos
		   SET [IdMarca] = @IdMarca
			  ,[IdPresentacion] = @IdPresntacion
			  ,[IdAleacion] = @IdAleacion
			  ,[IdProductoCasting] = @IdProductoCasting
			  ,[Descripcion] = @Descripcion
			  ,[PiezasMolde] = @PiezasMolde
			  ,[CiclosMolde] = @CiclosMolde
			  ,[PesoCasting] = @PesoCasting
			  ,[PesoArania] = @PesoArania
		WHERE Identificacion = @Identificacion
		SELECT @IdProducto = IdProducto FROM Productos WHERE Identificacion = @Identificacion;
	END
END
GO
/****** Object:  StoredProcedure [dbo].[p_SetProgramacionSemana]    Script Date: 30/10/2014 11:43:43 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jesus Huante>
-- Create date: <27/10/2014>
-- Description:	<Procedimiento que permite la sincronizacion de la programacion semanal >
-- =============================================
CREATE PROCEDURE [dbo].[p_SetProgramacionSemana] @IdProgramacion int, @Anio int, @Semana int,
@Prioridad int, @Programadas int, @IdProgramacionSemana int OUT
AS
BEGIN
	IF NOT EXISTS (SELECT * FROM ProgramacionesSemana WHERE IdProgramacion = @IdProgramacion AND Anio = @Anio AND Semana = @Semana) 
	BEGIN
		INSERT INTO ProgramacionesSemana([IdProgramacion],[Anio],[Semana],[Prioridad],[Programadas])
		VALUES (@IdProgramacion, @Anio, @Semana, @Prioridad, @Programadas)
		SELECT @IdProgramacionSemana = @@identity;
	END
	ELSE
	BEGIN
		SELECT @IdProgramacionSemana = IdProgramacionSemana FROM ProgramacionesSemana WHERE IdProgramacion = @IdProgramacion AND Anio = @Anio AND Semana = @Semana;
		UPDATE ProgramacionesSemana
		   SET [IdProgramacion] = @IdProgramacion
			  ,[Anio] = @Anio
			  ,[Semana] = @Semana
			  ,[Prioridad] = @Prioridad
			  ,[Programadas] = @Programadas
--			  ,[Hechas] = @Hechas
		WHERE IdProgramacionSemana = @IdProgramacionSemana
	END
END
GO
/****** Object:  Table [dbo].[Aleaciones]    Script Date: 30/10/2014 11:43:43 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Aleaciones](
	[IdAleacion] [int] IDENTITY(1,1) NOT NULL,
	[Identificador] [varchar](5) NOT NULL,
	[Descripcion] [varchar](30) NOT NULL,
 CONSTRAINT [PK_Aleaciones] PRIMARY KEY CLUSTERED 
(
	[IdAleacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Almacenes]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Almacenes](
	[IdAlmacen] [int] IDENTITY(1,1) NOT NULL,
	[Identificador] [varchar](5) NOT NULL,
	[Descripcion] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Almacenes] PRIMARY KEY CLUSTERED 
(
	[IdAlmacen] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AlmacenesProducto]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AlmacenesProducto](
	[IdAlmacenProducto] [int] IDENTITY(1,1) NOT NULL,
	[IdAlmacen] [int] NOT NULL,
	[IdProducto] [int] NOT NULL,
	[Existencia] [decimal](15, 4) NOT NULL,
 CONSTRAINT [PK_AlmacenesProducto] PRIMARY KEY CLUSTERED 
(
	[IdAlmacenProducto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Almas]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Almas](
	[IdAlma] [int] IDENTITY(1,1) NOT NULL,
	[IdProducto] [int] NOT NULL,
	[IdAlmaTipo] [int] NOT NULL,
	[IdAlmaMaterialCaja] [int] NOT NULL,
	[IdAlmaReceta] [int] NOT NULL,
	[Existencia] [int] NOT NULL,
	[PiezasCaja] [int] NOT NULL,
	[PiezasMolde] [int] NOT NULL,
	[Peso] [real] NULL,
	[TiempoLlenado] [real] NULL,
	[TiempoFraguado] [real] NULL,
	[TiempoGaseoDirectro] [real] NULL,
	[TiempoGaseoIndirecto] [real] NULL,
 CONSTRAINT [PK_Almas] PRIMARY KEY CLUSTERED 
(
	[IdAlma] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AlmasMaterialCaja]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AlmasMaterialCaja](
	[IdAlmaMaterialCaja] [int] IDENTITY(1,1) NOT NULL,
	[Identificador] [varchar](5) NOT NULL,
	[Dscripcion] [varchar](20) NOT NULL,
 CONSTRAINT [PK_AlmasMaterialCaja] PRIMARY KEY CLUSTERED 
(
	[IdAlmaMaterialCaja] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AlmasProduccionDefecto]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AlmasProduccionDefecto](
	[IdAlmaProduccionDefecto] [int] IDENTITY(1,1) NOT NULL,
	[IdAlmaProduccionDetalle] [int] NOT NULL,
	[IdDefecto] [int] NOT NULL,
	[Rechazada] [int] NULL,
 CONSTRAINT [PK_AlmasProduccionDefecto] PRIMARY KEY CLUSTERED 
(
	[IdAlmaProduccionDefecto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AlmasProduccionDetalle]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AlmasProduccionDetalle](
	[IdAlmaProduccion] [int] IDENTITY(1,1) NOT NULL,
	[IdProduccion] [int] NOT NULL,
	[IdProgramacionAlma] [int] NOT NULL,
	[IdAlma] [int] NOT NULL,
	[Inicio] [datetime2](7) NOT NULL,
	[Fin] [datetime2](7) NOT NULL,
	[Programadas] [int] NOT NULL,
	[Hechas] [int] NOT NULL,
	[Rechazadas] [int] NOT NULL,
 CONSTRAINT [PK_AlmasProduccionDetalle] PRIMARY KEY CLUSTERED 
(
	[IdAlmaProduccion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AlmasRecetas]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AlmasRecetas](
	[IdAlmaReceta] [int] IDENTITY(1,1) NOT NULL,
	[Identificador] [varchar](5) NOT NULL,
	[Descripcion] [varchar](20) NOT NULL,
 CONSTRAINT [PK_AlmasRecetas] PRIMARY KEY CLUSTERED 
(
	[IdAlmaReceta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AlmasTipo]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AlmasTipo](
	[IdAlmaTipo] [int] IDENTITY(1,1) NOT NULL,
	[Identificador] [varchar](5) NOT NULL,
	[Descrfipcion] [varchar](20) NOT NULL,
 CONSTRAINT [PK_AlmasTipo] PRIMARY KEY CLUSTERED 
(
	[IdAlmaTipo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Areas]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Areas](
	[IdArea] [int] NOT NULL,
	[Identificador] [varchar](5) NOT NULL,
	[Descripcion] [varchar](30) NOT NULL,
 CONSTRAINT [PK_Areas] PRIMARY KEY CLUSTERED 
(
	[IdArea] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Camisas]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Camisas](
	[IdCamisa] [int] IDENTITY(1,1) NOT NULL,
	[IdProducto] [int] NOT NULL,
	[IdCamisaTipo] [int] NOT NULL,
	[Cantidad] [int] NOT NULL,
 CONSTRAINT [PK_Camisas] PRIMARY KEY CLUSTERED 
(
	[IdCamisa] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CamisasTipo]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CamisasTipo](
	[IdCamisaTipo] [int] IDENTITY(1,1) NOT NULL,
	[Identificador] [varchar](5) NOT NULL,
	[Descripcion] [varchar](30) NOT NULL,
	[CantidadPorPaquete] [int] NOT NULL,
	[DUX_CodigoPesos] [varchar](20) NULL,
	[DUX_CodigoDolares] [varchar](20) NULL,
 CONSTRAINT [PK_CamisasTipo] PRIMARY KEY CLUSTERED 
(
	[IdCamisaTipo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Causas]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Causas](
	[IdCausa] [int] IDENTITY(1,1) NOT NULL,
	[IdCausaTipo] [int] NOT NULL,
	[Indentificador] [varchar](5) NOT NULL,
	[Descripcion] [varchar](60) NOT NULL,
	[IdProceso] [int] NOT NULL,
 CONSTRAINT [PK_Causas] PRIMARY KEY CLUSTERED 
(
	[IdCausa] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CausasTipo]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CausasTipo](
	[IdCausaTipo] [int] IDENTITY(1,1) NOT NULL,
	[Identificador] [varchar](5) NOT NULL,
	[Descripcion] [varchar](20) NOT NULL,
 CONSTRAINT [PK_CausasTipo] PRIMARY KEY CLUSTERED 
(
	[IdCausaTipo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CentrosTrabajo]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CentrosTrabajo](
	[IdCentroTrabajo] [int] IDENTITY(1,1) NOT NULL,
	[Identificador] [varchar](5) NOT NULL,
	[Descripcion] [varchar](50) NOT NULL,
	[IdProceso] [int] NOT NULL,
 CONSTRAINT [PK_CentrosTrabajo] PRIMARY KEY CLUSTERED 
(
	[IdCentroTrabajo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Defectos]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Defectos](
	[IdDefecto] [int] IDENTITY(1,1) NOT NULL,
	[IdDefectoTipo] [int] NOT NULL,
	[Identificador] [varchar](5) NOT NULL,
	[Descripcion] [varchar](60) NOT NULL,
	[IdProceso] [int] NOT NULL,
 CONSTRAINT [PK_Defectos] PRIMARY KEY CLUSTERED 
(
	[IdDefecto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DefectosTipo]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DefectosTipo](
	[IdDefectoTipo] [int] IDENTITY(1,1) NOT NULL,
	[Identificador] [varchar](5) NOT NULL,
	[Descripcion] [varchar](30) NOT NULL,
 CONSTRAINT [PK_DefectosTipo] PRIMARY KEY CLUSTERED 
(
	[IdDefectoTipo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DUX_ALMACEN]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DUX_ALMACEN](
	[IDENTIFICACION] [char](20) NOT NULL,
	[DESCRIPCION] [char](40) NULL,
	[FECHAMODIFICACION] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[IDENTIFICACION] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DUX_ALMPROD]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DUX_ALMPROD](
	[PRODUCTO] [char](20) NULL,
	[ALMACEN] [char](20) NULL,
	[CUENTACONTABLEVENTA] [char](19) NULL,
	[CUENTACONTABLECOMPRA] [char](19) NULL,
	[CUENTACONTABLECOSTOVENTAS] [char](19) NULL,
	[EXISTENCIA] [numeric](15, 6) NULL,
	[COSTO] [numeric](15, 6) NULL,
	[ULTIMOCOSTO] [numeric](15, 6) NULL,
	[COSTOPROMEDIO] [numeric](15, 6) NULL,
	[MAXIMO] [numeric](15, 6) NULL,
	[MINIMO] [numeric](15, 6) NULL,
	[PUNTOREORDEN] [numeric](15, 6) NULL,
	[UBICACION] [char](50) NULL,
	[FECHAMODIFICACION] [date] NULL,
	[CUENTACONTABLEORDEN] [char](19) NULL,
	[CANTIDADRESERVADA] [numeric](19, 6) NULL,
	[CUENTACONTABLEESPECIAL] [char](19) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DUX_CLIENTES]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DUX_CLIENTES](
	[CODIGO] [char](15) NULL,
	[NOMBRE] [char](100) NULL,
	[CONTACTO] [char](45) NULL,
	[RFC] [char](15) NULL,
	[DOMICILIO] [char](50) NULL,
	[COLONIA] [char](50) NULL,
	[CIUDAD] [char](50) NULL,
	[ESTADO] [char](40) NULL,
	[CP] [char](5) NULL,
	[PAIS] [char](20) NULL,
	[TELEFONO1] [char](40) NULL,
	[TELEFONO2] [char](40) NULL,
	[TELEFONO3] [char](40) NULL,
	[FAX] [char](40) NULL,
	[CLASIFICACION] [char](20) NULL,
	[ZONA] [char](20) NULL,
	[IVADESGLOSADO] [int] NULL,
	[AGENTE] [char](40) NULL,
	[DESCUENTO] [char](20) NULL,
	[DIASCREDITO] [int] NULL,
	[LIMITECREDITO] [numeric](11, 2) NULL,
	[FECHAINICIORELACIONES] [date] NULL,
	[FECHAULTIMOMOVIMIENTO] [date] NULL,
	[CONCEPTO] [char](50) NULL,
	[CUENTACONTABLE] [char](19) NULL,
	[BLOQUEADO] [int] NULL,
	[MOTIVOBLOQUEO] [char](40) NULL,
	[FECHAALTA] [date] NULL,
	[PUBLICOGENERAL] [int] NULL,
	[GOLDMINE] [char](20) NULL,
	[EMAIL] [char](50) NULL,
	[PAGINAWEB] [char](50) NULL,
	[CODIGOADICIONAL] [char](20) NULL,
	[ALMACEN] [char](20) NULL,
	[SUBALMACEN] [char](20) NULL,
	[INTERCOMPANIA] [int] NULL,
	[CUENTACONTABLECOSTOVENTAS] [char](19) NULL,
	[CUENTACONTABLEVENTAS] [char](19) NULL,
	[AUTORIZADOPOR] [char](50) NULL,
	[FECHAAUTORIZACION] [date] NULL,
	[NIVELRIESGO] [char](5) NULL,
	[COMENTARIOSCREDITO] [char](50) NULL,
	[CAMPOUSUARIO1] [char](50) NULL,
	[CAMPOUSUARIO2] [char](50) NULL,
	[CAMPOUSUARIO3] [char](50) NULL,
	[CAMPOUSUARIO4] [char](50) NULL,
	[CAMPOUSUARIO5] [char](50) NULL,
	[CUENTACONTABLEORDEN] [char](19) NULL,
	[AGENTECOBRANZA] [char](40) NULL,
	[COBRARIVA] [int] NULL,
	[CURP] [char](20) NULL,
	[RLUNES] [int] NULL,
	[RMARTES] [int] NULL,
	[RMIERCOLES] [int] NULL,
	[RJUEVES] [int] NULL,
	[RVIERNES] [int] NULL,
	[RSABADO] [int] NULL,
	[RDOMINGO] [int] NULL,
	[PLUNES] [int] NULL,
	[PMARTES] [int] NULL,
	[PMIERCOLES] [int] NULL,
	[PJUEVES] [int] NULL,
	[PVIERNES] [int] NULL,
	[PSABADO] [int] NULL,
	[PDOMINGO] [int] NULL,
	[NOMBRECOMERCIAL] [char](80) NULL,
	[ENTRECALLE1] [char](60) NULL,
	[ENTRECALLE2] [char](60) NULL,
	[HORARIO] [char](40) NULL,
	[DELEGACION] [char](50) NULL,
	[ESPECIFICACIONFECHAREVISION] [char](70) NULL,
	[ESPECIFICACIONFECHAPAGO] [char](70) NULL,
	[HORAINICIOREVISION] [time](7) NULL,
	[HORAFINALREVISION] [time](7) NULL,
	[HORAINICIOPAGO] [time](7) NULL,
	[HORAFINALPAGO] [time](7) NULL,
	[NUMEROEXTERIOR] [char](20) NULL,
	[NUMEROINTERIOR] [char](20) NULL,
	[COORDENADASDOMICILIO] [char](30) NULL,
	[GEOCERCA] [char](6) NULL,
	[DISTANCIAMASDEUNAHORA] [int] NULL,
	[NIVELACCESO] [char](1) NULL,
	[NIVELRIESGOACCESO] [char](1) NULL,
	[ESTACIONAMIENTO] [char](1) NULL,
	[COORDENADASESTACIONAMIENTO] [char](30) NULL,
	[ELUNES] [int] NULL,
	[EMARTES] [int] NULL,
	[EMIERCOLES] [int] NULL,
	[EJUEVES] [int] NULL,
	[EVIERNES] [int] NULL,
	[ESABADO] [int] NULL,
	[EDOMINGO] [int] NULL,
	[HORAINICIOENTREGALUNES] [time](7) NULL,
	[HORAFINALENTREGALUNES] [time](7) NULL,
	[HORAINICIOENTREGAMARTES] [time](7) NULL,
	[HORAFINALENTREGAMARTES] [time](7) NULL,
	[HORAINICIOENTREGAMIERCOLES] [time](7) NULL,
	[HORAFINALENTREGAMIERCOLES] [time](7) NULL,
	[HORAINICIOENTREGAJUEVES] [time](7) NULL,
	[HORAFINALENTREGAJUEVES] [time](7) NULL,
	[HORAINICIOENTREGAVIERNES] [time](7) NULL,
	[HORAFINALENTREGAVIERNES] [time](7) NULL,
	[HORAINICIOENTREGASABADO] [time](7) NULL,
	[HORAFINALENTREGASABADO] [time](7) NULL,
	[HORAINICIOENTREGADOMINGO] [time](7) NULL,
	[HORAFINALENTREGADOMINGO] [time](7) NULL,
	[GEOCERCAESTACIONAMIENTO] [char](6) NULL,
	[METODOPAGO] [int] NULL,
	[DATOSCUENTAPAGO] [char](20) NULL,
	[OBSERVACIONES] [text] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DUX_OENTREGA]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DUX_OENTREGA](
	[CODIGO] [int] NULL,
	[TIPO] [char](1) NULL,
	[NUMERO] [int] NULL,
	[SERIE] [char](3) NULL,
	[FECHA] [date] NULL,
	[CLIENTE] [char](15) NULL,
	[SALDO] [numeric](11, 2) NULL,
	[AGENTE] [char](40) NULL,
	[DIASCREDITO] [int] NULL,
	[FECHAEMBARQUE] [date] NULL,
	[DOMICILIOEMBARQUE] [char](60) NULL,
	[FLETEPOR] [int] NULL,
	[CLIENTERETIRA] [char](50) NULL,
	[DESCUENTOGLOBAL] [numeric](9, 4) NULL,
	[IVADESGLOSADO] [int] NULL,
	[DOCUMENTO1] [char](20) NULL,
	[DOCUMENTO2] [char](20) NULL,
	[DOCUMENTO3] [char](20) NULL,
	[ALMACEN] [char](20) NULL,
	[STATUS] [int] NULL,
	[USUARIO] [char](50) NULL,
	[TOTAL] [numeric](11, 2) NULL,
	[DESCUENTO] [numeric](11, 2) NULL,
	[IVA] [numeric](11, 2) NULL,
	[MES] [int] NULL,
	[FECHAVENCIMIENTO] [date] NULL,
	[COSTOFINANCIERO] [numeric](11, 2) NULL,
	[CONDICIONES] [char](1) NULL,
	[MODIFICARCONDICIONES] [int] NULL,
	[AUTORIZO] [char](50) NULL,
	[MONEDA] [char](20) NULL,
	[COTIZACION] [numeric](7, 4) NULL,
	[NOAFECTAPRODUCCION] [int] NULL,
	[RETENCIONIVA] [numeric](11, 2) NULL,
	[RETENCIONISR] [numeric](11, 2) NULL,
	[RETENCIONIE] [numeric](11, 2) NULL,
	[HORAEMBARQUE] [time](7) NULL,
	[OBSERVACIONES] [text] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DUX_PAROEN]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DUX_PAROEN](
	[CODIGO] [int] NULL,
	[NUMERO] [int] NULL,
	[SERIE] [char](3) NULL,
	[CANTIDAD] [numeric](15, 6) NULL,
	[PRODUCTO] [char](20) NULL,
	[PRECIOUNITARIO] [numeric](15, 6) NULL,
	[DESCUENTO] [numeric](9, 4) NULL,
	[IVA] [numeric](9, 4) NULL,
	[TOTALPARTIDA] [numeric](11, 2) NULL,
	[SALDOCANTIDAD] [numeric](15, 6) NULL,
	[SALDOIMPORTE] [numeric](15, 2) NULL,
	[CODIGOPEDIDO] [int] NULL,
	[PARTIDAPEDIDO] [int] NULL,
	[SALDOCANTIDADFACTURAR] [numeric](15, 6) NULL,
	[SALDOCANCELADO] [numeric](15, 6) NULL,
	[DOCUMENTO1] [char](20) NULL,
	[DOCUMENTO2] [char](20) NULL,
	[DOCUMENTO3] [char](20) NULL,
	[RETENCIONIVA] [int] NULL,
	[RETENCIONISR] [int] NULL,
	[RETENCIONIE] [int] NULL,
	[PORCENTAJERETENCIONIVA] [numeric](7, 4) NULL,
	[PORCENTAJERETENCIONISR] [numeric](7, 4) NULL,
	[PORCENTAJERETENCIONIE] [numeric](7, 4) NULL,
	[NOAFECTAPRODUCCION] [int] NULL,
	[DOCTOADICIONALFECHA] [date] NULL,
	[OBSERVACIONES] [text] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DUX_PRODUCTO]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DUX_PRODUCTO](
	[IDENTIFICACION] [char](20) NOT NULL,
	[DESCRIPCION] [char](60) NULL,
	[CLASIFICACION] [char](20) NULL,
	[UNIDAD] [char](20) NULL,
	[PROVEEDOR] [char](60) NULL,
	[TASA] [char](30) NULL,
	[EXISTENCIA] [numeric](15, 4) NULL,
	[SEVENDE] [int] NULL,
	[SECOMPRA] [int] NULL,
	[ESMANUFACTURABLE] [int] NULL,
	[TIPO] [char](1) NULL,
	[CLASE] [char](3) NULL,
	[ORDEN] [char](20) NULL,
	[FAMILIA] [char](30) NULL,
	[LINEA] [char](30) NULL,
	[PRESENTACION] [char](30) NULL,
	[SUBPRESENTACION] [char](30) NULL,
	[TASACOMPRAS] [char](30) NULL,
	[USAPEDIMENTO] [int] NULL,
	[FECHAMODIFICACION] [date] NULL,
	[UMVENTA] [char](20) NULL,
	[UMCOMPRA] [char](20) NULL,
	[METODOIDENTIFICACION] [char](20) NULL,
	[TIEMPOSURTIDO] [int] NULL,
	[PROVEEDOR2] [char](60) NULL,
	[PROVEEDOR3] [char](60) NULL,
	[CUENTACONTABLE] [char](19) NULL,
	[COSTOESTANDAR] [numeric](19, 6) NULL,
	[COLOR] [char](20) NULL,
	[CAMPOUSUARIO1] [char](50) NULL,
	[CAMPOUSUARIO2] [char](50) NULL,
	[CAMPOUSUARIO3] [char](50) NULL,
	[CAMPOUSUARIO4] [char](50) NULL,
	[CAMPOUSUARIO5] [char](50) NULL,
	[RETENCIONIVA] [char](30) NULL,
	[RETENCIONISR] [char](30) NULL,
	[RETENCIONIE] [char](30) NULL,
	[RETENCIONIVACLIENTES] [char](30) NULL,
	[RETENCIONISRCLIENTES] [char](30) NULL,
	[RETENCIONIECLIENTES] [char](30) NULL,
	[KIT] [int] NULL,
	[PORCENTAJECOMISION] [numeric](5, 2) NULL,
	[NODEDUCIBLEIETU] [int] NULL,
	[ANCHO] [numeric](9, 2) NULL,
	[LARGO] [numeric](9, 2) NULL,
	[PROFUNDIDAD] [numeric](9, 2) NULL,
	[OBSERVACIONES] [text] NULL,
PRIMARY KEY CLUSTERED 
(
	[IDENTIFICACION] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Filtros]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Filtros](
	[IdFiltro] [int] IDENTITY(1,1) NOT NULL,
	[IdProducto] [int] NOT NULL,
	[IdFiltroTipo] [int] NOT NULL,
	[Cantidad] [int] NOT NULL,
 CONSTRAINT [PK_Filtros] PRIMARY KEY CLUSTERED 
(
	[IdFiltro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FiltrosTipo]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FiltrosTipo](
	[IdFiltroTipo] [int] IDENTITY(1,1) NOT NULL,
	[Identificador] [varchar](5) NOT NULL,
	[Descripcion] [varchar](20) NOT NULL,
	[CantidadPorPaquete] [int] NOT NULL,
	[DUX_CodigoPesos] [varchar](20) NULL,
	[DUX_CodigoDolares] [varchar](20) NULL,
 CONSTRAINT [PK_FiltrosTipo] PRIMARY KEY CLUSTERED 
(
	[IdFiltroTipo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Maquinas]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Maquinas](
	[IdMaquina] [int] IDENTITY(1,1) NOT NULL,
	[IdCentroTrabajo] [int] NOT NULL,
	[Identificador] [varchar](5) NOT NULL,
	[Descripcion] [varchar](50) NOT NULL,
	[Consecutivo] [int] NOT NULL,
 CONSTRAINT [PK_Maquinas] PRIMARY KEY CLUSTERED 
(
	[IdMaquina] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Marcas]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Marcas](
	[IdMarca] [int] IDENTITY(1,1) NOT NULL,
	[Identificador] [varchar](5) NOT NULL,
	[Descripcion] [varchar](30) NOT NULL,
 CONSTRAINT [PK_Marcas] PRIMARY KEY CLUSTERED 
(
	[IdMarca] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Materiales]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Materiales](
	[IdMaterial] [int] IDENTITY(1,1) NOT NULL,
	[Identificador] [varchar](10) NOT NULL,
	[Descripcion] [varchar](30) NOT NULL,
 CONSTRAINT [PK_Materiales] PRIMARY KEY CLUSTERED 
(
	[IdMaterial] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MaterialesVaciado]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MaterialesVaciado](
	[IdMaterialVaciado] [int] IDENTITY(1,1) NOT NULL,
	[IdProduccion] [int] NOT NULL,
	[IdMaterial] [int] NOT NULL,
	[Cantidad] [float] NOT NULL,
 CONSTRAINT [PK_MaterialesVaciado] PRIMARY KEY CLUSTERED 
(
	[IdMaterialVaciado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Pedidos]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Pedidos](
	[IdPedido] [int] IDENTITY(1,1) NOT NULL,
	[IdAlmacen] [int] NOT NULL,
	[IdProducto] [int] NOT NULL,
	[Codigo] [int] NOT NULL,
	[Numero] [int] NOT NULL,
	[Fecha] [date] NOT NULL,
	[Cliente] [varchar](15) NOT NULL,
	[OrdenCompra] [varchar](20) NULL,
	[Estatus] [int] NOT NULL,
	[Cantidad] [decimal](15, 6) NOT NULL,
	[SaldoCantidad] [decimal](15, 6) NOT NULL,
	[FechaEmbarque] [date] NULL,
	[NivelRiesgo] [int] NOT NULL,
	[Observaciones] [text] NULL,
	[TotalProgramado] [decimal](15, 6) NOT NULL,
 CONSTRAINT [PK_Pedidos] PRIMARY KEY CLUSTERED 
(
	[IdPedido] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Presentaciones]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Presentaciones](
	[IDPresentacion] [int] IDENTITY(1,1) NOT NULL,
	[Identificador] [varchar](5) NOT NULL,
	[Descripcion] [varchar](30) NOT NULL,
 CONSTRAINT [PK_Presentaciones] PRIMARY KEY CLUSTERED 
(
	[IDPresentacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Procesos]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Procesos](
	[IdProceso] [int] IDENTITY(1,1) NOT NULL,
	[IdArea] [int] NOT NULL,
	[Identificador] [char](2) NOT NULL,
	[Descripcion] [varchar](50) NOT NULL,
	[Secuencia] [int] NOT NULL,
 CONSTRAINT [PK_Procesos] PRIMARY KEY CLUSTERED 
(
	[IdProceso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Producciones]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Producciones](
	[IdProduccion] [int] IDENTITY(1,1) NOT NULL,
	[IdCentroTrabajo] [int] NOT NULL,
	[IdMaquina] [int] NOT NULL,
	[IdUsuario] [int] NOT NULL,
	[IdProduccionEstatus] [int] NOT NULL,
	[Fecha] [datetime2](7) NOT NULL,
	[IdProceso] [int] NOT NULL,
 CONSTRAINT [PK_Producciones] PRIMARY KEY CLUSTERED 
(
	[IdProduccion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ProduccionesDefecto]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProduccionesDefecto](
	[IdProduccionDefecto] [int] IDENTITY(1,1) NOT NULL,
	[IdProduccionDetalle] [int] NOT NULL,
	[IdDefecto] [int] NOT NULL,
	[Rechazadas] [int] NOT NULL,
 CONSTRAINT [PK_ProduccionesDefecto] PRIMARY KEY CLUSTERED 
(
	[IdProduccionDefecto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ProduccionesDetalle]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProduccionesDetalle](
	[IdProduccionDetalle] [int] IDENTITY(1,1) NOT NULL,
	[IdProduccion] [int] NOT NULL,
	[IdProgramacion] [int] NOT NULL,
	[IdProductos] [int] NOT NULL,
	[Inicio] [datetime2](7) NOT NULL,
	[Fin] [datetime2](7) NOT NULL,
	[CiclosMolde] [int] NOT NULL,
	[PiezasMolde] [int] NOT NULL,
	[Programadas] [int] NOT NULL,
	[Hechas] [int] NOT NULL,
	[Rechazadas] [int] NOT NULL,
 CONSTRAINT [PK_ProduccionesDetalle] PRIMARY KEY CLUSTERED 
(
	[IdProduccionDetalle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ProduccionesEstatus]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ProduccionesEstatus](
	[IdProduccionEstatus] [int] IDENTITY(1,1) NOT NULL,
	[Identificador] [char](1) NOT NULL,
	[Descripcion] [varchar](20) NOT NULL,
 CONSTRAINT [PK_ProduccionesEstatus] PRIMARY KEY CLUSTERED 
(
	[IdProduccionEstatus] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Productos]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Productos](
	[IdProducto] [int] IDENTITY(1,1) NOT NULL,
	[IdMarca] [int] NOT NULL,
	[IdPresentacion] [int] NOT NULL,
	[IdAleacion] [int] NOT NULL,
	[IdProductoCasting] [int] NULL,
	[Identificacion] [varchar](20) NOT NULL,
	[Descripcion] [varchar](60) NOT NULL,
	[PiezasMolde] [int] NOT NULL,
	[CiclosMolde] [int] NOT NULL,
	[PesoCasting] [decimal](15, 4) NOT NULL,
	[PesoArania] [decimal](15, 4) NOT NULL,
 CONSTRAINT [PK_Productos] PRIMARY KEY CLUSTERED 
(
	[IdProducto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Programaciones]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Programaciones](
	[IdProgramacion] [int] IDENTITY(1,1) NOT NULL,
	[IdPedido] [int] NOT NULL,
	[IdUsuario] [int] NOT NULL,
	[IdProgramacionEstatus] [int] NOT NULL,
	[IdProducto] [int] NOT NULL,
	[Programadas] [int] NOT NULL,
	[Hechas] [int] NOT NULL,
 CONSTRAINT [PK_Programaciones] PRIMARY KEY CLUSTERED 
(
	[IdProgramacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ProgramacionesAlma]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProgramacionesAlma](
	[IdProgramacionAlma] [int] IDENTITY(1,1) NOT NULL,
	[IdProgramacion] [int] NOT NULL,
	[IdUsuario] [int] NOT NULL,
	[IdProgramacionEstatus] [int] NOT NULL,
	[IdAlmas] [int] NOT NULL,
	[Programadas] [int] NOT NULL,
	[Hechas] [int] NOT NULL,
 CONSTRAINT [PK_ProgramacionesAlma] PRIMARY KEY CLUSTERED 
(
	[IdProgramacionAlma] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ProgramacionesAlmaDia]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProgramacionesAlmaDia](
	[IdProgramacionAlmaDia] [int] IDENTITY(1,1) NOT NULL,
	[IdProgramacionAlmaSemana] [int] NOT NULL,
	[Dia] [date] NOT NULL,
	[Prioridad] [int] NOT NULL,
	[Programadas] [int] NOT NULL,
	[Hechas] [int] NOT NULL,
 CONSTRAINT [PK_ProgramacionesAlmaDia] PRIMARY KEY CLUSTERED 
(
	[IdProgramacionAlmaDia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ProgramacionesAlmaSemana]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProgramacionesAlmaSemana](
	[IdProgramacionAlmaSemana] [int] IDENTITY(1,1) NOT NULL,
	[IdProgramacionAlma] [int] NOT NULL,
	[Anio] [int] NOT NULL,
	[Semana] [int] NOT NULL,
	[Prioridad] [int] NOT NULL,
	[Programadas] [int] NOT NULL,
	[Hechas] [int] NOT NULL,
 CONSTRAINT [PK_ProgramacionesAlmaSemana] PRIMARY KEY CLUSTERED 
(
	[IdProgramacionAlmaSemana] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ProgramacionesDia]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProgramacionesDia](
	[IdProgramacionDia] [int] IDENTITY(1,1) NOT NULL,
	[IdProgramacionSemana] [int] NOT NULL,
	[Dia] [date] NOT NULL,
	[Prioridad] [int] NOT NULL,
	[Programadas] [int] NOT NULL,
	[Hechas] [int] NOT NULL,
 CONSTRAINT [PK_ProgramacionesDia] PRIMARY KEY CLUSTERED 
(
	[IdProgramacionDia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ProgramacionesEstatus]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ProgramacionesEstatus](
	[IdProgramacionEstatus] [int] IDENTITY(1,1) NOT NULL,
	[Identificador] [char](1) NOT NULL,
	[Descripcion] [varchar](20) NOT NULL,
 CONSTRAINT [PK_ProgramacionesEstatus] PRIMARY KEY CLUSTERED 
(
	[IdProgramacionEstatus] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ProgramacionesSemana]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProgramacionesSemana](
	[IdProgramacionSemana] [int] IDENTITY(1,1) NOT NULL,
	[IdProgramacion] [int] NOT NULL,
	[Anio] [int] NOT NULL,
	[Semana] [int] NOT NULL,
	[Prioridad] [int] NOT NULL,
	[Programadas] [int] NOT NULL,
	[Hechas] [int] NOT NULL,
 CONSTRAINT [PK_ProgramacionesSemana] PRIMARY KEY CLUSTERED 
(
	[IdProgramacionSemana] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Query]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Query](
	[IDENTIFICACION] [char](20) NOT NULL,
	[DESCRIPCION] [char](60) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Temperaturas]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Temperaturas](
	[IdTemperatura] [int] IDENTITY(1,1) NOT NULL,
	[IdProduccion] [int] NOT NULL,
	[IdMaquina] [int] NOT NULL,
	[Fecha] [datetime2](7) NOT NULL,
	[Temperatura] [decimal](8, 4) NOT NULL,
 CONSTRAINT [PK_Temperaturas] PRIMARY KEY CLUSTERED 
(
	[IdTemperatura] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[TiemposMuerto]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TiemposMuerto](
	[IdTiempoMuerto] [int] IDENTITY(1,1) NOT NULL,
	[IdProduccion] [int] NOT NULL,
	[IdCausa] [int] NOT NULL,
	[Inicio] [datetime2](7) NOT NULL,
	[Fin] [datetime2](7) NOT NULL,
	[Descripcion] [varchar](80) NULL,
 CONSTRAINT [PK_TiemposMuerto] PRIMARY KEY CLUSTERED 
(
	[IdTiempoMuerto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Turnos]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Turnos](
	[IdTurno] [int] IDENTITY(1,1) NOT NULL,
	[Identificador] [char](1) NOT NULL,
	[Descripcion] [varchar](20) NOT NULL,
 CONSTRAINT [PK_Turnos] PRIMARY KEY CLUSTERED 
(
	[IdTurno] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Usuarios]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Usuarios](
	[IdUsuarios] [int] IDENTITY(1,1) NOT NULL,
	[IdTurno] [int] NOT NULL,
	[Usuario] [varchar](20) NOT NULL,
	[Contrasena] [varchar](20) NOT NULL,
	[Nombre] [varchar](80) NOT NULL,
 CONSTRAINT [PK_Usuarios] PRIMARY KEY CLUSTERED 
(
	[IdUsuarios] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Vaciados]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Vaciados](
	[IdProduccion] [int] IDENTITY(1,1) NOT NULL,
	[IdAleacion] [int] NOT NULL,
	[Colada] [int] NOT NULL,
	[Lance] [int] NOT NULL,
	[HornoConsecutivo] [int] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  View [dbo].[v_ExistenciasBronces]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[v_ExistenciasBronces]
AS
SELECT IdProducto, [48] AS PLB, [57] AS PMB, [61] AS PTB, [81] AS TRB, [41] AS PCC, [14] AS CTB
FROM
(SELECT IdProducto, IdAlmacen, Existencia 
FROM AlmacenesProducto) ps
PIVOT
(
SUM (Existencia)
FOR IdAlmacen IN
( [48] , [57], [61], [81] , [41], [14] )
) AS pvt



GO
/****** Object:  View [dbo].[v_Productos]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[v_Productos]
AS
SELECT        dbo.Productos.IdProducto, dbo.Productos.IdMarca, dbo.Productos.IdPresentacion, dbo.Productos.IdAleacion, dbo.Productos.IdProductoCasting, 
                         dbo.Productos.Identificacion, dbo.Productos.Descripcion, ProductosCast.Identificacion AS ProductoCasting, dbo.Marcas.Descripcion AS Marca, 
                         dbo.Presentaciones.Descripcion AS Presentacion, dbo.Aleaciones.Descripcion AS Aleacion, dbo.Productos.PiezasMolde, dbo.Productos.CiclosMolde, 
                         dbo.Productos.PesoCasting, dbo.Productos.PesoArania
FROM            dbo.Productos INNER JOIN
                         dbo.Marcas ON dbo.Productos.IdMarca = dbo.Marcas.IdMarca INNER JOIN
                         dbo.Presentaciones ON dbo.Productos.IdPresentacion = dbo.Presentaciones.IDPresentacion INNER JOIN
                         dbo.Aleaciones ON dbo.Productos.IdAleacion = dbo.Aleaciones.IdAleacion INNER JOIN
                         dbo.Productos AS ProductosCast ON dbo.Productos.IdProductoCasting = ProductosCast.IdProducto

GO
/****** Object:  View [dbo].[v_Programaciones]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[v_Programaciones]
AS
SELECT        dbo.Programaciones.IdProgramacion, dbo.Pedidos.Codigo AS OE_Codigo, dbo.Pedidos.Numero AS OE_Nuemero, dbo.Usuarios.Usuario, 
                         dbo.ProgramacionesEstatus.Descripcion AS Estatus, dbo.v_Productos.Identificacion AS Producto, dbo.v_Productos.Descripcion, dbo.v_Productos.ProductoCasting, 
                         dbo.v_Productos.Marca, dbo.v_Productos.Presentacion, dbo.v_Productos.Aleacion, dbo.v_ExistenciasBronces.PLB, dbo.v_ExistenciasBronces.PMB, 
                         dbo.v_ExistenciasBronces.PTB, dbo.v_ExistenciasBronces.TRB, dbo.v_ExistenciasBronces.PCC, dbo.v_ExistenciasBronces.CTB, ISNULL(Semana1.Anio, 0) 
                         AS Anio1, ISNULL(Semana1.Semana, 0) AS Semana1, ISNULL(Semana1.Prioridad, 0) AS Prioridad1, ISNULL(Semana1.Programadas, 0) AS Programadas1, 
                         ISNULL(Semana1.Hechas, 0) AS Hechas1, ISNULL(Semana2.Anio, 0) AS Anio2, ISNULL(Semana2.Semana, 0) AS Semana2, ISNULL(Semana2.Prioridad, 0) 
                         AS Prioridad2, ISNULL(Semana2.Programadas, 0) AS Programadas2, ISNULL(Semana2.Hechas, 0) AS Hechas2, ISNULL(Semana3.Anio, 0) AS Anio3, 
                         ISNULL(Semana3.Semana, 0) AS Semana3, ISNULL(Semana3.Prioridad, 0) AS Prioridad3, ISNULL(Semana3.Programadas, 0) AS Programadas3, 
                         ISNULL(Semana3.Hechas, 0) AS Hechas3
FROM            dbo.Programaciones INNER JOIN
                         dbo.Pedidos ON dbo.Programaciones.IdPedido = dbo.Pedidos.IdPedido INNER JOIN
                         dbo.Usuarios ON dbo.Programaciones.IdUsuario = dbo.Usuarios.IdUsuarios INNER JOIN
                         dbo.ProgramacionesEstatus ON dbo.Programaciones.IdProgramacionEstatus = dbo.ProgramacionesEstatus.IdProgramacionEstatus INNER JOIN
                         dbo.v_Productos ON dbo.Programaciones.IdProducto = dbo.v_Productos.IdProducto INNER JOIN
                         dbo.v_ExistenciasBronces ON dbo.Programaciones.IdProducto = dbo.v_ExistenciasBronces.IdProducto LEFT OUTER JOIN
                         dbo.ProgramacionesSemana AS Semana1 ON dbo.Programaciones.IdProgramacion = Semana1.IdProgramacion LEFT OUTER JOIN
                         dbo.ProgramacionesSemana AS Semana2 ON dbo.Programaciones.IdProgramacion = Semana2.IdProgramacion LEFT OUTER JOIN
                         dbo.ProgramacionesSemana AS Semana3 ON dbo.Programaciones.IdProgramacion = Semana3.IdProgramacion

GO
/****** Object:  UserDefinedFunction [dbo].[f_GetProgramaciones]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[f_GetProgramaciones](@Anio1 int, @Semana1 int, @Anio2 int, @Semana2 int, @Anio3 int, @Semana3 int)
RETURNS TABLE 
AS
RETURN 
(
	SELECT dbo.Programaciones.IdProgramacion, dbo.Pedidos.Codigo AS OE_Codigo, dbo.Pedidos.Numero AS OE_Nuemero, dbo.Usuarios.Usuario, 
	dbo.ProgramacionesEstatus.Descripcion AS Estatus, dbo.v_Productos.Identificacion AS Producto, dbo.v_Productos.Descripcion, dbo.v_Productos.ProductoCasting, 
	dbo.v_Productos.Marca, dbo.v_Productos.Presentacion, dbo.v_Productos.Aleacion, dbo.v_ExistenciasBronces.PLB, dbo.v_ExistenciasBronces.PMB, 
	dbo.v_ExistenciasBronces.PTB, dbo.v_ExistenciasBronces.TRB, dbo.v_ExistenciasBronces.PCC, dbo.v_ExistenciasBronces.CTB, 
	Semana1.IdProgramacionSemana AS IdProgramacionSemana1, ISNULL(Semana1.Prioridad, 0) AS Prioridad1, ISNULL(Semana1.Programadas, 0) AS Programadas1, ISNULL(Semana1.Hechas, 0) AS Hechas1, 
	Semana2.IdProgramacionSemana AS IdProgramacionSemana2, ISNULL(Semana2.Prioridad, 0) AS Prioridad2, ISNULL(Semana2.Programadas, 0) AS Programadas2, ISNULL(Semana2.Hechas, 0) AS Hechas2, 
	Semana3.IdProgramacionSemana AS IdProgramacionSemana3, ISNULL(Semana3.Prioridad, 0) AS Prioridad3, ISNULL(Semana3.Programadas, 0) AS Programadas3, ISNULL(Semana3.Hechas, 0) AS Hechas3
	FROM dbo.Programaciones INNER JOIN
	dbo.Pedidos ON dbo.Programaciones.IdPedido = dbo.Pedidos.IdPedido INNER JOIN
	dbo.Usuarios ON dbo.Programaciones.IdUsuario = dbo.Usuarios.IdUsuarios INNER JOIN
	dbo.ProgramacionesEstatus ON dbo.Programaciones.IdProgramacionEstatus = dbo.ProgramacionesEstatus.IdProgramacionEstatus INNER JOIN
	dbo.v_Productos ON dbo.Programaciones.IdProducto = dbo.v_Productos.IdProducto INNER JOIN
	dbo.v_ExistenciasBronces ON dbo.Programaciones.IdProducto = dbo.v_ExistenciasBronces.IdProducto 
	LEFT JOIN dbo.ProgramacionesSemana AS Semana1 ON dbo.Programaciones.IdProgramacion = Semana1.IdProgramacion AND Semana1.Anio = @Anio1 AND Semana1.Semana = @Semana1
	LEFT JOIN dbo.ProgramacionesSemana AS Semana2 ON dbo.Programaciones.IdProgramacion = Semana2.IdProgramacion AND Semana2.Anio = @Anio2 AND Semana2.Semana = @Semana2
	LEFT JOIN dbo.ProgramacionesSemana AS Semana3 ON dbo.Programaciones.IdProgramacion = Semana3.IdProgramacion AND Semana3.Anio = @Anio3 AND Semana3.Semana = @Semana3
)

GO
/****** Object:  View [dbo].[v_AlmacenesProducto]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[v_AlmacenesProducto]
AS
SELECT        dbo.AlmacenesProducto.IdAlmacenProducto, dbo.AlmacenesProducto.IdAlmacen, dbo.AlmacenesProducto.IdProducto, dbo.Productos.Identificacion AS Producto, 
                         dbo.Almacenes.Identificador AS Almacen, dbo.AlmacenesProducto.Existencia
FROM            dbo.AlmacenesProducto INNER JOIN
                         dbo.Almacenes ON dbo.AlmacenesProducto.IdAlmacen = dbo.Almacenes.IdAlmacen INNER JOIN
                         dbo.Productos ON dbo.AlmacenesProducto.IdProducto = dbo.Productos.IdProducto
WHERE        (dbo.AlmacenesProducto.Existencia > 0)

GO
/****** Object:  View [dbo].[v_Pedidos]    Script Date: 30/10/2014 11:43:44 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[v_Pedidos]
AS
SELECT        dbo.Pedidos.IdPedido, dbo.Pedidos.IdAlmacen, dbo.Pedidos.IdProducto, dbo.Pedidos.Codigo, dbo.Pedidos.Numero, dbo.Productos.Identificacion AS Producto, 
                         dbo.Almacenes.Identificador AS Almacen, dbo.Pedidos.Fecha, dbo.Pedidos.Cliente, dbo.Pedidos.OrdenCompra, dbo.Pedidos.Estatus, dbo.Pedidos.Cantidad, 
                         dbo.Pedidos.SaldoCantidad, dbo.Pedidos.FechaEmbarque, dbo.Pedidos.NivelRiesgo, dbo.Pedidos.TotalProgramado, dbo.Pedidos.Observaciones
FROM            dbo.Pedidos INNER JOIN
                         dbo.Almacenes ON dbo.Pedidos.IdAlmacen = dbo.Almacenes.IdAlmacen INNER JOIN
                         dbo.Productos ON dbo.Pedidos.IdProducto = dbo.Productos.IdProducto

GO
/****** Object:  Index [IDX1_AlmacenesProducto]    Script Date: 30/10/2014 11:43:44 a.m. ******/
CREATE UNIQUE NONCLUSTERED INDEX [IDX1_AlmacenesProducto] ON [dbo].[AlmacenesProducto]
(
	[IdAlmacen] ASC,
	[IdProducto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IDX1_Productos]    Script Date: 30/10/2014 11:43:44 a.m. ******/
CREATE UNIQUE NONCLUSTERED INDEX [IDX1_Productos] ON [dbo].[Productos]
(
	[Identificacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IDX1_ProgramacionesDia]    Script Date: 30/10/2014 11:43:44 a.m. ******/
CREATE UNIQUE NONCLUSTERED INDEX [IDX1_ProgramacionesDia] ON [dbo].[ProgramacionesDia]
(
	[IdProgramacionSemana] ASC,
	[Dia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IDX1_ProgramacionesSemana]    Script Date: 30/10/2014 11:43:44 a.m. ******/
CREATE UNIQUE NONCLUSTERED INDEX [IDX1_ProgramacionesSemana] ON [dbo].[ProgramacionesSemana]
(
	[IdProgramacion] ASC,
	[Anio] ASC,
	[Semana] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Almas] ADD  DEFAULT ((0)) FOR [Existencia]
GO
ALTER TABLE [dbo].[AlmasProduccionDefecto] ADD  CONSTRAINT [DF_AlmasProduccionDefecto_Rechazada]  DEFAULT ((0)) FOR [Rechazada]
GO
ALTER TABLE [dbo].[Camisas] ADD  DEFAULT ((0)) FOR [Cantidad]
GO
ALTER TABLE [dbo].[CamisasTipo] ADD  DEFAULT ((0)) FOR [CantidadPorPaquete]
GO
ALTER TABLE [dbo].[Filtros] ADD  DEFAULT ((0)) FOR [Cantidad]
GO
ALTER TABLE [dbo].[FiltrosTipo] ADD  CONSTRAINT [DF_FiltrosTipo_CantidadPorPaquete]  DEFAULT ((0)) FOR [CantidadPorPaquete]
GO
ALTER TABLE [dbo].[Maquinas] ADD  DEFAULT ((0)) FOR [Consecutivo]
GO
ALTER TABLE [dbo].[Pedidos] ADD  CONSTRAINT [DF__Pedidos__NivelRi__43A1090D]  DEFAULT ((0)) FOR [NivelRiesgo]
GO
ALTER TABLE [dbo].[Pedidos] ADD  CONSTRAINT [DF__Pedidos__TotalPr__44952D46]  DEFAULT ((0)) FOR [TotalProgramado]
GO
ALTER TABLE [dbo].[Procesos] ADD  CONSTRAINT [DF__Procesos__Secuen__57A801BA]  DEFAULT ((0)) FOR [Secuencia]
GO
ALTER TABLE [dbo].[Producciones] ADD  DEFAULT (getdate()) FOR [Fecha]
GO
ALTER TABLE [dbo].[ProduccionesDefecto] ADD  DEFAULT ((0)) FOR [Rechazadas]
GO
ALTER TABLE [dbo].[ProduccionesDetalle] ADD  DEFAULT ((0)) FOR [CiclosMolde]
GO
ALTER TABLE [dbo].[ProduccionesDetalle] ADD  DEFAULT ((0)) FOR [PiezasMolde]
GO
ALTER TABLE [dbo].[ProgramacionesAlmaDia] ADD  DEFAULT ((0)) FOR [Prioridad]
GO
ALTER TABLE [dbo].[ProgramacionesAlmaDia] ADD  DEFAULT ((0)) FOR [Hechas]
GO
ALTER TABLE [dbo].[ProgramacionesAlmaSemana] ADD  DEFAULT ((0)) FOR [Prioridad]
GO
ALTER TABLE [dbo].[ProgramacionesAlmaSemana] ADD  DEFAULT ((0)) FOR [Hechas]
GO
ALTER TABLE [dbo].[ProgramacionesDia] ADD  DEFAULT ((0)) FOR [Prioridad]
GO
ALTER TABLE [dbo].[ProgramacionesDia] ADD  DEFAULT ((0)) FOR [Hechas]
GO
ALTER TABLE [dbo].[ProgramacionesSemana] ADD  DEFAULT ((0)) FOR [Prioridad]
GO
ALTER TABLE [dbo].[ProgramacionesSemana] ADD  DEFAULT ((0)) FOR [Hechas]
GO
ALTER TABLE [dbo].[Temperaturas] ADD  DEFAULT ((0)) FOR [Temperatura]
GO
ALTER TABLE [dbo].[AlmacenesProducto]  WITH CHECK ADD  CONSTRAINT [fk_AlmacenesProducto_Almacenes_1] FOREIGN KEY([IdAlmacen])
REFERENCES [dbo].[Almacenes] ([IdAlmacen])
GO
ALTER TABLE [dbo].[AlmacenesProducto] CHECK CONSTRAINT [fk_AlmacenesProducto_Almacenes_1]
GO
ALTER TABLE [dbo].[AlmacenesProducto]  WITH CHECK ADD  CONSTRAINT [fk_AlmacenesProducto_Productos_1] FOREIGN KEY([IdProducto])
REFERENCES [dbo].[Productos] ([IdProducto])
GO
ALTER TABLE [dbo].[AlmacenesProducto] CHECK CONSTRAINT [fk_AlmacenesProducto_Productos_1]
GO
ALTER TABLE [dbo].[Almas]  WITH CHECK ADD  CONSTRAINT [fk_Almas_AlmasMaterialCaja_1] FOREIGN KEY([IdAlmaMaterialCaja])
REFERENCES [dbo].[AlmasMaterialCaja] ([IdAlmaMaterialCaja])
GO
ALTER TABLE [dbo].[Almas] CHECK CONSTRAINT [fk_Almas_AlmasMaterialCaja_1]
GO
ALTER TABLE [dbo].[Almas]  WITH CHECK ADD  CONSTRAINT [fk_Almas_AlmasRecetas_1] FOREIGN KEY([IdAlmaReceta])
REFERENCES [dbo].[AlmasRecetas] ([IdAlmaReceta])
GO
ALTER TABLE [dbo].[Almas] CHECK CONSTRAINT [fk_Almas_AlmasRecetas_1]
GO
ALTER TABLE [dbo].[Almas]  WITH CHECK ADD  CONSTRAINT [fk_Almas_AlmasTipo_1] FOREIGN KEY([IdAlmaTipo])
REFERENCES [dbo].[AlmasTipo] ([IdAlmaTipo])
GO
ALTER TABLE [dbo].[Almas] CHECK CONSTRAINT [fk_Almas_AlmasTipo_1]
GO
ALTER TABLE [dbo].[Almas]  WITH CHECK ADD  CONSTRAINT [fk_Almas_Productos_1] FOREIGN KEY([IdProducto])
REFERENCES [dbo].[Productos] ([IdProducto])
GO
ALTER TABLE [dbo].[Almas] CHECK CONSTRAINT [fk_Almas_Productos_1]
GO
ALTER TABLE [dbo].[AlmasProduccionDefecto]  WITH CHECK ADD  CONSTRAINT [fk_AlmasProduccionDefecto_AlmasProduccionDetalle_1] FOREIGN KEY([IdAlmaProduccionDetalle])
REFERENCES [dbo].[AlmasProduccionDetalle] ([IdAlmaProduccion])
GO
ALTER TABLE [dbo].[AlmasProduccionDefecto] CHECK CONSTRAINT [fk_AlmasProduccionDefecto_AlmasProduccionDetalle_1]
GO
ALTER TABLE [dbo].[AlmasProduccionDefecto]  WITH CHECK ADD  CONSTRAINT [fk_AlmasProduccionDefecto_Defectos_1] FOREIGN KEY([IdDefecto])
REFERENCES [dbo].[Defectos] ([IdDefecto])
GO
ALTER TABLE [dbo].[AlmasProduccionDefecto] CHECK CONSTRAINT [fk_AlmasProduccionDefecto_Defectos_1]
GO
ALTER TABLE [dbo].[AlmasProduccionDetalle]  WITH CHECK ADD  CONSTRAINT [fk_AlmasProduccionDetalle_Almas_1] FOREIGN KEY([IdAlma])
REFERENCES [dbo].[Almas] ([IdAlma])
GO
ALTER TABLE [dbo].[AlmasProduccionDetalle] CHECK CONSTRAINT [fk_AlmasProduccionDetalle_Almas_1]
GO
ALTER TABLE [dbo].[AlmasProduccionDetalle]  WITH CHECK ADD  CONSTRAINT [fk_AlmasProduccionDetalle_Producciones_1] FOREIGN KEY([IdProduccion])
REFERENCES [dbo].[Producciones] ([IdProduccion])
GO
ALTER TABLE [dbo].[AlmasProduccionDetalle] CHECK CONSTRAINT [fk_AlmasProduccionDetalle_Producciones_1]
GO
ALTER TABLE [dbo].[AlmasProduccionDetalle]  WITH CHECK ADD  CONSTRAINT [fk_AlmasProduccionDetalle_ProgramacionesAlma_1] FOREIGN KEY([IdProgramacionAlma])
REFERENCES [dbo].[ProgramacionesAlma] ([IdProgramacionAlma])
GO
ALTER TABLE [dbo].[AlmasProduccionDetalle] CHECK CONSTRAINT [fk_AlmasProduccionDetalle_ProgramacionesAlma_1]
GO
ALTER TABLE [dbo].[Camisas]  WITH CHECK ADD  CONSTRAINT [fk_Camisas_CamisasTipo_1] FOREIGN KEY([IdCamisaTipo])
REFERENCES [dbo].[CamisasTipo] ([IdCamisaTipo])
GO
ALTER TABLE [dbo].[Camisas] CHECK CONSTRAINT [fk_Camisas_CamisasTipo_1]
GO
ALTER TABLE [dbo].[Camisas]  WITH CHECK ADD  CONSTRAINT [fk_Camisas_Productos_1] FOREIGN KEY([IdProducto])
REFERENCES [dbo].[Productos] ([IdProducto])
GO
ALTER TABLE [dbo].[Camisas] CHECK CONSTRAINT [fk_Camisas_Productos_1]
GO
ALTER TABLE [dbo].[Causas]  WITH CHECK ADD  CONSTRAINT [fk_Causas_CausasTipo_1] FOREIGN KEY([IdCausaTipo])
REFERENCES [dbo].[CausasTipo] ([IdCausaTipo])
GO
ALTER TABLE [dbo].[Causas] CHECK CONSTRAINT [fk_Causas_CausasTipo_1]
GO
ALTER TABLE [dbo].[Causas]  WITH CHECK ADD  CONSTRAINT [fk_Causas_Procesos_1] FOREIGN KEY([IdProceso])
REFERENCES [dbo].[Procesos] ([IdProceso])
GO
ALTER TABLE [dbo].[Causas] CHECK CONSTRAINT [fk_Causas_Procesos_1]
GO
ALTER TABLE [dbo].[CentrosTrabajo]  WITH CHECK ADD  CONSTRAINT [fk_CentrosTrabajo_Procesos_1] FOREIGN KEY([IdProceso])
REFERENCES [dbo].[Procesos] ([IdProceso])
GO
ALTER TABLE [dbo].[CentrosTrabajo] CHECK CONSTRAINT [fk_CentrosTrabajo_Procesos_1]
GO
ALTER TABLE [dbo].[Defectos]  WITH CHECK ADD  CONSTRAINT [fk_Defectos_DefectosTipo_1] FOREIGN KEY([IdDefectoTipo])
REFERENCES [dbo].[DefectosTipo] ([IdDefectoTipo])
GO
ALTER TABLE [dbo].[Defectos] CHECK CONSTRAINT [fk_Defectos_DefectosTipo_1]
GO
ALTER TABLE [dbo].[Defectos]  WITH CHECK ADD  CONSTRAINT [fk_Defectos_Procesos_1] FOREIGN KEY([IdProceso])
REFERENCES [dbo].[Procesos] ([IdProceso])
GO
ALTER TABLE [dbo].[Defectos] CHECK CONSTRAINT [fk_Defectos_Procesos_1]
GO
ALTER TABLE [dbo].[Filtros]  WITH CHECK ADD  CONSTRAINT [fk_Filtros_FiltrosTipo_1] FOREIGN KEY([IdFiltroTipo])
REFERENCES [dbo].[FiltrosTipo] ([IdFiltroTipo])
GO
ALTER TABLE [dbo].[Filtros] CHECK CONSTRAINT [fk_Filtros_FiltrosTipo_1]
GO
ALTER TABLE [dbo].[Filtros]  WITH CHECK ADD  CONSTRAINT [fk_Filtros_Productos_1] FOREIGN KEY([IdProducto])
REFERENCES [dbo].[Productos] ([IdProducto])
GO
ALTER TABLE [dbo].[Filtros] CHECK CONSTRAINT [fk_Filtros_Productos_1]
GO
ALTER TABLE [dbo].[Maquinas]  WITH CHECK ADD  CONSTRAINT [fk_Maquinas_CentrosTrabajo_1] FOREIGN KEY([IdCentroTrabajo])
REFERENCES [dbo].[CentrosTrabajo] ([IdCentroTrabajo])
GO
ALTER TABLE [dbo].[Maquinas] CHECK CONSTRAINT [fk_Maquinas_CentrosTrabajo_1]
GO
ALTER TABLE [dbo].[MaterialesVaciado]  WITH CHECK ADD  CONSTRAINT [fk_MaterialesVaciado_Materiales_1] FOREIGN KEY([IdMaterial])
REFERENCES [dbo].[Materiales] ([IdMaterial])
GO
ALTER TABLE [dbo].[MaterialesVaciado] CHECK CONSTRAINT [fk_MaterialesVaciado_Materiales_1]
GO
ALTER TABLE [dbo].[MaterialesVaciado]  WITH CHECK ADD  CONSTRAINT [fk_MaterialesVaciado_Producciones_1] FOREIGN KEY([IdProduccion])
REFERENCES [dbo].[Producciones] ([IdProduccion])
GO
ALTER TABLE [dbo].[MaterialesVaciado] CHECK CONSTRAINT [fk_MaterialesVaciado_Producciones_1]
GO
ALTER TABLE [dbo].[Pedidos]  WITH CHECK ADD  CONSTRAINT [fk_Pedidos_Almacenes_1] FOREIGN KEY([IdAlmacen])
REFERENCES [dbo].[Almacenes] ([IdAlmacen])
GO
ALTER TABLE [dbo].[Pedidos] CHECK CONSTRAINT [fk_Pedidos_Almacenes_1]
GO
ALTER TABLE [dbo].[Pedidos]  WITH CHECK ADD  CONSTRAINT [fk_Pedidos_Productos_1] FOREIGN KEY([IdProducto])
REFERENCES [dbo].[Productos] ([IdProducto])
GO
ALTER TABLE [dbo].[Pedidos] CHECK CONSTRAINT [fk_Pedidos_Productos_1]
GO
ALTER TABLE [dbo].[Procesos]  WITH CHECK ADD  CONSTRAINT [fk_Procesos_Areas_1] FOREIGN KEY([IdArea])
REFERENCES [dbo].[Areas] ([IdArea])
GO
ALTER TABLE [dbo].[Procesos] CHECK CONSTRAINT [fk_Procesos_Areas_1]
GO
ALTER TABLE [dbo].[Producciones]  WITH CHECK ADD  CONSTRAINT [fk_Producciones_CentrosTrabajo_1] FOREIGN KEY([IdCentroTrabajo])
REFERENCES [dbo].[CentrosTrabajo] ([IdCentroTrabajo])
GO
ALTER TABLE [dbo].[Producciones] CHECK CONSTRAINT [fk_Producciones_CentrosTrabajo_1]
GO
ALTER TABLE [dbo].[Producciones]  WITH CHECK ADD  CONSTRAINT [fk_Producciones_Procesos_1] FOREIGN KEY([IdProceso])
REFERENCES [dbo].[Procesos] ([IdProceso])
GO
ALTER TABLE [dbo].[Producciones] CHECK CONSTRAINT [fk_Producciones_Procesos_1]
GO
ALTER TABLE [dbo].[Producciones]  WITH CHECK ADD  CONSTRAINT [fk_Producciones_ProduccionesEstatus_1] FOREIGN KEY([IdProduccionEstatus])
REFERENCES [dbo].[ProduccionesEstatus] ([IdProduccionEstatus])
GO
ALTER TABLE [dbo].[Producciones] CHECK CONSTRAINT [fk_Producciones_ProduccionesEstatus_1]
GO
ALTER TABLE [dbo].[Producciones]  WITH CHECK ADD  CONSTRAINT [fk_Seguimientos_Maquinas_1] FOREIGN KEY([IdMaquina])
REFERENCES [dbo].[Maquinas] ([IdMaquina])
GO
ALTER TABLE [dbo].[Producciones] CHECK CONSTRAINT [fk_Seguimientos_Maquinas_1]
GO
ALTER TABLE [dbo].[Producciones]  WITH CHECK ADD  CONSTRAINT [fk_Seguimientos_Usuarios_1] FOREIGN KEY([IdUsuario])
REFERENCES [dbo].[Usuarios] ([IdUsuarios])
GO
ALTER TABLE [dbo].[Producciones] CHECK CONSTRAINT [fk_Seguimientos_Usuarios_1]
GO
ALTER TABLE [dbo].[ProduccionesDefecto]  WITH CHECK ADD  CONSTRAINT [fk_ProduccionesDefecto_Defectos_1] FOREIGN KEY([IdDefecto])
REFERENCES [dbo].[Defectos] ([IdDefecto])
GO
ALTER TABLE [dbo].[ProduccionesDefecto] CHECK CONSTRAINT [fk_ProduccionesDefecto_Defectos_1]
GO
ALTER TABLE [dbo].[ProduccionesDefecto]  WITH CHECK ADD  CONSTRAINT [fk_ProduccionesDefecto_ProduccionesDetalle_1] FOREIGN KEY([IdProduccionDetalle])
REFERENCES [dbo].[ProduccionesDetalle] ([IdProduccionDetalle])
GO
ALTER TABLE [dbo].[ProduccionesDefecto] CHECK CONSTRAINT [fk_ProduccionesDefecto_ProduccionesDetalle_1]
GO
ALTER TABLE [dbo].[ProduccionesDetalle]  WITH CHECK ADD  CONSTRAINT [fk_ProduccionesDetalle_Producciones_1] FOREIGN KEY([IdProduccion])
REFERENCES [dbo].[Producciones] ([IdProduccion])
GO
ALTER TABLE [dbo].[ProduccionesDetalle] CHECK CONSTRAINT [fk_ProduccionesDetalle_Producciones_1]
GO
ALTER TABLE [dbo].[ProduccionesDetalle]  WITH CHECK ADD  CONSTRAINT [fk_SeguimientosDetalle_Productos_1] FOREIGN KEY([IdProductos])
REFERENCES [dbo].[Productos] ([IdProducto])
GO
ALTER TABLE [dbo].[ProduccionesDetalle] CHECK CONSTRAINT [fk_SeguimientosDetalle_Productos_1]
GO
ALTER TABLE [dbo].[ProduccionesDetalle]  WITH CHECK ADD  CONSTRAINT [fk_SeguimientosDetalle_Programaciones_1] FOREIGN KEY([IdProgramacion])
REFERENCES [dbo].[Programaciones] ([IdProgramacion])
GO
ALTER TABLE [dbo].[ProduccionesDetalle] CHECK CONSTRAINT [fk_SeguimientosDetalle_Programaciones_1]
GO
ALTER TABLE [dbo].[Productos]  WITH CHECK ADD  CONSTRAINT [fk_Productos_Aleaciones_1] FOREIGN KEY([IdAleacion])
REFERENCES [dbo].[Aleaciones] ([IdAleacion])
GO
ALTER TABLE [dbo].[Productos] CHECK CONSTRAINT [fk_Productos_Aleaciones_1]
GO
ALTER TABLE [dbo].[Productos]  WITH CHECK ADD  CONSTRAINT [fk_Productos_Marcas_1] FOREIGN KEY([IdMarca])
REFERENCES [dbo].[Marcas] ([IdMarca])
GO
ALTER TABLE [dbo].[Productos] CHECK CONSTRAINT [fk_Productos_Marcas_1]
GO
ALTER TABLE [dbo].[Productos]  WITH CHECK ADD  CONSTRAINT [fk_Productos_Presentacion_1] FOREIGN KEY([IdPresentacion])
REFERENCES [dbo].[Presentaciones] ([IDPresentacion])
GO
ALTER TABLE [dbo].[Productos] CHECK CONSTRAINT [fk_Productos_Presentacion_1]
GO
ALTER TABLE [dbo].[Productos]  WITH CHECK ADD  CONSTRAINT [fk_Productos_Productos_1] FOREIGN KEY([IdProductoCasting])
REFERENCES [dbo].[Productos] ([IdProducto])
GO
ALTER TABLE [dbo].[Productos] CHECK CONSTRAINT [fk_Productos_Productos_1]
GO
ALTER TABLE [dbo].[Programaciones]  WITH CHECK ADD  CONSTRAINT [fk_Programaciones_Pedidos_1] FOREIGN KEY([IdPedido])
REFERENCES [dbo].[Pedidos] ([IdPedido])
GO
ALTER TABLE [dbo].[Programaciones] CHECK CONSTRAINT [fk_Programaciones_Pedidos_1]
GO
ALTER TABLE [dbo].[Programaciones]  WITH CHECK ADD  CONSTRAINT [fk_Programaciones_Productos_1] FOREIGN KEY([IdProducto])
REFERENCES [dbo].[Productos] ([IdProducto])
GO
ALTER TABLE [dbo].[Programaciones] CHECK CONSTRAINT [fk_Programaciones_Productos_1]
GO
ALTER TABLE [dbo].[Programaciones]  WITH CHECK ADD  CONSTRAINT [fk_Programaciones_ProgramacionesEstatus_1] FOREIGN KEY([IdProgramacionEstatus])
REFERENCES [dbo].[ProgramacionesEstatus] ([IdProgramacionEstatus])
GO
ALTER TABLE [dbo].[Programaciones] CHECK CONSTRAINT [fk_Programaciones_ProgramacionesEstatus_1]
GO
ALTER TABLE [dbo].[Programaciones]  WITH CHECK ADD  CONSTRAINT [fk_Programaciones_Usuarios_1] FOREIGN KEY([IdUsuario])
REFERENCES [dbo].[Usuarios] ([IdUsuarios])
GO
ALTER TABLE [dbo].[Programaciones] CHECK CONSTRAINT [fk_Programaciones_Usuarios_1]
GO
ALTER TABLE [dbo].[ProgramacionesAlma]  WITH CHECK ADD  CONSTRAINT [fk_ProgramacionesAlma_Almas_1] FOREIGN KEY([IdAlmas])
REFERENCES [dbo].[Almas] ([IdAlma])
GO
ALTER TABLE [dbo].[ProgramacionesAlma] CHECK CONSTRAINT [fk_ProgramacionesAlma_Almas_1]
GO
ALTER TABLE [dbo].[ProgramacionesAlma]  WITH CHECK ADD  CONSTRAINT [fk_ProgramacionesAlma_Programaciones_1] FOREIGN KEY([IdProgramacion])
REFERENCES [dbo].[Programaciones] ([IdProgramacion])
GO
ALTER TABLE [dbo].[ProgramacionesAlma] CHECK CONSTRAINT [fk_ProgramacionesAlma_Programaciones_1]
GO
ALTER TABLE [dbo].[ProgramacionesAlma]  WITH CHECK ADD  CONSTRAINT [fk_ProgramacionesAlma_ProgramacionesEstatus_1] FOREIGN KEY([IdProgramacionEstatus])
REFERENCES [dbo].[ProgramacionesEstatus] ([IdProgramacionEstatus])
GO
ALTER TABLE [dbo].[ProgramacionesAlma] CHECK CONSTRAINT [fk_ProgramacionesAlma_ProgramacionesEstatus_1]
GO
ALTER TABLE [dbo].[ProgramacionesAlma]  WITH CHECK ADD  CONSTRAINT [fk_ProgramacionesAlma_Usuarios_1] FOREIGN KEY([IdUsuario])
REFERENCES [dbo].[Usuarios] ([IdUsuarios])
GO
ALTER TABLE [dbo].[ProgramacionesAlma] CHECK CONSTRAINT [fk_ProgramacionesAlma_Usuarios_1]
GO
ALTER TABLE [dbo].[ProgramacionesAlmaDia]  WITH CHECK ADD  CONSTRAINT [fk_ProgramacionesAlmaDia_ProgramacionesAlmaSemana_1] FOREIGN KEY([IdProgramacionAlmaSemana])
REFERENCES [dbo].[ProgramacionesAlmaSemana] ([IdProgramacionAlmaSemana])
GO
ALTER TABLE [dbo].[ProgramacionesAlmaDia] CHECK CONSTRAINT [fk_ProgramacionesAlmaDia_ProgramacionesAlmaSemana_1]
GO
ALTER TABLE [dbo].[ProgramacionesAlmaSemana]  WITH CHECK ADD  CONSTRAINT [fk_ProgramacionesAlmaSemana_ProgramacionesAlma_1] FOREIGN KEY([IdProgramacionAlma])
REFERENCES [dbo].[ProgramacionesAlma] ([IdProgramacionAlma])
GO
ALTER TABLE [dbo].[ProgramacionesAlmaSemana] CHECK CONSTRAINT [fk_ProgramacionesAlmaSemana_ProgramacionesAlma_1]
GO
ALTER TABLE [dbo].[ProgramacionesDia]  WITH CHECK ADD  CONSTRAINT [fk_ProgramacionesDia_ProgramacionesSemana_1] FOREIGN KEY([IdProgramacionSemana])
REFERENCES [dbo].[ProgramacionesSemana] ([IdProgramacionSemana])
GO
ALTER TABLE [dbo].[ProgramacionesDia] CHECK CONSTRAINT [fk_ProgramacionesDia_ProgramacionesSemana_1]
GO
ALTER TABLE [dbo].[ProgramacionesSemana]  WITH CHECK ADD  CONSTRAINT [fk_ProgramacionesSemana_Programaciones_1] FOREIGN KEY([IdProgramacion])
REFERENCES [dbo].[Programaciones] ([IdProgramacion])
GO
ALTER TABLE [dbo].[ProgramacionesSemana] CHECK CONSTRAINT [fk_ProgramacionesSemana_Programaciones_1]
GO
ALTER TABLE [dbo].[Temperaturas]  WITH CHECK ADD  CONSTRAINT [fk_Temperaturas_Maquinas_1] FOREIGN KEY([IdMaquina])
REFERENCES [dbo].[Maquinas] ([IdMaquina])
GO
ALTER TABLE [dbo].[Temperaturas] CHECK CONSTRAINT [fk_Temperaturas_Maquinas_1]
GO
ALTER TABLE [dbo].[Temperaturas]  WITH CHECK ADD  CONSTRAINT [fk_Temperaturas_Producciones_1] FOREIGN KEY([IdProduccion])
REFERENCES [dbo].[Producciones] ([IdProduccion])
GO
ALTER TABLE [dbo].[Temperaturas] CHECK CONSTRAINT [fk_Temperaturas_Producciones_1]
GO
ALTER TABLE [dbo].[TiemposMuerto]  WITH CHECK ADD  CONSTRAINT [fk_TiemposMuerto_Causas_1] FOREIGN KEY([IdCausa])
REFERENCES [dbo].[Causas] ([IdCausa])
GO
ALTER TABLE [dbo].[TiemposMuerto] CHECK CONSTRAINT [fk_TiemposMuerto_Causas_1]
GO
ALTER TABLE [dbo].[TiemposMuerto]  WITH CHECK ADD  CONSTRAINT [fk_TiemposMuerto_Producciones_1] FOREIGN KEY([IdProduccion])
REFERENCES [dbo].[Producciones] ([IdProduccion])
GO
ALTER TABLE [dbo].[TiemposMuerto] CHECK CONSTRAINT [fk_TiemposMuerto_Producciones_1]
GO
ALTER TABLE [dbo].[Usuarios]  WITH CHECK ADD  CONSTRAINT [fk_Usuarios_Turnos_1] FOREIGN KEY([IdTurno])
REFERENCES [dbo].[Turnos] ([IdTurno])
GO
ALTER TABLE [dbo].[Usuarios] CHECK CONSTRAINT [fk_Usuarios_Turnos_1]
GO
ALTER TABLE [dbo].[Vaciados]  WITH CHECK ADD  CONSTRAINT [fk_Vaciados_Aleaciones_1] FOREIGN KEY([IdAleacion])
REFERENCES [dbo].[Aleaciones] ([IdAleacion])
GO
ALTER TABLE [dbo].[Vaciados] CHECK CONSTRAINT [fk_Vaciados_Aleaciones_1]
GO
ALTER TABLE [dbo].[Vaciados]  WITH CHECK ADD  CONSTRAINT [fk_Vaciados_Producciones_1] FOREIGN KEY([IdProduccion])
REFERENCES [dbo].[Producciones] ([IdProduccion])
GO
ALTER TABLE [dbo].[Vaciados] CHECK CONSTRAINT [fk_Vaciados_Producciones_1]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Moldeo Permanente 
Bronce
 Acero' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Areas', @level2type=N'COLUMN',@level2name=N'Descripcion'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Collingnon 
Cooper 
Jabsco 
Rain Bird' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Marcas', @level2type=N'COLUMN',@level2name=N'Descripcion'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Almacen de la orden de entrega' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Pedidos', @level2type=N'COLUMN',@level2name=N'IdAlmacen'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Codigo de la orden de entrega' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Pedidos', @level2type=N'COLUMN',@level2name=N'Codigo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Numero de la partida de la orden de entrega' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Pedidos', @level2type=N'COLUMN',@level2name=N'Numero'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de la orden de entrega' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Pedidos', @level2type=N'COLUMN',@level2name=N'Fecha'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cliente de la orden de entrega' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Pedidos', @level2type=N'COLUMN',@level2name=N'Cliente'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Orden de compra del cliente (OE_DOCUMENTO1)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Pedidos', @level2type=N'COLUMN',@level2name=N'OrdenCompra'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estatus de la orden de entrega PO_STATUS' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Pedidos', @level2type=N'COLUMN',@level2name=N'Estatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'POE_DctoAdicionalFecha' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Pedidos', @level2type=N'COLUMN',@level2name=N'FechaEmbarque'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'POE_Observaciones' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Pedidos', @level2type=N'COLUMN',@level2name=N'Observaciones'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Acero 
Bronce' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Presentaciones', @level2type=N'COLUMN',@level2name=N'Descripcion'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Moldeado Vaciado' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Procesos', @level2type=N'COLUMN',@level2name=N'Descripcion'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'CampoUsuario1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Productos', @level2type=N'COLUMN',@level2name=N'PesoCasting'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'CampoUsuario2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Productos', @level2type=N'COLUMN',@level2name=N'PesoArania'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Dia Noche' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Turnos', @level2type=N'COLUMN',@level2name=N'Descripcion'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[37] 4[21] 2[14] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "AlmacenesProducto"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 188
               Right = 233
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Almacenes"
            Begin Extent = 
               Top = 6
               Left = 271
               Bottom = 207
               Right = 441
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Productos"
            Begin Extent = 
               Top = 161
               Left = 489
               Bottom = 311
               Right = 677
            End
            DisplayFlags = 280
            TopColumn = 5
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'v_AlmacenesProducto'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'v_AlmacenesProducto'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'v_ExistenciasBronces'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'v_ExistenciasBronces'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[32] 4[29] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Pedidos"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 309
               Right = 220
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "Almacenes"
            Begin Extent = 
               Top = 6
               Left = 258
               Bottom = 118
               Right = 428
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Productos"
            Begin Extent = 
               Top = 156
               Left = 418
               Bottom = 285
               Right = 606
            End
            DisplayFlags = 280
            TopColumn = 4
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'v_Pedidos'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'v_Pedidos'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[9] 2[24] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Productos"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 320
               Right = 226
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Marcas"
            Begin Extent = 
               Top = 6
               Left = 264
               Bottom = 118
               Right = 434
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Presentaciones"
            Begin Extent = 
               Top = 6
               Left = 472
               Bottom = 118
               Right = 642
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Aleaciones"
            Begin Extent = 
               Top = 6
               Left = 680
               Bottom = 118
               Right = 850
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ProductosCast"
            Begin Extent = 
               Top = 6
               Left = 888
               Bottom = 268
               Right = 1076
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 12
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
   ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'v_Productos'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'   Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'v_Productos'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'v_Productos'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[59] 4[6] 2[15] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Programaciones"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 265
               Right = 249
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Pedidos"
            Begin Extent = 
               Top = 6
               Left = 287
               Bottom = 273
               Right = 469
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Usuarios"
            Begin Extent = 
               Top = 6
               Left = 507
               Bottom = 135
               Right = 677
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ProgramacionesEstatus"
            Begin Extent = 
               Top = 6
               Left = 715
               Bottom = 118
               Right = 926
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "v_Productos"
            Begin Extent = 
               Top = 120
               Left = 715
               Bottom = 318
               Right = 903
            End
            DisplayFlags = 280
            TopColumn = 5
         End
         Begin Table = "v_ExistenciasBronces"
            Begin Extent = 
               Top = 292
               Left = 537
               Bottom = 531
               Right = 707
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Semana1"
            Begin Extent = 
               Top = 168
               Left = 257
               Bottom = 351
               Right = 473
            ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'v_Programaciones'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Semana2"
            Begin Extent = 
               Top = 270
               Left = 38
               Bottom = 399
               Right = 254
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Semana3"
            Begin Extent = 
               Top = 318
               Left = 745
               Bottom = 447
               Right = 961
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 33
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1500
         Alias = 900
         Table = 2070
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'v_Programaciones'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'v_Programaciones'
GO
USE [master]
GO
ALTER DATABASE [FIMEX_Produccion] SET  READ_WRITE 
GO
