CREATE TABLE [cmp].[EnrollmentFact] (
    [DemographicKey]         INT      NOT NULL,
    [SchoolKey]              INT      NOT NULL,
    [SchoolYearKey]          SMALLINT NOT NULL,
    [EnrollmentStudentCount] INT      NOT NULL,
    CONSTRAINT [PK_EnrollmentFact] PRIMARY KEY CLUSTERED ([DemographicKey] ASC, [SchoolKey] ASC, [SchoolYearKey] ASC),
    CONSTRAINT [FK_EnrollmentFact_DemographicJunkDimension] FOREIGN KEY ([DemographicKey]) REFERENCES [cmp].[DemographicJunkDimension] ([DemographicKey]),
    CONSTRAINT [FK_EnrollmentFact_SchoolDimension] FOREIGN KEY ([SchoolKey]) REFERENCES [cmp].[SchoolDimension] ([SchoolKey]),
    CONSTRAINT [FK_EnrollmentFact_SchoolYearDimension] FOREIGN KEY ([SchoolYearKey]) REFERENCES [cmp].[SchoolYearDimension] ([SchoolYearKey])
);

