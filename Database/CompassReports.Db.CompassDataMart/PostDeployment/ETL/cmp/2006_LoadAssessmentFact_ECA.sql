/* STUDENT ASSESSMENT PERFORMANCE FOR ECA */

INSERT INTO [CompassDataMart].[cmp].[AssessmentFact]
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
FROM [$(OdsDatabaseServer)].[$(OdsDatabaseName)].[cmp].[AssessmentFact_ECA]
OPTION (maxrecursion 0)

      
 