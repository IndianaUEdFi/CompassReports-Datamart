if ('$(Data)' = 'true')
Begin
	PRINT 'Deploying Cockpit Data:'
	:r .\Data\Manifest.sql
End