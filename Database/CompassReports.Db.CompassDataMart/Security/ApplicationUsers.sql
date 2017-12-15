CREATE ROLE [ApplicationUsers]
GO

ALTER ROLE [db_datareader] ADD MEMBER [ApplicationUsers]
GO

ALTER ROLE [db_datawriter] ADD MEMBER [ApplicationUsers]
Go
