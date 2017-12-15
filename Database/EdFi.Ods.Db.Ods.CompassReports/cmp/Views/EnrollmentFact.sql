CREATE VIEW [cmp].[EnrollmentFact]
	AS 
SELECT  
		DD.DemographicId,
		SE.SchoolId,
		SchoolYear,
		COUNT(DISTINCT SE.StudentUSI) AS EnrollmentCount
FROM [cmp].StudentEnrollment() SE 
JOIN [cmp].DemographicDim() DD
	ON SE.GradeLevel = DD.GradeLevel
	AND SE.Ethnicity = DD.Ethnicity
	AND SE.FreeReducedLunchStatus = DD.FreeReducedLunchStatus
	AND SE.SpecialEducationStatus = DD.SpecialEducationStatus
	AND SE.EnglishLanguageLearnerStatus = DD.EnglishLanguageLearnerStatus
	AND (SE.ExpectedGraduationYear = DD.ExpectedGraduationYear OR SE.ExpectedGraduationYear IS NULL)
GROUP BY
		SchoolYear,
		SE.SchoolId,
		DD.DemographicId
/* ??NEED TO KNOW IF STUDENTS WHO LEFT SCHOOL DURING THE SCHOOL YEAR SHOULD BE COUNTED?? */