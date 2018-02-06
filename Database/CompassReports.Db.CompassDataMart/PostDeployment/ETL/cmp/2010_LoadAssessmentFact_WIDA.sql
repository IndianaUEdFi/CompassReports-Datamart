/* STUDENT ASSESSMENT PERFORMANCE FOR SAT AND ACT TAKEN */

INSERT INTO [cmp].[AssessmentFact]
           ([DemographicKey]
           ,[SchoolKey]
           ,[SchoolYearKey]
           ,[AssessmentKey]
           ,[PerformanceKey]
           ,[GoodCauseExemptionKey]
           ,[AssessmentStudentCount]
		   )

SELECT  DemographicId,
		SchoolId,
		SchoolYear,
		AssessmentKey,
		PerformanceKey,
		GoodCauseExemptionKey,
		StudentCount
FROM [$(OdsDatabaseServer)].[$(OdsDatabaseName)].[cmp].[AssessmentFact_WIDA]
OPTION (maxrecursion 0)
      
 