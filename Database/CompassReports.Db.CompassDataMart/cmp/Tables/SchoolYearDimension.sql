CREATE TABLE [cmp].[SchoolYearDimension] (
    [SchoolYearKey]         SMALLINT      NOT NULL,
    [SchoolYearDescription] NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_SchoolYearDimension] PRIMARY KEY CLUSTERED ([SchoolYearKey] ASC)
);

