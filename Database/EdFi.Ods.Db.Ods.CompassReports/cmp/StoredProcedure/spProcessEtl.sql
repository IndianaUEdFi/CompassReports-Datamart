CREATE PROCEDURE [cmp].[spProcessEtl] AS

EXEC [cmp].[spClearSchoolDataForOds] 
EXEC [cmp].[spLoadSchoolYearDimension] 
EXEC [cmp].[spLoadSchoolDimension] 
EXEC [cmp].[spLoadEnrollmentFact] 
EXEC [cmp].[spLoadAttendanceFact] 
EXEC [cmp].[spLoadAssessmentFact_IREAD-3] 
EXEC [cmp].[spLoadAssessmentFact_ISTEP+] 
EXEC [cmp].[spLoadAssessmentFact_ISTAR] 
EXEC [cmp].[spLoadAssessmentFact_ECA] 
EXEC [cmp].[spLoadAssessmentFact_CollegeCareerReadiness] 
EXEC [cmp].[spLoadAssessmentFact_SAT-ACT] 
EXEC [cmp].[spLoadAssessmentFact_SAT-ACTCompositeScore] 
EXEC [cmp].[spLoadAssessmentFact_WIDA] 
EXEC [cmp].[spLoadGraduationFact] 

select LocalEducationAgencyId
FROM edfi.LocalEducationAgency
FOR XML PATH ('LocalEducationAgency'), ROOT ('root')