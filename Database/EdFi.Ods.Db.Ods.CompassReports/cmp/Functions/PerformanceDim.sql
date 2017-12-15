CREATE FUNCTION cmp.PerformanceDim()
RETURNS TABLE AS

RETURN
( 

WITH ScoreResult (Score) AS 
	(
	SELECT 1
	UNION ALL
	SELECT Score + 1
	FROM ScoreResult
	WHERE Score < 1600
	)

SELECT PerformanceLevel
	 , ScoreResult
	 , ROW_NUMBER()OVER (ORDER BY PerformanceLevel, ScoreResult) AS PerformanceKey
FROM (
	SELECT 'Not Applicable' AS [PerformanceLevel]
		 , CAST(Score AS INT) AS [ScoreResult]
	FROM ScoreResult

	UNION
	SELECT 'Pass' AS [PerformanceLevel]
		 , NULL AS [ScoreResult]
	UNION
	SELECT 'Did Not Pass' AS [PerformanceLevel]
		 , NULL AS [ScoreResult]
	UNION
	SELECT 'Pass+' AS [PerformanceLevel]
		 , NULL AS [ScoreResult]
	UNION
	SELECT 'Entering' AS [PerformanceLevel]
		 , NULL AS [ScoreResult]
	UNION
	SELECT 'Developing' AS [PerformanceLevel]
		 , NULL AS [ScoreResult]
	UNION
	SELECT 'Bridging' AS [PerformanceLevel]
		 , NULL AS [ScoreResult]
	UNION
	SELECT 'Reaching' AS [PerformanceLevel]
		 , NULL AS [ScoreResult]
	UNION
	SELECT 'Emerging' AS [PerformanceLevel]
		 , NULL AS [ScoreResult]
	UNION
	SELECT 'Expanding' AS [PerformanceLevel]
		 , NULL AS [ScoreResult]
	
	UNION
	SELECT 'Took SAT' AS [PerformanceLevel]
		 , NULL AS [ScoreResult]
	UNION
	SELECT 'Did Not Take SAT' AS [PerformanceLevel]
		 , NULL AS [ScoreResult]
	UNION
	SELECT 'Took ACT' AS [PerformanceLevel]
		 , NULL AS [ScoreResult]
	UNION
	SELECT 'Did Not Take ACT' AS [PerformanceLevel]
		 , NULL AS [ScoreResult]
	UNION
	SELECT 'Took an AP Exam' AS [PerformanceLevel]
		 , NULL AS [ScoreResult]
	UNION
	SELECT 'Did Not Take an AP Exam' AS [PerformanceLevel]
		 , NULL AS [ScoreResult]
) PL

)
GO

