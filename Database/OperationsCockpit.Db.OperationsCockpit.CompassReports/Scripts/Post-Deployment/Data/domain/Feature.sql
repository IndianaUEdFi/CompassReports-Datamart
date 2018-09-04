DECLARE @Compass_FeatureDescription nvarchar(255) = 'Compass'
DECLARE @Compass_FeatureId int

IF NOT EXISTS(SELECT 1 FROM [domain].[Feature] WHERE [Description] = @Compass_FeatureDescription)
BEGIN
	PRINT 'Inserting Feature Data for ' + @Compass_FeatureDescription

	INSERT INTO [domain].[Feature] ([Description], [CreatedBy], [CreatedDate])
	VALUES (@Compass_FeatureDescription, 'Deployment', GETDATE())
END

SET @Compass_FeatureId = (SELECT ID FROM [domain].[Feature] WHERE [Description] = @Compass_FeatureDescription)
