CREATE PROCEDURE spFActividadUsuario
	@pUsuario_Sin_Fecha varchar(50)
	as
BEGIN
	UPDATE WEB_Usuarios SET FActividad=getdate() WHERE Usuario=@pUsuario_Sin_Fecha
END
