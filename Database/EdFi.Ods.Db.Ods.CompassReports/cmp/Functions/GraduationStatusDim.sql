CREATE FUNCTION cmp.GraduationStatusDim()
RETURNS TABLE AS

RETURN
( 

WITH GraduationStatus AS
(
SELECT 'Graduates' AS GraduationStatus
UNION
SELECT 'Course Completion' AS GraduationStatus
UNION
SELECT 'Special Education Certificate' AS GraduationStatus
UNION
SELECT 'HSE' AS GraduationStatus
UNION
SELECT 'Students Still in School' AS GraduationStatus
UNION
SELECT 'Dropouts' AS GraduationStatus
)

,DiplomaType AS
(
SELECT 'Honors' AS DiplomaType
UNION
SELECT 'General' AS DiplomaType
UNION
SELECT 'Core 40' AS DiplomaType
)

,GraduationWaiver AS
(
SELECT 'Waiver' AS GraduationWaiver
UNION
SELECT 'Non-Waiver' AS GraduationWaiver
)


SELECT GraduationStatus
	 , DiplomaType
	 , GraduationWaiver
	 , ROW_NUMBER()OVER (ORDER BY GraduationStatus, DiplomaType, GraduationWaiver) AS GraduationStatusKey
FROM (
	SELECT GraduationStatus
		 , DiplomaType
		 , GraduationWaiver
	FROM GraduationStatus
	CROSS JOIN DiplomaType
	CROSS JOIN GraduationWaiver
	WHERE GraduationStatus = 'Graduates'

	UNION

	SELECT GraduationStatus
		 , 'Not Applicable'
		 , 'Not Applicable'
	FROM GraduationStatus
	WHERE GraduationStatus <> 'Graduates'
	) GS

)
GO