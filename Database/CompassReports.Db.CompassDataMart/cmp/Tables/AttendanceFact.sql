CREATE TABLE [cmp].[AttendanceFact] (
    [DemographicKey]         INT      NOT NULL,
    [SchoolKey]              INT      NOT NULL,
    [SchoolYearKey]          SMALLINT NOT NULL,
    [TotalAbsences]          INT      NOT NULL,
    [TotalInstructionalDays] INT      NOT NULL,
    CONSTRAINT [PK_AttendanceFact] PRIMARY KEY CLUSTERED ([DemographicKey] ASC, [SchoolKey] ASC, [SchoolYearKey] ASC),
    CONSTRAINT [FK_AttendanceFact_DemographicJunkDimension] FOREIGN KEY ([DemographicKey]) REFERENCES [cmp].[DemographicJunkDimension] ([DemographicKey]),
    CONSTRAINT [FK_AttendanceFact_SchoolDimension] FOREIGN KEY ([SchoolKey]) REFERENCES [cmp].[SchoolDimension] ([SchoolKey]),
    CONSTRAINT [FK_AttendanceFact_SchoolYearDimension] FOREIGN KEY ([SchoolYearKey]) REFERENCES [cmp].[SchoolYearDimension] ([SchoolYearKey])
);

