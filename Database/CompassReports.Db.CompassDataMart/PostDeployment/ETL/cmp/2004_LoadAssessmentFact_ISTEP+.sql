/* STUDENT ASSESSMENT PERFORMANCE FOR ISTEP+ */
INSERT INTO [cmp].[AssessmentFact]
           ([DemographicKey]
           ,[SchoolKey]
           ,[SchoolYearKey]
           ,[AssessmentKey]
           ,[PerformanceKey]
           ,[GoodCauseExemptionKey]
           ,[AssessmentStudentCount]
		   )
SELECT [DemographicId]
    ,[SchoolId]
    ,[SchoolYear]
    ,[AssessmentKey]
    ,[PerformanceKey]
    ,[GoodCauseExemptionKey]
    ,[StudentCount]
FROM [$(OdsDatabaseServer)].[$(OdsDatabaseName)].[cmp].[AssessmentFact_ISTEP+]
OPTION (maxrecursion 0)

      
 