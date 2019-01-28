CREATE FUNCTION cmp.StudentEnrollment()
RETURNS TABLE AS

RETURN
( 

WITH Multiracial AS
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

,DATES AS
(
SELECT SchoolId
	 , SchoolYear
	 , MIN(BeginDate) AS BeginDate
	 , MAX(EndDate) AS EndDate
FROM edfi.Session 
GROUP BY  SchoolId, SchoolYear
)


SELECT SSA.[StudentUSI]
      ,SSA.[SchoolId]
	  ,CASE WHEN SFSET.Description = 'Free' THEN 'Free meals'
			WHEN SFSET.Description = 'Reduced price' THEN 'Reduced price meals'
			ELSE 'Paid meals'
	   END AS FreeReducedLunchStatus
	  ,CASE WHEN LEPT.Description IN ('Limited', 'Limited Monitored 1', 'Limited Monitored 2') THEN 'English Language Learner'
			ELSE 'Non-English Language Learner'
		END AS EnglishLanguageLearnerStatus
	  ,DS.SchoolYear
      ,CASE WHEN GLT.Description = 'First grade' THEN 'Grade 1'
			WHEN GLT.Description = 'Second grade' THEN 'Grade 2'
			WHEN GLT.Description = 'Third grade' THEN 'Grade 3'
			WHEN GLT.Description = 'Fourth grade' THEN 'Grade 4'
			WHEN GLT.Description = 'Fifth grade' THEN 'Grade 5'
			WHEN GLT.Description = 'Sixth grade' THEN 'Grade 6'
			WHEN GLT.Description = 'Seventh grade' THEN 'Grade 7'
			WHEN GLT.Description = 'Eighth grade' THEN 'Grade 8'
			WHEN GLT.Description = 'Ninth grade' THEN 'Grade 9'
			WHEN GLT.Description = 'Tenth grade' THEN 'Grade 10'
			WHEN GLT.Description = 'Eleventh grade' THEN 'Grade 11'
			WHEN GLT.Description = 'Twelfth grade' THEN 'Grade 12'
			WHEN GLT.Description = 'Preschool/Prekindergarten' THEN 'Pre-Kindergarten'
			WHEN GLT.Description = 'Kindergarten' THEN 'Kindergarten'
	   END AS GradeLevel
	  ,CASE WHEN SE.[HispanicLatinoEthnicity] = 1 THEN 'Hispanic'
			WHEN SE.[HispanicLatinoEthnicity] = 0 AND SE.Racecount > 1 THEN 'Multiracial'
			WHEN SE.[HispanicLatinoEthnicity] = 0 AND SE.Racecount = 1 AND SE.Ethnicity = 'American Indian - Alaskan Native' THEN  'American Indian'
			WHEN SE.[HispanicLatinoEthnicity] = 0 AND SE.Racecount = 1 AND SE.Ethnicity = 'White' THEN  'White'
			WHEN SE.[HispanicLatinoEthnicity] = 0 AND SE.Racecount = 1 AND SE.Ethnicity = 'Asian' THEN  'Asian'
			WHEN SE.[HispanicLatinoEthnicity] = 0 AND SE.Racecount = 1 AND SE.Ethnicity = 'Black - African American' THEN  'Black'
			WHEN SE.[HispanicLatinoEthnicity] = 0 AND SE.Racecount = 1 AND SE.Ethnicity = 'Native Hawaiian - Pacific Islander' THEN  'Native Hawaiian or Other Pacific Islander'
		END AS Ethnicity
	  ,CASE WHEN GLT.Description IN ('Tenth grade', 'Ninth grade', 'Eleventh grade', 'Twelfth grade') AND SSA.GraduationSchoolYear IS NOT NULL THEN CAST(SSA.[GraduationSchoolYear] AS NVARCHAR(15))
			WHEN GLT.Description = 'Ninth grade' AND  SSA.GraduationSchoolYear IS NULL THEN CAST((DS.SchoolYear + 3) AS NVARCHAR(15))
			WHEN GLT.Description = 'Tenth grade' AND  SSA.GraduationSchoolYear IS NULL THEN CAST((DS.SchoolYear + 2) AS NVARCHAR(15))
			WHEN GLT.Description = 'Eleventh grade' AND  SSA.GraduationSchoolYear IS NULL THEN CAST((DS.SchoolYear + 1) AS NVARCHAR(15))
			WHEN GLT.Description = 'Twelfth grade' AND  SSA.GraduationSchoolYear IS NULL THEN CAST(DS.SchoolYear  AS NVARCHAR(15))
		END AS ExpectedGraduationYear
	  ,CASE WHEN P.Description = 'Special Education' THEN 'Special Education'
			ELSE 'General Education'
		END AS SpecialEducationStatus
FROM [edfi].[StudentSchoolAssociation] SSA
JOIN [edfi].[GradeLevelDescriptor] GLD
	ON GLD.[GradeLevelDescriptorId] = SSA.[EntryGradeLevelDescriptorId]
JOIN [edfi].[GradeLevelType] GLT
	ON GLD.[GradeLevelTypeId] = GLT.[GradeLevelTypeId]
JOIN [edfi].[Student] S
	ON S.[StudentUSI] = SSA.[StudentUSI]
JOIN DATES DS
	ON DS.[SchoolId] = SSA.[SchoolId]
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
	ON SE.[StudentUSI] = SSA.[StudentUSI]
LEFT JOIN [edfi].[StudentSpecialEducationProgramAssociation] SPED
	ON SSA.[StudentUSI] = SPED.[StudentUSI]
LEFT JOIN [edfi].[ProgramType] P
	ON SPED.[ProgramTypeId] = P.[ProgramTypeId]
	AND P.Description = 'Special Education'
LEFT JOIN Multiracial M
	ON M.[StudentUSI] = S.[StudentUSI]
WHERE SSA.ExitWithdrawDate IS NULL AND SSA.ExitWithdrawTypeDescriptorId IS NULL
GROUP BY SSA.[StudentUSI]
		,SSA.[SchoolId]
		,CASE WHEN SFSET.Description = 'Free' THEN 'Free meals'
			  WHEN SFSET.Description = 'Reduced price' THEN 'Reduced price meals'
			  ELSE 'Paid meals'
		 END 
		,CASE WHEN LEPT.Description IN ('Limited', 'Limited Monitored 1', 'Limited Monitored 2') THEN 'English Language Learner'
			  ELSE 'Non-English Language Learner'
		  END 
		,DS.SchoolYear
      ,CASE WHEN GLT.Description = 'First grade' THEN 'Grade 1'
			WHEN GLT.Description = 'Second grade' THEN 'Grade 2'
			WHEN GLT.Description = 'Third grade' THEN 'Grade 3'
			WHEN GLT.Description = 'Fourth grade' THEN 'Grade 4'
			WHEN GLT.Description = 'Fifth grade' THEN 'Grade 5'
			WHEN GLT.Description = 'Sixth grade' THEN 'Grade 6'
			WHEN GLT.Description = 'Seventh grade' THEN 'Grade 7'
			WHEN GLT.Description = 'Eighth grade' THEN 'Grade 8'
			WHEN GLT.Description = 'Ninth grade' THEN 'Grade 9'
			WHEN GLT.Description = 'Tenth grade' THEN 'Grade 10'
			WHEN GLT.Description = 'Eleventh grade' THEN 'Grade 11'
			WHEN GLT.Description = 'Twelfth grade' THEN 'Grade 12'
			WHEN GLT.Description = 'Preschool/Prekindergarten' THEN 'Pre-Kindergarten'
			WHEN GLT.Description = 'Kindergarten' THEN 'Kindergarten'
	   END 
	  ,CASE WHEN SE.[HispanicLatinoEthnicity] = 1 THEN 'Hispanic'
			WHEN SE.[HispanicLatinoEthnicity] = 0 AND SE.Racecount > 1 THEN 'Multiracial'
			WHEN SE.[HispanicLatinoEthnicity] = 0 AND SE.Racecount = 1 AND SE.Ethnicity = 'American Indian - Alaskan Native' THEN  'American Indian'
			WHEN SE.[HispanicLatinoEthnicity] = 0 AND SE.Racecount = 1 AND SE.Ethnicity = 'White' THEN  'White'
			WHEN SE.[HispanicLatinoEthnicity] = 0 AND SE.Racecount = 1 AND SE.Ethnicity = 'Asian' THEN  'Asian'
			WHEN SE.[HispanicLatinoEthnicity] = 0 AND SE.Racecount = 1 AND SE.Ethnicity = 'Black - African American' THEN  'Black'
			WHEN SE.[HispanicLatinoEthnicity] = 0 AND SE.Racecount = 1 AND SE.Ethnicity = 'Native Hawaiian - Pacific Islander' THEN  'Native Hawaiian or Other Pacific Islander'
		END 
	  ,CASE WHEN P.Description = 'Special Education' THEN 'Special Education'
			ELSE 'General Education'
		END 
	  ,CASE WHEN GLT.Description IN ('Tenth grade', 'Ninth grade', 'Eleventh grade', 'Twelfth grade') AND SSA.GraduationSchoolYear IS NOT NULL THEN CAST(SSA.[GraduationSchoolYear] AS NVARCHAR(15))
			WHEN GLT.Description = 'Ninth grade' AND  SSA.GraduationSchoolYear IS NULL THEN CAST((DS.SchoolYear + 3) AS NVARCHAR(15))
			WHEN GLT.Description = 'Tenth grade' AND  SSA.GraduationSchoolYear IS NULL THEN CAST((DS.SchoolYear + 2) AS NVARCHAR(15))
			WHEN GLT.Description = 'Eleventh grade' AND  SSA.GraduationSchoolYear IS NULL THEN CAST((DS.SchoolYear + 1) AS NVARCHAR(15))
			WHEN GLT.Description = 'Twelfth grade' AND  SSA.GraduationSchoolYear IS NULL THEN CAST(DS.SchoolYear  AS NVARCHAR(15))
		END


)
GO