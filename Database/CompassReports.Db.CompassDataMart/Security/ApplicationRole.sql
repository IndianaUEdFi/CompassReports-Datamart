CREATE ROLE [ApplicationRole]
GO

ALTER ROLE [db_datareader] ADD MEMBER [ApplicationRole]
GO

ALTER ROLE [db_datawriter] ADD MEMBER [ApplicationRole]
Go
