CREATE TABLE [cmp].[AssessmentDimension] (
    [AssessmentKey]      INT           IDENTITY (1, 1) NOT NULL,
    [AssessmentTitle]    NVARCHAR (60) NOT NULL,
    [AssessedGradeLevel] NVARCHAR (50) NOT NULL,
    [AcademicSubject]    NVARCHAR (50) NOT NULL,
    [MaxScore]           INT           NULL,
    CONSTRAINT [PK_AssessmentDimension] PRIMARY KEY CLUSTERED ([AssessmentKey] ASC)
);

