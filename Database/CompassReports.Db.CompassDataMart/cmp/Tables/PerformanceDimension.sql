CREATE TABLE [cmp].[PerformanceDimension] (
    [PerformanceKey]   INT           IDENTITY (1, 1) NOT NULL,
    [PerformanceLevel] NVARCHAR (50) NOT NULL,
    [ScoreResult]      INT           NULL,
    CONSTRAINT [PK_PerformanceDimension] PRIMARY KEY CLUSTERED ([PerformanceKey] ASC)
);

