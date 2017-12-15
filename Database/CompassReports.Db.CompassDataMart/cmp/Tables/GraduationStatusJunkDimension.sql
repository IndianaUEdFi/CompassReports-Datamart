CREATE TABLE [cmp].[GraduationStatusJunkDimension] (
    [GraduationStatusKey] INT           IDENTITY (1, 1) NOT NULL,
    [GraduationStatus]    NVARCHAR (50) NOT NULL,
    [DiplomaType]         NVARCHAR (15) NOT NULL,
    [GraduationWaiver]    NVARCHAR (15) NULL,
    CONSTRAINT [PK_GraduationStatusJunkDimension] PRIMARY KEY CLUSTERED ([GraduationStatusKey] ASC)
);

