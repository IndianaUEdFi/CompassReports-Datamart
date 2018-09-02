DECLARE @Compass_FeatureSystem TABLE (
    [Feature_Id]    INT            NOT NULL,
    [System_Id]	INT            NOT NULL)

INSERT INTO @Compass_FeatureSystem
    ([Feature_Id], [System_Id])
SELECT @Compass_FeatureId, [ID]
FROM @Compass_System

SELECT * INTO #Compass_FeatureSystemDiff FROM (
SELECT [Feature_Id], [System_Id]
FROM @Compass_FeatureSystem
EXCEPT
SELECT [Feature_Id], [System_Id]
FROM [domain].[FeatureSystem]) Diffs

INSERT INTO #Compass_FeatureSystemDiff ([Feature_Id], [System_Id])
SELECT [Feature_Id], [System_Id]
FROM (
SELECT [Feature_Id], [System_Id]
FROM [domain].[FeatureSystem]
WHERE [Feature_Id] = @Compass_FeatureId
EXCEPT
SELECT [Feature_Id], [System_Id]
FROM @Compass_FeatureSystem) Diffs

IF EXISTS(SELECT 1 FROM #Compass_FeatureSystemDiff)
BEGIN
	PRINT 'Upserting FeatureSystem Data for ' + @Compass_FeatureDescription

	MERGE INTO [domain].[FeatureSystem] AS Target
		USING @Compass_FeatureSystem AS Source ON Target.[Feature_Id]=Source.[Feature_Id] AND Target.[System_Id]=Source.[System_Id]
		WHEN NOT MATCHED BY TARGET THEN
			INSERT ([Feature_Id], [System_Id])
			VALUES (Source.[Feature_Id], Source.[System_Id])
		WHEN NOT MATCHED BY SOURCE AND Target.[Feature_Id] = @Compass_FeatureId THEN
			DELETE;

END
DROP TABLE #Compass_FeatureSystemDiff