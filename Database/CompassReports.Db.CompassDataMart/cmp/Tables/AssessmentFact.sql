CREATE TABLE [cmp].[AssessmentFact] (
    [DemographicKey]         INT      NOT NULL,
    [SchoolKey]              INT      NOT NULL,
    [SchoolYearKey]          SMALLINT NOT NULL,
    [AssessmentKey]          INT      NOT NULL,
    [PerformanceKey]         INT      NOT NULL,
    [GoodCauseExemptionKey]  INT      NOT NULL,
    [AssessmentStudentCount] INT      NOT NULL,
    CONSTRAINT [PK_AssessmentFact] PRIMARY KEY CLUSTERED ([DemographicKey] ASC, [SchoolKey] ASC, [SchoolYearKey] ASC, [AssessmentKey] ASC, [PerformanceKey] ASC, [GoodCauseExemptionKey] ASC),
    CONSTRAINT [FK_AssessmentFact_AssessmentDimension] FOREIGN KEY ([AssessmentKey]) REFERENCES [cmp].[AssessmentDimension] ([AssessmentKey]),
    CONSTRAINT [FK_AssessmentFact_DemographicJunkDimension] FOREIGN KEY ([DemographicKey]) REFERENCES [cmp].[DemographicJunkDimension] ([DemographicKey]),
    CONSTRAINT [FK_AssessmentFact_GoodCauseExemptionJunkDimension] FOREIGN KEY ([GoodCauseExemptionKey]) REFERENCES [cmp].[GoodCauseExemptionJunkDimension] ([GoodCauseExemptionKey]),
    CONSTRAINT [FK_AssessmentFact_PerformanceDimension] FOREIGN KEY ([PerformanceKey]) REFERENCES [cmp].[PerformanceDimension] ([PerformanceKey]),
    CONSTRAINT [FK_AssessmentFact_SchoolDimension] FOREIGN KEY ([SchoolKey]) REFERENCES [cmp].[SchoolDimension] ([SchoolKey]),
    CONSTRAINT [FK_AssessmentFact_SchoolYearDimension] FOREIGN KEY ([SchoolYearKey]) REFERENCES [cmp].[SchoolYearDimension] ([SchoolYearKey])
);

