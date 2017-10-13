/* Load Demographic Junk Dimension */
WITH GradeLevel (GradeLevel, GradeLevelSort ) AS
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
	SELECT 2010 /* WILL NEED TO UPDATE THIS TO CORRECT STARTING YEAR FOR DATAMASRT */
	UNION ALL
	SELECT ExpectedGraduationYear + 1
	FROM ExpectedGraduationSchoolYear
	WHERE ExpectedGraduationYear < 2030 /* WILL NEED TO UPDATE THIS VALUE OVER THE YEARS AS NEW YEARS ARE ADDED TO THE SCHOOLYEARTYPE TABLE */
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


INSERT INTO cmp.DemographicJunkDimension
(	GradeLevel, 
	GradeLevelSort, 
	Ethnicity,
	FreeReducedLunchStatus,
	SpecialEducationStatus,
	EnglishLanguageLearnerStatus,
	ExpectedGraduationYear
)

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
ORDER BY GradeLevel, 
		 GradeLevelSort, 
		 Ethnicity, 
		 FreeReducedLunchStatus, 
		 SpecialEducationStatus, 
		 EnglishLanguageLearnerStatus, 
		 ExpectedGraduationYear

OPTION (maxrecursion 0)
GO