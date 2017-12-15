CREATE VIEW [cmp].[SchoolYearDimension]
	AS SELECT [SchoolYear]
      ,SUBSTRING([SchoolYearDescription], 1,5) + SUBSTRING([SchoolYearDescription], 8,9) AS [SchoolYearDescription]
FROM [edfi].[SchoolYearType]
WHERE [SchoolYear] >= (SELECT [SchoolYear] FROM [edfi].[SchoolYearType] WHERE [CurrentSchoolYear] = 1)