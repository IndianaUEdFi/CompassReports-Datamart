DECLARE @Compass_Output TABLE ([Id] [int] NULL,
	[Name] [nvarchar](max) NULL,
	Discriminator [nvarchar](128) NOT NULL,
	BundleNameTemplate [nvarchar](255) NULL)

	INSERT INTO @Compass_Output
		(Name, Discriminator, BundleNameTemplate)
	VALUES ('Compass Extract', 'ExtractorOutput', '<IntegrationName>')

SELECT * INTO #Compass_OutputDiff FROM (
SELECT [Name], [Discriminator], [BundleNameTemplate]
FROM @Compass_Output
EXCEPT
SELECT [Name], [Discriminator], [BundleNameTemplate]
FROM [domain].[Output]) Diffs

INSERT INTO #Compass_OutputDiff
SELECT * FROM (
SELECT [Name], [Discriminator], [BundleNameTemplate]
FROM [domain].[Output]
WHERE [ID] IN (SELECT [Output_Id] FROM [domain].[FeatureOutput] WHERE [Feature_Id] = @Compass_FeatureId)
EXCEPT
SELECT [Name], [Discriminator], [BundleNameTemplate]
FROM @Compass_Output) Diffs

IF EXISTS(SELECT 1 FROM #Compass_OutputDiff)
BEGIN
	PRINT 'Upserting Output Data for ' + @Compass_FeatureDescription

	MERGE INTO [domain].[Output] AS Target
		USING @Compass_Output AS Source ON Target.[Name]=Source.[Name]
		WHEN MATCHED THEN
			UPDATE SET Target.[Discriminator]=Source.[Discriminator], Target.[BundleNameTemplate]=Source.[BundleNameTemplate]
		WHEN NOT MATCHED BY TARGET THEN
			INSERT ([Name], [Discriminator], [BundleNameTemplate])
			VALUES (Source.[Name], Source.[Discriminator], Source.[BundleNameTemplate])
		WHEN NOT MATCHED BY SOURCE AND Target.[ID] IN (SELECT [Output_Id] FROM [domain].[FeatureOutput] WHERE [Feature_Id] = @Compass_FeatureId) THEN
			DELETE;

END
DROP TABLE #Compass_OutputDiff

UPDATE fo
SET [Id] = dO.[Id]
FROM @Compass_Output fo
INNER JOIN [domain].[Output] dO on fo.Name = dO.Name
