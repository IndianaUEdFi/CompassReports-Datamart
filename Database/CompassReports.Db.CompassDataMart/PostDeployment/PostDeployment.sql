GO

if ('$(InitialData)' = 'true')
Begin
PRINT 'Executing Initial Data Scripts:'
:r .\InitialData\Manifest.sql
End

GO
if ('$(ETL)' = 'true')
Begin
PRINT 'Executing ETL:'
:r .\ETL\Manifest.sql
End
GO

PRINT 'Applying User Roles'
:r .\UserRoleAssignment.sql

