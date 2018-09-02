DECLARE @Compass_FeatureOutput TABLE (
    [Feature_Id]    INT            NOT NULL,
    [Output_Id]	INT            NOT NULL)

INSERT INTO @Compass_FeatureOutput 
	([Feature_Id], [Output_Id])
SELECT @Compass_FeatureId, [Id]
FROM @Compass_Output

SELECT * INTO #Compass_FeatureOutputDiff FROM (
SELECT [Feature_Id], [Output_Id]
FROM @Compass_FeatureOutput
EXCEPT
SELECT [Feature_Id], [Output_Id]
FROM [domain].[FeatureOutput]) Diffs

INSERT INTO #Compass_FeatureOutputDiff ([Feature_Id], [Output_Id])
SELECT [Feature_Id], [Output_Id]
FROM (
SELECT [Feature_Id], [Output_Id]
FROM [domain].[FeatureOutput]
WHERE [Feature_Id] = @Compass_FeatureId
EXCEPT
SELECT [Feature_Id], [Output_Id]
FROM @Compass_FeatureOutput) Diffs

IF EXISTS(SELECT 1 FROM #Compass_FeatureOutputDiff)
BEGIN
	PRINT 'Upserting FeatureOutput Data for ' + @Compass_FeatureDescription
	
	MERGE INTO [domain].[FeatureOutput] AS Target
		USING @Compass_FeatureOutput AS Source ON Target.[Feature_Id]=Source.[Feature_Id] AND Target.[Output_Id]=Source.[Output_Id] 
		WHEN NOT MATCHED BY TARGET THEN
			INSERT ([Feature_Id], [Output_Id])
			VALUES (Source.[Feature_Id], Source.[Output_Id])
		WHEN NOT MATCHED BY SOURCE AND [Feature_Id] = @Compass_FeatureId THEN
			DELETE;

END
DROP TABLE #Compass_FeatureOutputDiff