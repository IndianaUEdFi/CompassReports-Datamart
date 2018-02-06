CREATE FUNCTION cmp.GoodCauseExemptionDim()
RETURNS TABLE AS

RETURN
( 
SELECT GoodCauseExemption,
		ROW_NUMBER() OVER (ORDER BY GoodCauseExemption) AS GoodCauseExemptionKey
FROM
(
SELECT 'Good Cause Exemption Granted' AS [GoodCauseExemption] 
UNION
SELECT 'No Good Cause Exemption Granted' AS [GoodCauseExemption] 
UNION
SELECT 'Not Applicable' AS [GoodCauseExemption] 
)A

)
GO