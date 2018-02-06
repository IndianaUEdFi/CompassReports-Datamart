CREATE TABLE [cmp].[DemographicJunkDimension] (
    [DemographicKey]               INT           IDENTITY (1, 1) NOT NULL,
    [GradeLevel]                   NVARCHAR (50) NOT NULL,
    [GradeLevelSort]               NVARCHAR (10) NOT NULL,
    [Ethnicity]                    NVARCHAR (50) NOT NULL,
    [FreeReducedLunchStatus]       NVARCHAR (50) NOT NULL,
    [SpecialEducationStatus]       NVARCHAR (50) NOT NULL,
    [EnglishLanguageLearnerStatus] NVARCHAR (50) NOT NULL,
    [ExpectedGraduationYear]       SMALLINT      NULL,
    CONSTRAINT [PK_DemographicJunkDimension] PRIMARY KEY CLUSTERED ([DemographicKey] ASC)
);

