DECLARE @Compass_OutputFormatOutput TABLE ([Output_Id] [int] NOT NULL,
	[OutputFormat_Id] [int])

INSERT INTO @Compass_OutputFormatOutput
	([Output_Id],[OutputFormat_Id])
SELECT [Id], 2
FROM @Compass_Output

SELECT * INTO #Compass_OutputFormatOutputDiff FROM (
SELECT [Output_Id],[OutputFormat_Id]
FROM @Compass_OutputFormatOutput
EXCEPT
SELECT [Output_Id],[OutputFormat_Id]
FROM [domain].[OutputFormatOutput]) Diffs

INSERT INTO #Compass_OutputFormatOutputDiff ([Output_Id],[OutputFormat_Id])
SELECT [Output_Id],[OutputFormat_Id] FROM (
SELECT [Output_Id],[OutputFormat_Id]
FROM [domain].[OutputFormatOutput]
WHERE [Output_Id] IN (SELECT Output_Id FROM domain.FeatureOutput WHERE [Feature_Id] = @Compass_FeatureId)
EXCEPT
SELECT [Output_Id],[OutputFormat_Id]
FROM @Compass_OutputFormatOutput) Diffs

IF EXISTS(SELECT 1 FROM #Compass_OutputFormatOutputDiff)
BEGIN
	PRINT 'Upserting OutputFormatOutput Data for ' + @Compass_FeatureDescription

	MERGE INTO [domain].[OutputFormatOutput] AS Target
		USING @Compass_OutputFormatOutput AS Source ON Target.[Output_Id]=Source.[Output_Id] AND Target.[OutputFormat_Id]=Source.[OutputFormat_Id]
		WHEN NOT MATCHED BY TARGET THEN
		INSERT ([Output_Id],[OutputFormat_Id])
		VALUES (Source.[Output_Id], Source.[OutputFormat_Id])
		WHEN NOT MATCHED BY SOURCE AND Target.[Output_Id] IN (SELECT Output_Id FROM domain.FeatureOutput WHERE [Feature_Id] = @Compass_FeatureId) THEN
		DELETE;

END
DROP TABLE #Compass_OutputFormatOutputDiff