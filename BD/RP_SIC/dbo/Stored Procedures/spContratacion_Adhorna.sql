CREATE PROCEDURE [dbo].[spContratacion_Adhorna] 
	@pAño int,
	@pMes int
	AS
BEGIN

	DECLARE @vContratacion TABLE (Mercado varchar(100), Nombre varchar(100),ImporteContratado float,ImporteContratadoAcumulado float, ImporteContratadoAcumuladoAñoAnterior float,ImporteContratadoAcumuladoInternacional float)
	
	-- NACIONAL
	INSERT INTO @vContratacion(Mercado,Nombre,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoAnterior,ImporteContratadoAcumuladoInternacional)	
	SELECT  Mercado,Nombre,
			sum(dbo.fnImporteContratacion_Mensual_Adhorna(Año,Mes,@pAño,@pMes,ContratacionMensual)) as ImporteContratado,
			sum(dbo.fnImporteContratacion_Acumulado_Adhorna(Año,Mes,@pAño,@pMes,ContratacionMensual)) as ImporteContratadoAcumulado,
			sum(dbo.fnImporteContratacion_Acumulado_Adhorna(Año,Mes,@pAño-1,@pMes,ContratacionMensual)) as ImporteContratadoAcumuladoAñoAnterior,
			0
	FROM dbo.ContratacionAdhorna 
	WHERE  (Año=@pAño OR año=@pAño-1) AND mes <= @pMes 
	GROUP BY Mercado,Nombre		
	
	-- INTERNACIONAL
	INSERT INTO @vContratacion(Mercado,Nombre,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoAnterior,ImporteContratadoAcumuladoInternacional)	
	SELECT  Mercado,Nombre,0,0,0,sum(dbo.fnImporteContratacion_Acumulado_Adhorna(Año,Mes,@pAño,@pMes,ContratacionMensual)) 
	FROM dbo.ContratacionAdhorna 
	WHERE  (Año=@pAño) AND mes <= @pMes AND Mercado='Internacional'
	GROUP BY Mercado,Nombre	
	
	SELECT Nombre,sum(ImporteContratado) as ImporteContratado ,sum(ImporteContratadoAcumulado) as ImporteContratadoAcumulado ,Sum(ImporteContratadoAcumuladoAñoAnterior) as ImporteContratadoAcumuladoAñoAnterior,sum(ImporteContratadoAcumuladoInternacional) as ImporteContratadoAcumuladoInternacional
	FROM @vContratacion
	group by Nombre
	
END