if ('$(ETL)' = 'true')
Begin
PRINT 'Executing ETL:'
	EXEC [cmp].[spProcessEtl]
End
GO

PRINT 'Applying User Roles'
:r .\UserRoleAssignment.sql

