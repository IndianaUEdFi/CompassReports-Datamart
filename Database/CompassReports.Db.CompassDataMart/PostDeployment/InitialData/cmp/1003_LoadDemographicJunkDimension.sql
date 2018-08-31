/* Load Demographic Junk Dimension */

;WITH GradeLevel (GradeLevel, GradeLevelSort ) AS
(
SELECT 'Pre-Kindergarten' AS GradeLevel, 'G00' AS GradeLevelSort
UNION
SELECT 'Kindergarten' AS GradeLevel, 'G01' AS GradeLevelSort
UNION
SELECT 'Grade 1' AS GradeLevel, 'G02' AS GradeLevelSort
UNION
SELECT 'Grade 2' AS GradeLevel, 'G03' AS GradeLevelSort
UNION
SELECT 'Grade 3' AS GradeLevel, 'G04' AS GradeLevelSort
UNION
SELECT 'Grade 4' AS GradeLevel, 'G05' AS GradeLevelSort
UNION
SELECT 'Grade 5' AS GradeLevel, 'G06' AS GradeLevelSort
UNION
SELECT 'Grade 6' AS GradeLevel, 'G07' AS GradeLevelSort
UNION
SELECT 'Grade 7' AS GradeLevel, 'G08' AS GradeLevelSort
UNION
SELECT 'Grade 8' AS GradeLevel, 'G09' AS GradeLevelSort
UNION
SELECT 'Grade 9' AS GradeLevel, 'G10' AS GradeLevelSort
UNION
SELECT 'Grade 10' AS GradeLevel, 'G11' AS GradeLevelSort
UNION
SELECT 'Grade 11' AS GradeLevel, 'G12' AS GradeLevelSort
UNION
SELECT 'Grade 12' AS GradeLevel, 'G13' AS GradeLevelSort
)

,Ethnicity AS
(
SELECT 'American Indian' AS Ethnicity
UNION
SELECT 'Asian' AS Ethnicity
UNION
SELECT 'Black' AS Ethnicity
UNION
SELECT 'Hispanic' AS Ethnicity
UNION
SELECT 'Multiracial' AS Ethnicity
UNION
SELECT 'Native Hawaiian or Other Pacific Islander' AS Ethnicity
UNION
SELECT 'White' AS Ethnicity
)

,FreeReducedLunchStatus AS
(
SELECT 'Free Meals' AS FreeReducedLunchStatus
UNION
SELECT 'Reduced price meals' AS FreeReducedLunchStatus
UNION
SELECT 'Paid meals' AS FreeReducedLunchStatus
)

,SpecialEducationStatus AS
(
SELECT 'Special Education' AS SpecialEducationStatus
UNION
SELECT 'General Education' AS SpecialEducationStatus
)

,EnglishLanguageLearnerStatus AS
(
SELECT 'English Language Learner' AS EnglishLanguageLearnerStatus
UNION
SELECT 'Non-English Language Learner' AS EnglishLanguageLearnerStatus
)

,ExpectedGraduationSchoolYear (ExpectedGraduationYear) AS 
(
	SELECT @StartYear
	UNION ALL
	SELECT CAST(ExpectedGraduationYear + 1 AS smallint)
	FROM ExpectedGraduationSchoolYear
	WHERE ExpectedGraduationYear < @EndYear
)

,GradeLevelExpectedGraduationYear AS
(
SELECT GradeLevel, GradeLevelSort, ExpectedGraduationYear
FROM GradeLevel GL
CROSS JOIN ExpectedGraduationSchoolYear
WHERE GL.GradeLevel IN ('Grade 9','Grade 10','Grade 11','Grade 12')


UNION
SELECT GradeLevel, GradeLevelSort, NULL AS ExpectedGraduationYear
FROM GradeLevel GL
WHERE GL.GradeLevel NOT IN ('Grade 9','Grade 10','Grade 11','Grade 12')
)


MERGE INTO cmp.DemographicJunkDimension AS Target
USING  (
	SELECT	GradeLevel,
			GradeLevelSort,
			Ethnicity,
			FreeReducedLunchStatus,
			SpecialEducationStatus,
			EnglishLanguageLearnerStatus,
			ExpectedGraduationYear
	FROM GradeLevelExpectedGraduationYear
	CROSS JOIN Ethnicity
	CROSS JOIN FreeReducedLunchStatus
	CROSS JOIN SpecialEducationStatus
	CROSS JOIN EnglishLanguageLearnerStatus
	GROUP BY [GradeLevel], [GradeLevelSort], [Ethnicity], [FreeReducedLunchStatus], [SpecialEducationStatus], [EnglishLanguageLearnerStatus], [ExpectedGraduationYear]
) AS Source ON Target.[GradeLevel]=Source.[GradeLevel] AND
	Target.[GradeLevelSort]=Source.[GradeLevelSort] AND 
	Target.[Ethnicity]=Source.[Ethnicity] AND
	Target.[FreeReducedLunchStatus]=Source.[FreeReducedLunchStatus] AND
	Target.[SpecialEducationStatus]=Source.[SpecialEducationStatus] AND
	Target.[EnglishLanguageLearnerStatus]=Source.[EnglishLanguageLearnerStatus] AND
	ISNULL(Target.[ExpectedGraduationYear],0)=ISNULL(Source.[ExpectedGraduationYear],0)
WHEN NOT MATCHED BY TARGET THEN
	INSERT 	([GradeLevel], [GradeLevelSort], [Ethnicity], [FreeReducedLunchStatus], [SpecialEducationStatus], [EnglishLanguageLearnerStatus], [ExpectedGraduationYear])
	VALUES 	(Source.[GradeLevel], Source.[GradeLevelSort], Source.[Ethnicity], Source.[FreeReducedLunchStatus], Source.[SpecialEducationStatus], Source.[EnglishLanguageLearnerStatus], Source.[ExpectedGraduationYear]) 
WHEN NOT MATCHED BY SOURCE THEN
	DELETE
OPTION (maxrecursion 0);
