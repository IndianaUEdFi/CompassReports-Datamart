/* Load GraduationStatus Junk Dimension */

WITH GraduationStatus (GraduationStatus) AS
(
SELECT 'Graduates'
UNION
SELECT 'Course Completion'
UNION
SELECT 'Special Education Certificate'
UNION
SELECT 'HSE'
UNION
SELECT 'Students Still in School'
UNION
SELECT 'Dropouts'
)


,DiplomaType (DiplomaType) AS
(
SELECT 'Honors'
UNION
SELECT 'Core 40'
UNION
SELECT 'General'
)


,GraduationWaiver (GraduationWaiver) AS 
(
SELECT 'Waiver'
UNION
SELECT 'Non-Waiver'
)

/* INSERT INTO GraduationStatusJunkDimension */
INSERT INTO [cmp].[GraduationStatusJunkDimension]
           ([GraduationStatus]
           ,[DiplomaType]
           ,[GraduationWaiver])

SELECT *
FROM GraduationStatus
CROSS JOIN DiplomaType
CROSS JOIN GraduationWaiver
WHERE GraduationStatus = 'Graduates'

UNION

SELECT GraduationStatus, 'Not Applicable','Not Applicable'
FROM GraduationStatus
WHERE GraduationStatus <> 'Graduates'