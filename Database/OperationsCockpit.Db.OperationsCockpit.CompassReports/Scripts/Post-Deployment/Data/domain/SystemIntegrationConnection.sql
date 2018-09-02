DECLARE @Compass_SystemIntegrationConnection TABLE (
	[CompressionType] [int] NOT NULL,
	[EncryptionPassword] [nvarchar](1024) NULL,
	[StorageAccountName] [nvarchar](255) NULL,
	[SharedAccessSignature] [nvarchar](255) NULL,
	[ContainerName] [nvarchar](255) NULL,
	[EndpointSuffix] [nvarchar](255) NULL,
	[EmailAddresses] [nvarchar](max) NULL,
	[LocationType] [int] NULL,
	[SFTP] [nvarchar](max) NULL,
	[SFTPPortNumber] [int] NULL,
	[Path] [nvarchar](max) NULL,
	[UserId] [nvarchar](max) NULL,
	[UserPassword] [nvarchar](max) NULL,
	[PublicKey] [nvarchar](max) NULL,
	[Discriminator] [nvarchar](128) NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
	[System_Id] [int] NOT NULL,
	[IncludeTimestamp] [bit] NOT NULL,
	[BundleNameTemplate] [nvarchar](255) NOT NULL,
	[NotificationEmailAddresses] [nvarchar](255) NULL,
	[IncludeInDefault] [bit] NOT NULL)
	
INSERT INTO @Compass_SystemIntegrationConnection 
	([CompressionType], [Discriminator], [Name], [System_Id], [IncludeTimestamp], [BundleNameTemplate], [NotificationEmailAddresses], [IncludeInDefault])
SELECT 0, 'SystemIntegrationConnectionNoOutput', 'No Delivery', [Id], 0, 'NA', NULL, 1
FROM @Compass_System

SELECT * INTO #Compass_SystemIntegrationConnectionDiff FROM (
SELECT [CompressionType], [EncryptionPassword], [StorageAccountName], [SharedAccessSignature], [ContainerName], [EndpointSuffix], [EmailAddresses], [LocationType], [SFTP], [SFTPPortNumber], [Path], [UserId], [UserPassword], [PublicKey], [Discriminator], [Name], [System_Id], [IncludeTimestamp], [BundleNameTemplate], [NotificationEmailAddresses], [IncludeInDefault]
FROM @Compass_SystemIntegrationConnection
EXCEPT
SELECT [CompressionType], [EncryptionPassword], [StorageAccountName], [SharedAccessSignature], [ContainerName], [EndpointSuffix], [EmailAddresses], [LocationType], [SFTP], [SFTPPortNumber], [Path], [UserId], [UserPassword], [PublicKey], [Discriminator], [Name], [System_Id], [IncludeTimestamp], [BundleNameTemplate], [NotificationEmailAddresses], [IncludeInDefault]
FROM [domain].[SystemIntegrationConnection]
) Diffs

INSERT INTO #Compass_SystemIntegrationConnectionDiff SELECT * FROM (
SELECT [CompressionType], [EncryptionPassword], [StorageAccountName], [SharedAccessSignature], [ContainerName], [EndpointSuffix], [EmailAddresses], [LocationType], [SFTP], [SFTPPortNumber], [Path], [UserId], [UserPassword], [PublicKey], [Discriminator], [Name], [System_Id], [IncludeTimestamp], [BundleNameTemplate], [NotificationEmailAddresses], [IncludeInDefault]
FROM [domain].[SystemIntegrationConnection]
WHERE System_Id IN (SELECT [System_Id] FROM domain.FeatureSystem WHERE [Feature_Id] = @Compass_FeatureId)
EXCEPT
SELECT [CompressionType], [EncryptionPassword], [StorageAccountName], [SharedAccessSignature], [ContainerName], [EndpointSuffix], [EmailAddresses], [LocationType], [SFTP], [SFTPPortNumber], [Path], [UserId], [UserPassword], [PublicKey], [Discriminator], [Name], [System_Id], [IncludeTimestamp], [BundleNameTemplate], [NotificationEmailAddresses], [IncludeInDefault]
FROM @Compass_SystemIntegrationConnection) Diffs

