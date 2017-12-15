CREATE ROLE [MigrationUsers]
GO

ALTER ROLE [db_owner] ADD MEMBER [MigrationUsers]
GO
