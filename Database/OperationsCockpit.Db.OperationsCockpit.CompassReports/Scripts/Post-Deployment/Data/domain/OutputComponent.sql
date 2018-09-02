DECLARE @Compass_OutputComponent TABLE ([Id] [int] NULL,
	[Output_Id] [int] NOT NULL,
	[Path] nvarchar(255) NOT NULL,
	[OutputFileBaseName] [nvarchar](255) NOT NULL)

	INSERT INTO @Compass_OutputComponent 
		([Output_Id], [Path], [OutputFileBaseName]) 
	SELECT [Id], [Path], [OutputFileBaseName]
	FROM (VALUES('Compass Extract', '[cmp].[spPublishEtl]', 'None')) X([OutputName], [Path], [OutputFileBaseName])
	INNER JOIN @Compass_Output fo ON fo.[Name] = X.OutputName

SELECT * INTO #Compass_OutputComponentDiff FROM (
SELECT [Output_Id], [Path], [OutputFileBaseName]
FROM @Compass_OutputComponent
EXCEPT
SELECT [Output_Id], [Path], [OutputFileBaseName]
FROM [domain].[OutputComponent]) Diffs

INSERT INTO #Compass_OutputComponentDiff ([Output_Id], [Path], [OutputFileBaseName])
SELECT [Output_Id], [Path], [OutputFileBaseName] FROM (
SELECT [Output_Id], [Path], [OutputFileBaseName]
FROM [domain].[OutputComponent]
WHERE [Output_Id] IN (SELECT Output_Id FROM domain.FeatureOutput WHERE [Feature_Id] = @Compass_FeatureId)
EXCEPT
SELECT [Output_Id], [Path], [OutputFileBaseName]
FROM @Compass_OutputComponent) Diffs

IF EXISTS(SELECT 1 FROM #Compass_OutputComponentDiff)
BEGIN
	PRINT 'Upserting OutputComponent Data for ' + @Compass_FeatureDescription

	MERGE INTO [domain].[OutputComponent] AS Target
		USING @Compass_OutputComponent AS Source ON Target.[Path]=Source.[Path] AND Target.[Output_Id]=Source.[Output_Id]
		WHEN MATCHED THEN
		UPDATE SET Target.[OutputFileBaseName]=Source.[OutputFileBaseName]
		WHEN NOT MATCHED BY TARGET THEN
		INSERT ([Output_Id], [Path], [OutputFileBaseName])
		VALUES (Source.[Output_Id], Source.[Path], Source.[OutputFileBaseName])
		WHEN NOT MATCHED BY Source AND Output_Id IN (SELECT Output_Id FROM domain.FeatureOutput WHERE [Feature_Id] = @Compass_FeatureId) THEN
		DELETE; 

END
DROP TABLE #Compass_OutputComponentDiff

UPDATE foc
SET Id = oc.[Id]
FROM @Compass_OutputComponent foc
INNER JOIN domain.OutputComponent oc ON foc.Path = oc.Path AND foc.[Output_Id] = oc.[Output_Id]