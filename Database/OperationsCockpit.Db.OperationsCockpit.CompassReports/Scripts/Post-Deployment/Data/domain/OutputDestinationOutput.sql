DECLARE @Compass_OutputDestinationOutput TABLE ([Output_Id] [int] NOT NULL,
	[OutputDestination_Id] [int])

INSERT INTO @Compass_OutputDestinationOutput
	([Output_Id],[OutputDestination_Id])
SELECT [Id], 5
FROM @Compass_Output

SELECT * INTO #Compass_OutputDestinationOutputDiff FROM (
SELECT [Output_Id],[OutputDestination_Id]
FROM @Compass_OutputDestinationOutput
EXCEPT
SELECT [Output_Id],[OutputDestination_Id]
FROM [domain].[OutputDestinationOutput]) Diffs

INSERT INTO #Compass_OutputDestinationOutputDiff ([Output_Id],[OutputDestination_Id])
SELECT [Output_Id],[OutputDestination_Id] FROM (
SELECT [Output_Id],[OutputDestination_Id]
FROM [domain].[OutputDestinationOutput]
WHERE [Output_Id] IN (SELECT Output_Id FROM domain.FeatureOutput WHERE [Feature_Id] = @Compass_FeatureId)
EXCEPT
SELECT [Output_Id],[OutputDestination_Id]
FROM @Compass_OutputDestinationOutput) Diffs

IF EXISTS(SELECT 1 FROM #Compass_OutputDestinationOutputDiff)
BEGIN
	PRINT 'Upserting OutputDestinationOutput Data for ' + @Compass_FeatureDescription

	MERGE INTO [domain].[OutputDestinationOutput] AS Target
		USING @Compass_OutputDestinationOutput AS Source ON Target.[Output_Id]=Source.[Output_Id] AND Target.[OutputDestination_Id]=Source.[OutputDestination_Id]
		WHEN NOT MATCHED BY TARGET THEN
		INSERT ([Output_Id],[OutputDestination_Id])
		VALUES (Source.[Output_Id], Source.[OutputDestination_Id])
		WHEN NOT MATCHED BY SOURCE AND Target.[Output_Id] IN (SELECT Output_Id FROM domain.FeatureOutput WHERE [Feature_Id] = @Compass_FeatureId) THEN
		DELETE;

END
DROP TABLE #Compass_OutputDestinationOutputDiff