CREATE TABLE [cmp].[GoodCauseExemptionJunkDimension] (
    [GoodCauseExemptionKey] INT           IDENTITY (1, 1) NOT NULL,
    [GoodCauseExemption]    NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_GoodCauseExemptionJunkDimension] PRIMARY KEY CLUSTERED ([GoodCauseExemptionKey] ASC)
);

