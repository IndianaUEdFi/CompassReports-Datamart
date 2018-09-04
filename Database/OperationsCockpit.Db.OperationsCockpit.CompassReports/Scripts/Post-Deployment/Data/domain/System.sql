DECLARE @Compass_System TABLE ([Id] int NULL,
	[SystemCode] [nvarchar](25) NOT NULL,
	[Name] [nvarchar](127) NOT NULL,
	[Version] int NOT NULL,
	[SystemTypeCode] nvarchar(25) NOT NULL,
	[VendorCode] nvarchar(25) NOT NULL,
	[ClaimSetName] nvarchar(255) NOT NULL,
	[SystemType_Id] int NULL,
	[Vendor_Id] int NULL)

INSERT INTO @Compass_System
		([SystemCode], [Name], [Version], [SystemTypeCode], [VendorCode], [ClaimSetName] )
VALUES (N'Compass', N'Compass', 1, N'EXTERNAL', N'IN', N'SIS Vendor')

UPDATE s
SET [SystemType_Id] = st.[Id]
FROM @Compass_System s
INNER JOIN [domain].[SystemType] st on s.[SystemTypeCode] = st.[SystemTypeCode]

UPDATE s 
SET [Vendor_Id] = v.[Id]
FROM @Compass_System s
INNER JOIN [domain].[Vendor] v on s.[VendorCode] = v.[VendorCode]


SELECT * INTO #Compass_SystemDiff FROM (
SELECT [SystemCode], [Name], [Version], [SystemType_Id], [Vendor_Id], [ClaimSetName]
FROM @Compass_System
EXCEPT
SELECT [SystemCode], [Name], [Version], [SystemType_Id], [Vendor_Id], [ClaimSetName]
FROM [domain].[System]) Diffs

INSERT INTO #Compass_SystemDiff SELECT * FROM (
SELECT [SystemCode], [Name], [Version], [SystemType_Id], [Vendor_Id], [ClaimSetName]
FROM [domain].[System]
WHERE [Id] IN (SELECT [System_Id] FROM domain.FeatureSystem WHERE [Feature_Id] = @Compass_FeatureId)
EXCEPT
SELECT [SystemCode], [Name], [Version], [SystemType_Id], [Vendor_Id], [ClaimSetName]
FROM @Compass_System
) Diffs

IF EXISTS(SELECT 1 FROM #Compass_SystemDiff)
BEGIN
	PRINT 'Upserting System Data for ' + @Compass_FeatureDescription

	MERGE INTO [domain].[System] AS Target
		USING @Compass_System AS Source ON Target.[SystemCode]=Source.[SystemCode]
		WHEN MATCHED THEN
			UPDATE SET Target.[Name]=Source.[Name], Target.[Version]=Source.[Version], Target.[SystemType_Id]=Source.[SystemType_Id], Target.[Vendor_Id]=Source.[Vendor_Id], Target.[ClaimSetName]=Source.[ClaimSetName]
		WHEN NOT MATCHED BY TARGET THEN
			INSERT ([SystemCode], [Name], [Version], [SystemType_Id], [Vendor_Id], [ClaimSetName])
			VALUES (Source.[SystemCode], Source.[Name], Source.[Version], Source.[SystemType_Id], Source.[Vendor_Id], Source.[ClaimSetName])
		WHEN NOT MATCHED BY SOURCE AND [Id] IN (SELECT [System_Id] FROM domain.FeatureSystem WHERE [Feature_Id] = @Compass_FeatureId) THEN
			DELETE;

END
DROP TABLE #Compass_SystemDiff

UPDATE fs
SET [Id] = dS.[Id]
FROM @Compass_System fs
INNER JOIN [domain].[System] dS on fs.[SystemCode] = dS.[SystemCode]