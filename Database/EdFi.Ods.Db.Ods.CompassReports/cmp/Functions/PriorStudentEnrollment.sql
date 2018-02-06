CREATE FUNCTION cmp.PriorStudentEnrollment()
RETURNS TABLE AS

RETURN
( 

WITH DATES AS
(
SELECT SchoolId
	 , SchoolYear
	 , MIN(BeginDate) AS BeginDate
	 , MAX(EndDate) AS EndDate
FROM edfi.Session 
GROUP BY  SchoolId, SchoolYear
)

,Multiracial AS
(
SELECT StudentUSI
    ,COUNT(DISTINCT RaceTypeId) AS RaceCount
FROM [edfi].[StudentRace]
GROUP BY StudentUSI
HAVING COUNT(DISTINCT RaceTypeId) > 1
)

,StudentEthnicity AS
(
SELECT	S. StudentUSI, 
		S.[HispanicLatinoEthnicity], 
		RT.Description AS Ethnicity, 
		ISNULL(RaceCount, 1) AS RaceCount
FROM [edfi].[Student] S
JOIN [edfi].[StudentRace] SR
	ON S.StudentUSI = SR.StudentUSI
JOIN [edfi].[RaceType] RT
	ON RT.[RaceTypeId] = SR.[RaceTypeId]
LEFT JOIN Multiracial M
	ON M.StudentUSI = S.StudentUSI
)


SELECT SCA.[StudentUSI]
      ,SCA.[EducationOrganizationId] AS [SchoolId]
	  ,CASE WHEN SFSET.Description = 'Free' THEN 'Free meals'
			WHEN SFSET.Description = 'Reduced price' THEN 'Reduced price meals'
			ELSE 'Paid meals'
	   END AS FreeReducedLunchStatus
	  ,CASE WHEN LEPT.Description IN ('Limited', 'Limited Monitored 1', 'Limited Monitored 2') THEN 'English Language Learner'
			ELSE 'Non-English Language Learner'
		END AS EnglishLanguageLearnerStatus
	  ,YEAR(SCA.[EndDate]) AS SchoolYear
      ,'Grade 12' AS GradeLevel
	  ,CASE WHEN SE.[HispanicLatinoEthnicity] = 1 THEN 'Hispanic'
			WHEN SE.[HispanicLatinoEthnicity] = 0 AND SE.Racecount > 1 THEN 'Multiracial'
			WHEN SE.[HispanicLatinoEthnicity] = 0 AND SE.Racecount = 1 AND SE.Ethnicity = 'American Indian - Alaskan Native' THEN  'American Indian'
			WHEN SE.[HispanicLatinoEthnicity] = 0 AND SE.Racecount = 1 AND SE.Ethnicity = 'White' THEN  'White'
			WHEN SE.[HispanicLatinoEthnicity] = 0 AND SE.Racecount = 1 AND SE.Ethnicity = 'Asian' THEN  'Asian'
			WHEN SE.[HispanicLatinoEthnicity] = 0 AND SE.Racecount = 1 AND SE.Ethnicity = 'Black - African American' THEN  'Black'
			WHEN SE.[HispanicLatinoEthnicity] = 0 AND SE.Racecount = 1 AND SE.Ethnicity = 'Native Hawaiian - Pacific Islander' THEN  'Native Hawaiian or Other Pacific Islander'
		END AS Ethnicity
	  ,YEAR(SCA.[EndDate]) AS ExpectedGraduationYear
	  ,CASE WHEN P.Description = 'Special Education' THEN 'Special Education'
			ELSE 'General Education'
		END AS SpecialEducationStatus
FROM [edfi].[StudentCohortAssociation] SCA
JOIN [edfi].[Student] S
	ON S.[StudentUSI] = SCA.[StudentUSI]
JOIN DATES DS
	ON DS.[SchoolId] = SCA.[EducationOrganizationId]
LEFT JOIN [edfi].[SchoolFoodServicesEligibilityDescriptor] SFSED
	ON S.[SchoolFoodServicesEligibilityDescriptorId] = SFSED.[SchoolFoodServicesEligibilityDescriptorId]
LEFT JOIN [edfi].[SchoolFoodServicesEligibilityType] SFSET
	ON SFSED.[SchoolFoodServicesEligibilityTypeId] = SFSET.[SchoolFoodServicesEligibilityTypeId]
	AND SFSET.Description IN ('Free', 'Full price', 'Reduced price')
LEFT JOIN [edfi].[LimitedEnglishProficiencyDescriptor] LEPD
	ON S.[LimitedEnglishProficiencyDescriptorId] = LEPD.[LimitedEnglishProficiencyDescriptorId]
LEFT JOIN [edfi].[LimitedEnglishProficiencyType] LEPT
	ON LEPD.[LimitedEnglishProficiencyTypeId] = LEPT.[LimitedEnglishProficiencyTypeId]
LEFT JOIN StudentEthnicity SE
	ON SE.[StudentUSI] = SCA.[StudentUSI]
LEFT JOIN [edfi].[StudentSpecialEducationProgramAssociation] SPED
	ON SCA.[StudentUSI] = SPED.[StudentUSI]
LEFT JOIN [edfi].[ProgramType] P
	ON SPED.[ProgramTypeId] = P.[ProgramTypeId]
	AND P.Description = 'Special Education'
LEFT JOIN Multiracial M
	ON M.[StudentUSI] = S.[StudentUSI]
WHERE SCA.[StudentUSI] NOT IN (SELECT [StudentUSI] FROM [edfi].[StudentSchoolAssociation])
GROUP BY SCA.[StudentUSI]
      ,SCA.[EducationOrganizationId] 
	  ,CASE WHEN SFSET.Description = 'Free' THEN 'Free meals'
			WHEN SFSET.Description = 'Reduced price' THEN 'Reduced price meals'
			ELSE 'Paid meals'
	   END 
	  ,CASE WHEN LEPT.Description IN ('Limited', 'Limited Monitored 1', 'Limited Monitored 2') THEN 'English Language Learner'
			ELSE 'Non-English Language Learner'
		END 
	  ,DS.SchoolYear
	  ,CASE WHEN SE.[HispanicLatinoEthnicity] = 1 THEN 'Hispanic'
			WHEN SE.[HispanicLatinoEthnicity] = 0 AND SE.Racecount > 1 THEN 'Multiracial'
			WHEN SE.[HispanicLatinoEthnicity] = 0 AND SE.Racecount = 1 AND SE.Ethnicity = 'American Indian - Alaskan Native' THEN  'American Indian'
			WHEN SE.[HispanicLatinoEthnicity] = 0 AND SE.Racecount = 1 AND SE.Ethnicity = 'White' THEN  'White'
			WHEN SE.[HispanicLatinoEthnicity] = 0 AND SE.Racecount = 1 AND SE.Ethnicity = 'Asian' THEN  'Asian'
			WHEN SE.[HispanicLatinoEthnicity] = 0 AND SE.Racecount = 1 AND SE.Ethnicity = 'Black - African American' THEN  'Black'
			WHEN SE.[HispanicLatinoEthnicity] = 0 AND SE.Racecount = 1 AND SE.Ethnicity = 'Native Hawaiian - Pacific Islander' THEN  'Native Hawaiian or Other Pacific Islander'
		END 
	  ,YEAR(SCA.[EndDate]) 
	  ,CASE WHEN P.Description = 'Special Education' THEN 'Special Education'
			ELSE 'General Education'
		END 

)
GO