CREATE ROLE [MigrationRole]
GO

ALTER ROLE [db_owner] ADD MEMBER [MigrationRole]
GO
