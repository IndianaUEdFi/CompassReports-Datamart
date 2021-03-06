INSERT INTO [cmp].[SchoolDimension]
           ([SchoolKey]
           ,[NameOfInstitution]
           ,[StreetNumberName]
           ,[BuildingSiteNumber]
           ,[City]
           ,[StateAbbreviation]
           ,[PostalCode]
           ,[NameOfCounty]
           ,[MainInstitutionTelephone]
           ,[InstitutionFax]
           ,[WebSite]
           ,[PrincipalName]
           ,[PrincipalElectronicMailAddress]
           ,[GradeLevels]
           ,[AccreditationStatus]
           ,[LocalEducationAgencyKey]
           ,[LEANameOfInstitution]
           ,[LEAStreetNumberName]
           ,[LEABuildingSiteNumber]
           ,[LEACity]
           ,[LEAStateAbbreviation]
           ,[LEAPostalCode]
           ,[LEANameOfCounty]
           ,[LEAMainInstitutionTelephone]
           ,[LEAInstitutionFax]
           ,[LEAWebSite]
           ,[LEASuperintendentName]
           ,[LEASuperintendentElectronicMailAddress])

SELECT [SchoolId]
           ,[NameOfInstitution]
           ,[StreetNumberName]
           ,[BuildingSiteNumber]
           ,[City]
           ,[StateAbbreviation]
           ,[PostalCode]
           ,[NameOfCounty]
           ,[MainInstitutionTelephone]
           ,[InstitutionFax]
           ,[WebSite]
           ,[PrincipalName]
           ,[PrincipalElectronicMailAddress]
           ,[GradeLevels]
           ,[AccreditationStatus]
           ,[LocalEducationAgencyId]
           ,[LEANameOfInstitution]
           ,[LEAStreetNumberName]
           ,[LEABuildingSiteNumber]
           ,[LEACity]
           ,[LEAStateAbbreviation]
           ,[LEAPostalCode]
           ,[LEANameOfCounty]
           ,[LEAMainInstitutionTelephone]
           ,[LEAInstitutionFax]
           ,[LEAWebSite]
           ,[LEASuperintendentName]
           ,[LEASuperintendentElectronicMailAddress]
FROM [$(OdsDatabaseServer)].[$(OdsDatabaseName)].[cmp].[SchoolDimension]	
