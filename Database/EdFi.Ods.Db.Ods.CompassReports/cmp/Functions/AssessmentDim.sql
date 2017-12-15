CREATE FUNCTION cmp.AssessmentDim()
RETURNS TABLE AS

RETURN
( 

WITH GRADELEVELS (AssessedGradeLevel) AS
(
SELECT 'Grade K'
UNION
SELECT 'Grade 1'
UNION
SELECT 'Grade 2'
UNION
SELECT 'Grade 3'
UNION
SELECT 'Grade 4'
UNION
SELECT 'Grade 5'
UNION
SELECT 'Grade 6'
UNION 
SELECT 'Grade 7'
UNION
SELECT 'Grade 8'
UNION
SELECT 'Grade 9'
UNION
SELECT 'Grade 10'
UNION
SELECT 'Grade 11'
UNION
SELECT 'Grade 12'
)

, ASSESSMENTS (AssessmentTitle) AS
(
SELECT 'IREAD-3'
UNION
SELECT 'ISTEP+'
UNION
SELECT 'ECA'
UNION
SELECT 'ISTAR'
UNION
SELECT 'SAT'
UNION
SELECT 'ACT'
UNION
SELECT 'AP'
UNION
SELECT 'WIDA'
)

, SUBJECTAREA (AcademicSubject) AS
(
SELECT 'English/Language Arts Only' 
UNION
SELECT 'Math Only'
UNION
SELECT 'Science Only'
UNION
SELECT 'Social Studies Only'
UNION
SELECT 'Both English/Language Arts and Math'
UNION
SELECT 'English 10 Only'
UNION
SELECT 'Algebra I Only'
UNION
SELECT 'Both English 10 and Algebra I'
UNION
SELECT 'Math'
UNION
SELECT 'Reading'
UNION
SELECT 'Writing'
UNION
SELECT 'Composite Score'
UNION
SELECT 'English (ACT Only)'
UNION
SELECT 'Science (ACT Only)'
UNION
SELECT 'English'
UNION
SELECT 'Not Applicable'
)

, SCORES (AssessmentTitle, MaxScore) AS
(
SELECT 'SAT' AS AssessmentTitle, 1600 AS MaxScore
UNION
SELECT 'ACT' AS AssessmentTitle, 36 AS MaxScore
)

,ALLASSESSMENTS AS 
(
SELECT ASSESSMENTS.AssessmentTitle, AssessedGradeLevel, AcademicSubject, MaxScore
FROM ASSESSMENTS 
LEFT JOIN SCORES
	ON ASSESSMENTS.AssessmentTitle = SCORES.AssessmentTitle
CROSS JOIN GRADELEVELS
CROSS JOIN SUBJECTAREA
)

SELECT	AssessmentTitle, 
		AssessedGradeLevel, 
		AcademicSubject,
		MaxScore,
		ROW_NUMBER() OVER (ORDER BY AssessmentTitle, AcademicSubject, AssessedGradeLevel) AS AssessmentKey
FROM
(
SELECT * 
FROM ALLASSESSMENTS
WHERE AssessmentTitle = 'IREAD-3'
AND AcademicSubject = 'Reading'
AND AssessedGradeLevel = 'Grade 3'

UNION

SELECT * 
FROM ALLASSESSMENTS
WHERE AssessmentTitle = 'AP'
AND AcademicSubject = 'Not Applicable'
AND AssessedGradeLevel IN ('Grade 10', 'Grade 11', 'Grade 12')

UNION

SELECT * 
FROM ALLASSESSMENTS
WHERE AssessmentTitle = 'ACT'
AND AcademicSubject IN ('Math', 'Reading', 'Writing', 'Composite Score', 'English (ACT Only)', 'Science (ACT Only)')
AND AssessedGradeLevel = 'Grade 12'

UNION

SELECT * 
FROM ALLASSESSMENTS
WHERE AssessmentTitle = 'SAT'
AND AcademicSubject IN ('Math', 'Reading', 'Writing', 'Composite Score')
AND AssessedGradeLevel = 'Grade 12'

UNION

SELECT * 
FROM ALLASSESSMENTS
WHERE AssessmentTitle = 'ECA'
AND AcademicSubject IN ('English 10 Only', 'Algebra I Only', 'Both English 10 and Algebra I')
AND AssessedGradeLevel IN ('Grade 10', 'Grade 11', 'Grade 12')

UNION

SELECT * 
FROM ALLASSESSMENTS
WHERE AssessmentTitle = 'ISTEP+'
AND AcademicSubject IN ('English/Language Arts Only', 'Math Only', 'Both English/Language Arts and Math')
AND AssessedGradeLevel IN ('Grade 3', 'Grade 4', 'Grade 5', 'Grade 6', 'Grade 7', 'Grade 8', 'Grade 10')

UNION

SELECT * 
FROM ALLASSESSMENTS
WHERE AssessmentTitle = 'ISTEP+'
AND AcademicSubject IN ('Science Only')
AND AssessedGradeLevel IN ('Grade 4', 'Grade 6', 'Grade 10')

UNION

SELECT * 
FROM ALLASSESSMENTS
WHERE AssessmentTitle = 'ISTEP+'
AND AcademicSubject IN ('Social Studies Only')
AND AssessedGradeLevel IN ('Grade 5', 'Grade 7')

UNION

SELECT * 
FROM ALLASSESSMENTS
WHERE AssessmentTitle = 'ISTAR'
AND AcademicSubject IN ('English/Language Arts Only', 'Math Only')
AND AssessedGradeLevel IN ('Grade 3', 'Grade 4', 'Grade 5', 'Grade 6', 'Grade 7', 'Grade 8', 'Grade 10')

UNION

SELECT * 
FROM ALLASSESSMENTS
WHERE AssessmentTitle = 'ISTAR'
AND AcademicSubject IN ('Science Only')
AND AssessedGradeLevel IN ('Grade 4', 'Grade 6', 'Grade 10')

UNION

SELECT * 
FROM ALLASSESSMENTS
WHERE AssessmentTitle = 'ISTAR'
AND AcademicSubject IN ('Social Studies Only')
AND AssessedGradeLevel IN ('Grade 5', 'Grade 7')

UNION

SELECT * 
FROM ALLASSESSMENTS
WHERE AssessmentTitle = 'WIDA'
AND AcademicSubject = 'English'

)A
GROUP BY AssessmentTitle, AssessedGradeLevel, AcademicSubject, MaxScore

)
GO