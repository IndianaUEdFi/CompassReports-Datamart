--False is used because dapac deployment does an IsNullOrWhitespase check on values passed and all defined sqlcmd variables MUST be passed.
--While it does appear that "extra" variables passed to the dacpac deployment should be available to these scripts, it would require all of
--these statements to be written as dynamic sql as environment variables are ignored during compilation, and values could not be passed
--without hard-coding. Additionally detecting "null" vs empty on sqlcmd variables is difficult as the deployment process includes an
--::onerror exit directive. Trying to access a null value raises an error. Meaning the error trapping would have to be disabled while
--we checked for the existence of the sqlcmd variable, and if it was not there, set it to a default. This also makes all the possible
--variables very hard to discover. For this reason these options were abandoned.
-- The option other than what is done here was to introduce an additional boolean variable for each user name and password for each
--credential, however in the interests of keeping the number of variables down and for simplicity, we're just using the 'false' value.

DECLARE @DefaultSchema sysname,
	@Role sysname,
	@UserName sysname,
	@UserPassword nvarchar(128)

DECLARE userRoles CURSOR FOR
SELECT * FROM (
VALUES
('dbo','MigrationRole','$(MigrationUserName)','$(MigrationUserPassword)')
,('dbo','ApplicationRole','$(ApplicationUserName)','$(ApplicationUserPassword)')
) [Users]([defaultSchema],[role],[userName],[userPassword])

DECLARE @testType nvarchar(1)
DECLARE @testAuthenticationType int
DECLARE @testSid varbinary(85)
DECLARE @userAction nvarchar(50)
DECLARE @errorMessage nvarchar(max)
DECLARE @userCmd nvarchar(max)

OPEN userRoles
FETCH NEXT FROM userRoles INTO @DefaultSchema, @Role, @UserName, @UserPassword

WHILE @@FETCH_STATUS = 0
BEGIN
	IF (@UserName <> 'false')
	--User Specified
	BEGIN
		SELECT @testType = [type] FROM sys.database_principals WHERE [name] = @Role
		IF (@testType IS NOT NULL)
		BEGIN
			IF (@testType = 'R')
			--Role exists
			BEGIN
				SET @testType = NULL
				SELECT @testType = [type], @testAuthenticationType = [authentication_type], @testSid = [sid] FROM sys.database_principals WHERE [name] = @UserName
				IF (@testType IS NOT NULL)
				--A principal exists by this name
				BEGIN
					IF (@testType = 'S')
					--SQL User Exists
					BEGIN
						IF (@testAuthenticationType = 1)
						--SQL User is an Instance Login
						BEGIN
							IF (EXISTS(SELECT sp.name LoginName FROM sys.database_principals dp INNER JOIN sys.server_principals sp ON dp.sid = sp.sid where dp.name = @UserName))
							--SQL User wuth Login
							BEGIN
								PRINT 'Found SQL User named ''' + @UserName + ''' that is associated with a SQL Login.'
								SET @userAction = 'ALTER'
							END
							ELSE
							--Orphaned User
							BEGIN
								PRINT 'Found Orphaned User named ''' + @UserName + '''... Dropping'
								EXEC('DROP USER [' + @UserName + ']')
								SET @testType = NULL
								SET @userAction = 'CREATE'
							END
						END
						ELSE IF (@testAuthenticationType = 2)
						--Contained Database User
						BEGIN
							PRINT 'Found SQL User named ''' + @UserName + ''' of Type S with Database Authentication'
							SET @userAction = 'ALTER'
						END
						ELSE
						--SQL user that is not a contained user or an instance user???
						BEGIN
							SET @errorMessage = 'User named ''' + @UserName + ''' was found, but with an Authentication Type of ' + CAST(@testAuthenticationType AS nvarchar(1)) + ', which is unsupported';
							THROW 51000,@errorMessage, 1;
						END
					END	
					ELSE IF (@testType IN ('U','G'))
					--Windows user
					BEGIN
						PRINT 'Found Windows User or Group named ''' + @UserName + ''' of Type ''' + @testType + '''.'
						SET @userAction = 'ALTER'
					END	
					ELSE
					--Principal exists but is not an expected user type
					BEGIN
						SET @errorMessage = 'Found object named ''' + @UserName + ''', but it was of type '''+ @testType + ''', not ''S'' or ''U'' as expected.';
						THROW 51000, @errorMessage, 1;
					END
				END
				ELSE
				--No object exists
				BEGIN
					SET @userAction = 'CREATE'
				END				
			END	
			ELSE
			--Principal of the same name exisits but it is not a database role
			BEGIN
				SET @errorMessage = 'Found object named ''' + @Role + ''', but it was of type '''+ @testType + ''', not ''R'' as expected.';
				THROW 51000, @errorMessage, 1;
			END
		END
		ELSE
		--Role does not exists
		BEGIN
			SET @errorMessage = 'Unable to find role named ''' + @Role + '''.';
			THROW 51000, @errorMessage, 1;
		END


		IF (@userAction IS NOT NULL)
		BEGIN
			SET @userCmd = @userAction + ' USER [' + @UserName + '] WITH DEFAULT_SCHEMA=[' + @DefaultSchema + ']'
			IF(@UserPassword <> '' AND ((@testType = 'S' AND @testAuthenticationType = 2) OR @testType IS NULL))
			BEGIN
				SET @userCmd = @userCmd + ', PASSWORD=''' + @UserPassword + ''''
			END
			EXEC(@userCmd)
		END

		EXEC('ALTER ROLE [' + @Role +'] ADD Member [' + @userName + ']')
	
	END
	ELSE
	--No User Specified
	BEGIN
		PRINT 'No user specified for ''' + @Role + '''.'
	END

	FETCH NEXT FROM userRoles INTO @DefaultSchema, @Role, @UserName, @UserPassword
END

CLOSE userRoles
DEALLOCATE userRoles



