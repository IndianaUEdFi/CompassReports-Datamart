DECLARE @Compass_SystemOutput TABLE (
    [System_Id] [int] NOT NULL,
    [Output_Id] [int] NOT NULL)

INSERT INTO @Compass_SystemOutput
    ([System_Id], [Output_Id])
SELECT S.Id, O.[Id]
FROM @Compass_System S 
CROSS JOIN @Compass_Output O

SELECT * INTO #Compass_SystemOutputDiff FROM (
SELECT [System_Id], [Output_Id]
FROM @Compass_SystemOutput
EXCEPT
SELECT [System_Id], [Output_Id]
FROM [domain].[SystemOutput]) Diffs

--Look for removed records also
INSERT INTO #Compass_SystemOutputDiff
SELECT * FROM (
SELECT [System_Id], [Output_Id]
FROM [domain].[SystemOutput]
WHERE [Output_Id] IN (SELECT [Output_Id] FROM domain.FeatureOutput WHERE [Feature_Id] = @Compass_FeatureId)
EXCEPT
SELECT [System_Id], [Output_Id]
FROM @Compass_SystemOutput) Diffs

IF EXISTS(SELECT 1 FROM #Compass_SystemOutputDiff)
BEGIN
    PRINT 'Upserting SystemOutput Data for ' + @Compass_FeatureDescription

    -- Use Full dataset for add or remove
    MERGE INTO [domain].[SystemOutput] AS Target
    USING @Compass_SystemOutput AS Source ON Target.[System_Id]=Source.[System_Id] AND Target.[Output_Id]=Source.[Output_Id]
    WHEN NOT MATCHED BY TARGET THEN
        INSERT ([System_Id], [Output_Id])
        VALUES (Source.[System_Id], Source.[Output_Id])
    WHEN NOT MATCHED BY SOURCE AND Target.[Output_Id] IN (SELECT [Output_Id] FROM domain.FeatureOutput WHERE [Feature_Id] = @Compass_FeatureId) THEN
        DELETE;
END

DROP TABLE #Compass_SystemOutputDiff