IF EXISTS(SELECT 1 FROM #Compass_SystemIntegrationConnectionDiff)
BEGIN
	PRINT 'Upserting SystemIntegrationConnection Data for ' + @Compass_FeatureDescription

	MERGE INTO [domain].[SystemIntegrationConnection] AS Target
		USING @Compass_SystemIntegrationConnection AS Source ON Target.[System_Id]=Source.[System_Id] AND Target.[Name]=Source.[Name] 
		WHEN MATCHED AND NOT (Target.[CompressionType]=Source.[CompressionType] AND Target.[EncryptionPassword]=Source.[EncryptionPassword] AND Target.[StorageAccountName]=Source.[StorageAccountName] AND Target.[SharedAccessSignature]=Source.[SharedAccessSignature] AND Target.[ContainerName]=Source.[ContainerName] AND Target.[EndpointSuffix]=Source.[EndpointSuffix] AND Target.[EmailAddresses]=Source.[EmailAddresses] AND Target.[LocationType]=Source.[LocationType] AND Target.[SFTP]=Source.[SFTP] AND Target.[SFTPPortNumber]=Source.[SFTPPortNumber] AND Target.[Path]=Source.[Path] AND Target.[UserId]=Source.[UserId] AND Target.[UserPassword]=Source.[UserPassword] AND Target.[PublicKey]=Source.[PublicKey] AND Target.[Discriminator]=Source.[Discriminator] AND Target.[IncludeTimestamp]=Source.[IncludeTimestamp] AND Target.[BundleNameTemplate]=Source.[BundleNameTemplate] AND ISNULL(Target.[NotificationEmailAddresses],'NoEmailSpecified')=ISNULL(Source.[NotificationEmailAddresses],'NoEmailSpecified') AND Target.[IncludeInDefault]=Source.[IncludeInDefault]) THEN
			UPDATE SET Target.[CompressionType]=Source.[CompressionType], Target.[EncryptionPassword]=Source.[EncryptionPassword], Target.[StorageAccountName]=Source.[StorageAccountName], Target.[SharedAccessSignature]=Source.[SharedAccessSignature], Target.[ContainerName]=Source.[ContainerName], Target.[EndpointSuffix]=Source.[EndpointSuffix], Target.[EmailAddresses]=Source.[EmailAddresses], Target.[LocationType]=Source.[LocationType], Target.[SFTP]=Source.[SFTP], Target.[SFTPPortNumber]=Source.[SFTPPortNumber], Target.[Path]=Source.[Path], Target.[UserId]=Source.[UserId], Target.[UserPassword]=Source.[UserPassword], Target.[PublicKey]=Source.[PublicKey], Target.[Discriminator]=Source.[Discriminator], Target.[IncludeTimestamp]=Source.[IncludeTimestamp], Target.[BundleNameTemplate]=Source.[BundleNameTemplate], Target.[NotificationEmailAddresses]=Source.[NotificationEmailAddresses], Target.[IncludeInDefault]=Source.[IncludeInDefault]
		WHEN NOT MATCHED BY TARGET THEN
			INSERT ([CompressionType], [EncryptionPassword], [StorageAccountName], [SharedAccessSignature], [ContainerName], [EndpointSuffix], [EmailAddresses], [LocationType], [SFTP], [SFTPPortNumber], [Path], [UserId], [UserPassword], [PublicKey], [Discriminator], [Name], [System_Id], [IncludeTimestamp], [BundleNameTemplate], [NotificationEmailAddresses], [IncludeInDefault])
			VALUES (Source.[CompressionType], Source.[EncryptionPassword], Source.[StorageAccountName], Source.[SharedAccessSignature], Source.[ContainerName], Source.[EndpointSuffix], Source.[EmailAddresses], Source.[LocationType], Source.[SFTP], Source.[SFTPPortNumber], Source.[Path], Source.[UserId], Source.[UserPassword], Source.[PublicKey], Source.[Discriminator], Source.[Name], Source.[System_Id], Source.[IncludeTimestamp], Source.[BundleNameTemplate], Source.[NotificationEmailAddresses], Source.[IncludeInDefault])
		WHEN NOT MATCHED BY SOURCE AND [System_Id] IN (SELECT [System_Id] FROM domain.FeatureSystem WHERE [Feature_Id] = @Compass_FeatureId) THEN
			DELETE; 
END

DROP TABLE #Compass_SystemIntegrationConnectionDiff
