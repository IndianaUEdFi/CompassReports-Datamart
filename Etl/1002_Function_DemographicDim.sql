CREATE FUNCTION DemographicDim()
RETURNS TABLE AS

RETURN
( 

WITH GradeLevel AS
(
SELECT 'Pre-Kindergarten' AS GradeLevel
UNION
SELECT 'Kindergarten' AS GradeLevel
UNION
SELECT 'Grade 1' AS GradeLevel
UNION
SELECT 'Grade 2' AS GradeLevel
UNION
SELECT 'Grade 3' AS GradeLevel
UNION
SELECT 'Grade 4' AS GradeLevel
UNION
SELECT 'Grade 5' AS GradeLevel
UNION
SELECT 'Grade 6' AS GradeLevel
UNION
SELECT 'Grade 7' AS GradeLevel
UNION
SELECT 'Grade 8' AS GradeLevel
UNION
SELECT 'Grade 9' AS GradeLevel
UNION
SELECT 'Grade 10' AS GradeLevel
UNION
SELECT 'Grade 11' AS GradeLevel
UNION
SELECT 'Grade 12' AS GradeLevel
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
	SELECT 2010 /* WILL NEED TO UPDATE THIS TO ACTUAL STARTING YEAR FOR DATAMART */
	UNION ALL
	SELECT ExpectedGraduationYear + 1
	FROM ExpectedGraduationSchoolYear
	WHERE ExpectedGraduationYear < 2030 /* WILL NEED TO UPDATE THIS WHEN YEARS ARE ADDED TO SCHOOLYEARTYPE TABLE IN ODS */
)

,GradeLevelExpectedGraduationYear AS
(
SELECT *
FROM GradeLevel GL
CROSS JOIN ExpectedGraduationSchoolYear
WHERE GL.GradeLevel IN ('Grade 9','Grade 10','Grade 11','Grade 12')


UNION
SELECT GradeLevel, NULL AS ExpectedGraduationYear
FROM GradeLevel GL
WHERE GL.GradeLevel NOT IN ('Grade 9','Grade 10','Grade 11','Grade 12')
)

SELECT	GradeLevel,
		Ethnicity,
		FreeReducedLunchStatus,
		SpecialEducationStatus,
		EnglishLanguageLearnerStatus,
		CAST(ExpectedGraduationYear AS SMALLINT) AS ExpectedGraduationYear,
		ROW_NUMBER()OVER (ORDER BY GradeLevel, Ethnicity, FreeReducedLunchStatus, SpecialEducationStatus, EnglishLanguageLearnerStatus, ExpectedGraduationYear) AS DemographicId
FROM GradeLevelExpectedGraduationYear
CROSS JOIN Ethnicity
CROSS JOIN FreeReducedLunchStatus
CROSS JOIN SpecialEducationStatus
CROSS JOIN EnglishLanguageLearnerStatus

)
GO