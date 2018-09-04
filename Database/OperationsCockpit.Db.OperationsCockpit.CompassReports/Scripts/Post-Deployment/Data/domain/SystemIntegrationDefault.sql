DECLARE @Compass_SystemIntegrationDefault TABLE (
	[SystemId] [int] NOT NULL,
	[OutputType] [int] NOT NULL,
	[Format] [int] NOT NULL,
	[NotificationEmailAddresses] [nvarchar](255) NULL)
	
INSERT INTO @Compass_SystemIntegrationDefault 
		([SystemId], [OutputType], [Format], [NotificationEmailAddresses])
SELECT [Id], 1, 2, NULL
FROM @Compass_System

SELECT * INTO #Compass_SystemIntegrationDefaultDiff FROM (
SELECT [SystemId], [OutputType], [Format], [NotificationEmailAddresses]
FROM @Compass_SystemIntegrationDefault
EXCEPT
SELECT [SystemId], [OutputType], [Format], [NotificationEmailAddresses]
FROM [domain].[SystemIntegrationDefault]) Diffs

INSERT INTO #Compass_SystemIntegrationDefaultDiff SELECT * FROM (
SELECT [SystemId], [OutputType], [Format], [NotificationEmailAddresses]
FROM [domain].[SystemIntegrationDefault]
WHERE [SystemId] IN (SELECT [System_Id] FROM domain.FeatureSystem WHERE [Feature_Id] = @Compass_FeatureId)
EXCEPT
SELECT [SystemId], [OutputType], [Format], [NotificationEmailAddresses]
FROM @Compass_SystemIntegrationDefault
) Diffs

IF EXISTS(SELECT 1 FROM #Compass_SystemIntegrationDefaultDiff)
BEGIN
	PRINT 'Upserting SystemIntegrationDefault Data for ' + @Compass_FeatureDescription

	MERGE INTO [domain].[SystemIntegrationDefault] AS Target
		USING @Compass_SystemIntegrationDefault AS Source ON Target.[SystemId]=Source.[SystemId] 
		WHEN MATCHED THEN
			UPDATE SET Target.[OutputType]=Source.[OutputType], Target.[Format]=Source.[Format], Target.[NotificationEmailAddresses]=Source.[NotificationEmailAddresses], Target.ModifiedBy=N'Deployment', Target.ModifiedDate=GetDate()
		WHEN NOT MATCHED BY TARGET THEN
			INSERT ([SystemId], [OutputType], [Format], [NotificationEmailAddresses], CreatedBy, CreatedDate)
			VALUES (Source.[SystemId], Source.[OutputType], Source.[Format], Source.[NotificationEmailAddresses], N'Deployment', GetDate())
		WHEN NOT MATCHED BY SOURCE AND [SystemId] IN (SELECT [System_Id] FROM domain.FeatureSystem WHERE [Feature_Id] = @Compass_FeatureId) THEN
			DELETE; 

END
DROP TABLE #Compass_SystemIntegrationDefaultDiff
