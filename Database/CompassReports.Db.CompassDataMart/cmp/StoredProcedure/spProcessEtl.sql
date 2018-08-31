CREATE PROCEDURE [cmp].[spProcessEtl] (
	@OdsDatabaseReference nvarchar(512)
	) AS

EXEC [cmp].[spClearSchoolDataForOds] @OdsDatabaseReference
EXEC [cmp].[spLoadSchoolYearDimension] @OdsDatabaseReference
EXEC [cmp].[spLoadSchoolDimension] @OdsDatabaseReference
EXEC [cmp].[spLoadEnrollmentFact] @OdsDatabaseReference
EXEC [cmp].[spLoadAttendanceFact] @OdsDatabaseReference
EXEC [cmp].[spLoadAssessmentFact_IREAD-3] @OdsDatabaseReference
EXEC [cmp].[spLoadAssessmentFact_ISTEP+] @OdsDatabaseReference
EXEC [cmp].[spLoadAssessmentFact_ISTAR] @OdsDatabaseReference
EXEC [cmp].[spLoadAssessmentFact_ECA] @OdsDatabaseReference
EXEC [cmp].[spLoadAssessmentFact_CollegeCareerReadiness] @OdsDatabaseReference
EXEC [cmp].[spLoadAssessmentFact_SAT-ACT] @OdsDatabaseReference
EXEC [cmp].[spLoadAssessmentFact_SAT-ACTCompositeScore] @OdsDatabaseReference
EXEC [cmp].[spLoadAssessmentFact_WIDA] @OdsDatabaseReference
EXEC [cmp].[spLoadGraduationFact] @OdsDatabaseReference
