CREATE TABLE [cmp].[GraduationFact] (
    [DemographicKey]         INT      NOT NULL,
    [SchoolKey]              INT      NOT NULL,
    [SchoolYearKey]          SMALLINT NOT NULL,
    [GraduationStatusKey]    INT      NOT NULL,
    [GraduationStudentCount] INT      NOT NULL,
    CONSTRAINT [PK_GraduationFact] PRIMARY KEY CLUSTERED ([DemographicKey] ASC, [SchoolKey] ASC, [SchoolYearKey] ASC, [GraduationStatusKey] ASC),
    CONSTRAINT [FK_GraduationFact_DemographicJunkDimension] FOREIGN KEY ([DemographicKey]) REFERENCES [cmp].[DemographicJunkDimension] ([DemographicKey]),
    CONSTRAINT [FK_GraduationFact_GraduationStatusJunkDimension] FOREIGN KEY ([GraduationStatusKey]) REFERENCES [cmp].[GraduationStatusJunkDimension] ([GraduationStatusKey]),
    CONSTRAINT [FK_GraduationFact_SchoolDimension] FOREIGN KEY ([SchoolKey]) REFERENCES [cmp].[SchoolDimension] ([SchoolKey]),
    CONSTRAINT [FK_GraduationFact_SchoolYearDimension] FOREIGN KEY ([SchoolYearKey]) REFERENCES [cmp].[SchoolYearDimension] ([SchoolYearKey])
);

