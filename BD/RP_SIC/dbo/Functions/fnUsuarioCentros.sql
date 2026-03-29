CREATE FUNCTION fnUsuarioCentros (@usuario varchar(50))  
RETURNS @Centros TABLE   
(  
    CodCentro nvarchar(3) primary key NOT NULL
)  
AS  
BEGIN  

	DECLARE @Puesto varchar(5)
	DECLARE @CodEntidad int

	SELECT @Puesto=Puesto, @CodEntidad=CodEntidad FROM WEB_Usuarios WHERE Usuario=@usuario

	IF (@Puesto='DG')
		BEGIN
			INSERT INTO @Centros 
			SELECT CodCentro FROM Centro	
		END
	ELSE IF (@Puesto='DN')
		BEGIN
			INSERT INTO @Centros 
			SELECT CodCentro FROM Centro
			WHERE CodigoDirNegocio = @CodEntidad			
		END
	ELSE IF (@Puesto='DEL')
		BEGIN
			INSERT INTO @Centros 
			SELECT CodCentro FROM Centro
			WHERE CodDelegacion = @CodEntidad			
		END
	ELSE IF (@Puesto='CT')
		BEGIN
			INSERT INTO @Centros 
			SELECT CodCentro FROM Centro
			WHERE CodCentro = @CodEntidad			
		END
    
   RETURN  

END;  
