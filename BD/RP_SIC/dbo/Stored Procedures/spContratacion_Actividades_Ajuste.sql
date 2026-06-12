CREATE PROCEDURE [dbo].[spContratacion_Actividades_Ajuste] 		
	@pAño int,
	@pMes int,
	@pLoginUsuario nvarchar(100) = NULL
	AS
BEGIN

	SET NOCOUNT ON;

	-- ═══════════════════════════════════════════════════════════════
	-- BLOQUE RLS: Filtrado de #Sumarigrama por permisos de usuario
	-- ═══════════════════════════════════════════════════════════════
	CREATE TABLE #Sumarigrama (
		[Año]                     SMALLINT       NOT NULL,
		[CodDirGeneral]           VARCHAR (3)    NULL,
		[NombreDirGeneral]        NVARCHAR (100) NOT NULL,
		[CodSubDirGeneral]        VARCHAR (3)    NULL,
		[NombreSubDirGeneral]     NVARCHAR (100) NOT NULL,
		[CodDDirNegocio]          VARCHAR (3)    NULL,
		[NombreDirNegocio]        NVARCHAR (30)  NOT NULL,
		[CodSubDirNegocioArea]    VARCHAR (3)    NULL,
		[NombreSubDirNegocioArea] NVARCHAR (100) NOT NULL,
		[CodDelegacion]           VARCHAR (3)    NULL,
		[NombreDelegacion]        NVARCHAR (30)  NOT NULL,
		[CodCentro]               VARCHAR (3)    NULL,
		[NombreCentro]            NVARCHAR (30)  NOT NULL,
		[OrdenSubDirGeneral]      INT            NOT NULL
	);

	DECLARE @vPuesto nvarchar(10), @vCodEntidad nvarchar(20)

	SELECT @vPuesto = Puesto, @vCodEntidad = CodEntidad 
	FROM dbo.WEB_Usuarios WITH (NOLOCK) 
	WHERE Usuario = @pLoginUsuario

	IF @vPuesto = 'DG' OR @vPuesto IS NULL OR @pLoginUsuario IS NULL
	BEGIN
		INSERT INTO #Sumarigrama
		SELECT * FROM dbo.Sumarigrama WITH (NOLOCK) WHERE Año = @pAño
	END
	ELSE
	BEGIN
		INSERT INTO #Sumarigrama
		SELECT S.* 
		FROM dbo.Sumarigrama S WITH (NOLOCK)
		WHERE S.Año = @pAño
		  AND (
			  (@vPuesto = 'SDG'  AND S.CodSubDirGeneral = @vCodEntidad) OR
			  (@vPuesto = 'DN'   AND S.CodDDirNegocio = @vCodEntidad) OR
			  (@vPuesto = 'AREA' AND S.CodSubDirNegocioArea = @vCodEntidad) OR
			  (@vPuesto = 'DEL'  AND S.CodDelegacion = @vCodEntidad) OR
			  (@vPuesto = 'CT'   AND S.CodCentro = @vCodEntidad)
		  )
	END
	-- ═══════════════════════════════════════════════════════════════

	DECLARE @vContratacionActividades TABLE (NombreDirGeneral varchar(100),CodAct1 varchar(2),CodAct2 varchar(2),Pais varchar(50), ImporteContratadoAcumulado float, ImporteContratadoAcumuladoAñoanterior float)
	
	-- OFERTAS
			
	INSERT INTO @vContratacionActividades(NombreDirGeneral,CodAct1,CodAct2,Pais,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT NombreDirGeneral,CodAct1,CodAct2,Pais,sum(ImporteContratado),0
	FROM #Sumarigrama INNER JOIN
		 dbo.vwOfertas ON #Sumarigrama.CodCentro = dbo.vwOfertas.CodCentro
	WHERE  AñoAdjudicacion=@pAño AND MesAdjudicacion <= @pMes 
	GROUP BY NombreDirGeneral,CodAct1,CodAct2,Pais	
	
	-- REGULARIZACIONES
		
	INSERT INTO @vContratacionActividades(NombreDirGeneral,CodAct1,CodAct2,Pais,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT  NombreDirGeneral,CodAct1,CodAct2,Pais,sum(ImporteContratado),0
	FROM         (SELECT   CodCentro,CodAct1,CodAct2 ,Pais,ImporteContratado
				  FROM     dbo.vwRegularizaciones
				  WHERE    (AñoAdjudicacion = @pAño) AND (MesAdjudicacion <= @pMes) ) AS vwRegularizacionesQ INNER JOIN
							 #Sumarigrama ON vwRegularizacionesQ.CodCentro = #Sumarigrama.CodCentro
	GROUP BY NombreDirGeneral,CodAct1,CodAct2,Pais	
	
	
	-- OFERTASsql	dbo.fnSubActividadOfertasSQL(CodAct1, CodAct2, Reparto) 
		
	INSERT INTO @vContratacionActividades(NombreDirGeneral,CodAct1,CodAct2,Pais,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT     NombreDirGeneral,CodAct1,CodAct2,Pais,sum(ImporteContratado),0
	FROM         dbo.OfertasSQL INNER JOIN
                      dbo.Provincias ON dbo.OfertasSQL.CodProv = dbo.Provincias.CDPRO INNER JOIN
                      #Sumarigrama ON dbo.OfertasSQL.CodCentro = #Sumarigrama.CodCentro
	WHERE AñoAdjudicacion=@pAño AND month(FAdjudicacion) <= @pMes
	GROUP BY NombreDirGeneral,CodAct1,CodAct2,Pais

	---------------------- OfertasSQL_Ajustes ----------------------

	INSERT INTO @vContratacionActividades(NombreDirGeneral,CodAct1,CodAct2,Pais,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT     '',CodAct1,CodAct2,Pais,sum(Importe),0
	FROM         dbo.OfertasSQL_Ajustes INNER JOIN
                     dbo.Provincias ON dbo.OfertasSQL_Ajustes.CodProv = dbo.Provincias.CDPRO 
	WHERE AñoAdjudicacion=@pAño AND month(FAdjudicacion) <= @pMes
	GROUP BY CodAct1,CodAct2,Pais
	
	
	SELECT NombreDirGeneral,Pais,CodAct1 as CodActividad,Agrupacion as Actividad,Orden,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoAnterior, 0 as ImporteContratadoAcumuladoLastYear, @pAño AS Año, @pLoginUsuario AS LoginUsuario
	FROM 
		(SELECT NombreDirGeneral,CodAct1,CodAct2,Pais,Sum(ImporteContratadoAcumulado) as ImporteContratadoAcumulado, sum(ImporteContratadoAcumuladoAñoAnterior) as ImporteContratadoAcumuladoAñoAnterior 
		 FROM @vContratacionActividades	
		 GROUP BY NombreDirGeneral,CodAct1,CodAct2,Pais) OfertasSQL
			INNER JOIN
			dbo.ActividadesSQL ON OfertasSQL.CodAct1 = dbo.ActividadesSQL.CDAC1 AND OfertasSQL.CodAct2 = dbo.ActividadesSQL.CDAC2
			
	UNION
	
	SELECT  '',Mercado,'00',Agrupacion,dbo.fnOrdenActividadAgrupacion(Agrupacion),0,sum(Importe), 0 as ImporteContratadoAcumuladoLastYear, @pAño AS Año, @pLoginUsuario AS LoginUsuario
	FROM Historico_Mercado_ActividadSQL
	WHERE Año=@pAño-1 
	GROUP BY Agrupacion,Mercado	

	UNION -- Modificacion 9/6/2014

	SELECT '',Mercado,'LY',Agrupacion,Orden,0,0, sum(Importe) as ImporteContratadoAcumuladoLastYear, @pAño AS Año, @pLoginUsuario AS LoginUsuario
	FROM            dbo.ActividadesSQL INNER JOIN
                         dbo.HistoricoContratacionGrupoSQL ON dbo.ActividadesSQL.CDAC1 = dbo.HistoricoContratacionGrupoSQL.CodAct1 AND 
                         dbo.ActividadesSQL.CDAC2 = dbo.HistoricoContratacionGrupoSQL.CodAct2
	WHERE Año=@pAño-1 AND Mes<= @pMes
	GROUP BY Agrupacion,Mercado,Orden
		
	DROP TABLE #Sumarigrama;
END