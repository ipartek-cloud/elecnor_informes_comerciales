CREATE TABLE [dbo].[SubActividadesSQL_OLD] (
    [CDAC1]                            NVARCHAR (2)  NOT NULL,
    [CDAC2]                            NVARCHAR (2)  NOT NULL,
    [Descrip_Subactiv]                 NVARCHAR (40) NULL,
    [Descrip_Activ_Espec]              NVARCHAR (50) NULL,
    [Descrip_Activ_Espec_Desglose]     NVARCHAR (50) NULL,
    [Ord_Descrip_Activ_Espec_Desglose] INT           NULL,
    CONSTRAINT [PK_SubActividadesSQL_OLD] PRIMARY KEY CLUSTERED ([CDAC1] ASC, [CDAC2] ASC)
);

