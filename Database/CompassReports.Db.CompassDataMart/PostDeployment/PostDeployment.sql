GO

if ('$(InitialData)' = 'true')
Begin
PRINT 'Executing Initial Data Scripts:'
	DECLARE @StartYear smallint = CAST('$(ExpectedGraduationStartYear)' AS smallint)
	DECLARE @EndYear smallint = CAST('$(ExpectedGraduationEndYear)' AS SMALLINT);
	:r .\InitialData\Manifest.sql
End
GO

PRINT 'Applying User Roles'
:r .\UserRoleAssignment.sql

