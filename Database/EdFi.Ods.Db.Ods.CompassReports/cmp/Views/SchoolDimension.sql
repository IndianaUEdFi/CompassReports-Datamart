CREATE VIEW [cmp].[SchoolDimension]
	AS 
	SELECT DISTINCT S.SchoolId
	 , EO.NameOfInstitution
	 , EOA.StreetNumberName
	 , EOA.BuildingSiteNumber
	 , EOA.City
	 , CAST(SAT.ShortDescription AS NVARCHAR(2)) AS [StateAbbreviation]
	 , EOA.PostalCode
	 , ISNULL(EOA.NameOfCounty,'Not Supplied') AS NameOfCounty
	 , ISNULL(EOIT.TelephoneNumber, '(000) 000-0000') AS [MainInstitutionTelephone]
	 , ISNULL(FEOIT.TelephoneNumber, '(000) 000-0000') AS [InstitutionFax]
	 , ISNULL(EO.WebSite, 'Not Supplied') AS WebSite
	 , ISNULL(CAST(CASE
			WHEN St.PersonalTitlePrefix IS NOT NULL THEN St.PersonalTitlePrefix + '. ' + St.FirstName + ' ' + St.LastSurname 
			ELSE St.FirstName + ' ' + St.LastSurname
		END AS NVARCHAR(182)), 'Not Supplied') AS [PrincipalName]
	 , ISNULL(SEM.ElectronicMailAddress, 'Not Supplied') AS [PrincipalElectronicMailAddress]
	 , CAST('Grade Levels ' + SGL.MinGradeLevel + ' - ' + SGL.MaxGradeLevel AS NVARCHAR(10)) AS [GradeLevels]
	 , CAST('State Accredited' AS NVARCHAR(75)) AS [AccreditationStatus] --Placeholder for possible required extension
	 , S.LocalEducationAgencyId --Assuming they use the state identification codes
	 , LEO.NameOfInstitution AS [LEANameOfInstitution]
	 , LEOA.StreetNumberName AS LEAStreetNumberName
	 , LEOA.BuildingSiteNumber AS LEABuildingSiteNumber
	 , LEOA.City AS LEACity
	 , CAST(LSAT.ShortDescription AS NVARCHAR(2)) AS [LEAStateAbbreviation]
	 , LEOA.PostalCode AS LEAPostalCode
	 , ISNULL(LEOA.NameOfCounty, 'Not Supplied') AS LEANameOfCounty
	 , ISNULL(LEOIT.TelephoneNumber, '(000) 000-0000') AS [LEAMainInstitutionTelephone]
	 , ISNULL(LFEOIT.TelephoneNumber, '(000) 000-0000') AS [LEAInstitutionFax]
	 , ISNULL(LEO.WebSite, 'Not Supplied') AS LEAWebSite
	 , ISNULL(CAST(CASE
			WHEN LST.PersonalTitlePrefix IS NOT NULL THEN LST.PersonalTitlePrefix + '. ' + LST.FirstName + ' ' + LST.LastSurname 
			ELSE LST.FirstName + ' ' + LST.LastSurname
		END AS NVARCHAR(182)), 'Not Supplied') AS [LEASuperintendentName]
	 , ISNULL(LSEM.ElectronicMailAddress, 'Not Supplied') AS [LEASuperintendentElectronicMailAddress]
FROM edfi.School AS S 
LEFT OUTER JOIN edfi.EducationOrganization AS EO ON EO.EducationOrganizationId = S.SchoolId 
LEFT OUTER JOIN (SELECT EOA1.* FROM edfi.EducationOrganizationAddress EOA1
	LEFT OUTER JOIN edfi.AddressType AS AT ON EOA1.AddressTypeId = AT.AddressTypeId
	WHERE AT.ShortDescription = 'Physical') AS EOA ON EOA.EducationOrganizationId = EO.EducationOrganizationId 
LEFT OUTER JOIN edfi.StateAbbreviationType AS SAT ON SAT.StateAbbreviationTypeId = EOA.StateAbbreviationTypeId 
LEFT OUTER JOIN (SELECT * FROM edfi.EducationOrganizationInstitutionTelephone WHERE InstitutionTelephoneNumberTypeId = (SELECT InstitutionTelephoneNumberTypeId FROM edfi.InstitutionTelephoneNumberType WHERE ShortDescription = 'Main')) AS EOIT ON EOIT.EducationOrganizationId = EO.EducationOrganizationId
LEFT OUTER JOIN (SELECT * FROM edfi.EducationOrganizationInstitutionTelephone WHERE InstitutionTelephoneNumberTypeId = (SELECT InstitutionTelephoneNumberTypeId FROM edfi.InstitutionTelephoneNumberType WHERE ShortDescription = 'Fax')) AS FEOIT ON FEOIT.EducationOrganizationId = EO.EducationOrganizationId
LEFT OUTER JOIN (SELECT SEOA1.* FROM edfi.StaffEducationOrganizationAssignmentAssociation SEOA1 
	LEFT OUTER JOIN edfi.StaffClassificationDescriptor AS SCD ON SCD.StaffClassificationDescriptorId = SEOA1.StaffClassificationDescriptorId 
	LEFT OUTER JOIN edfi.StaffClassificationType AS SCT ON SCD.StaffClassificationTypeId = SCT.StaffClassificationTypeId 
	WHERE SCT.ShortDescription = 'Principal')AS SEOA ON SEOA.EducationOrganizationId = EO.EducationOrganizationId 
LEFT OUTER JOIN edfi.Staff AS St ON St.StaffUSI = SEOA.StaffUSI 
LEFT OUTER JOIN (SELECT SEM1.* FROM edfi.StaffElectronicMail SEM1
	LEFT OUTER JOIN edfi.ElectronicMailType AS EMT ON EMT.ElectronicMailTypeId = SEM1.ElectronicMailTypeId
	WHERE EMT.ShortDescription IN ('Work', 'Organization')) AS SEM ON SEM.StaffUSI = SEOA.StaffUSI
LEFT OUTER JOIN (SELECT SchoolId
		, CASE WHEN MIN(S.GradeLevelCode) = - 1 THEN 'PK' 
			WHEN MIN(S.GradeLevelCode) = 0 THEN 'K' 
			WHEN MIN(S.GradeLevelCode) <= 9 THEN '0' + CAST(MIN(GradeLevelCode) AS nvarchar) 
			ELSE CAST(MIN(GradeLevelCode) AS nvarchar) END AS MinGradeLevel
		, CASE WHEN MAX(S.GradeLevelCode) = - 1 THEN 'PK' 
			WHEN MAX(S.GradeLevelCode) = 0 THEN 'K' 
			WHEN MAX(S.GradeLevelCode) < 9 THEN '0' + CAST(MAX(GradeLevelCode) AS nvarchar) 
			ELSE CAST(MAX(GradeLevelCode) AS nvarchar) END AS MaxGradeLevel
	FROM (SELECT SGL.SchoolId
			, GLT.CodeValue
			, CASE WHEN GLT.CodeValue = 'Preschool/Prekindergarten' THEN - 1 
				WHEN GLT.CodeValue = 'Kindergarten' THEN 0 
				WHEN GLT.CodeValue = 'First grade' THEN 1 
				WHEN GLT.CodeValue = 'Second grade' THEN 2 
				WHEN GLT.CodeValue = 'Third grade' THEN 3 
				WHEN GLT.CodeValue = 'Fourth grade' THEN 4 
				WHEN GLT.CodeValue = 'Fifth grade' THEN 5 
				WHEN GLT.CodeValue = 'Sixth grade' THEN 6 
				WHEN GLT.CodeValue = 'Seventh grade' THEN 7 
				WHEN GLT.CodeValue = 'Eighth grade' THEN 8 
				WHEN GLT.CodeValue = 'Ninth grade' THEN 9 
				WHEN GLT.CodeValue = 'Tenth grade' THEN 10 
				WHEN GLT.CodeValue = 'Eleventh grade' THEN 11 
				WHEN GLT.CodeValue = 'Twelfth grade' THEN 12 
				ELSE 13 END AS GradeLevelCode
			FROM edfi.SchoolGradeLevel AS SGL 
			INNER JOIN edfi.GradeLevelDescriptor AS GLD ON GLD.GradeLevelDescriptorId = SGL.GradeLevelDescriptorId 
			INNER JOIN edfi.GradeLevelType AS GLT ON GLT.GradeLevelTypeId = GLD.GradeLevelTypeId) AS S
    GROUP BY SchoolId) AS SGL ON SGL.SchoolId = S.SchoolId 
LEFT OUTER JOIN edfi.LocalEducationAgency AS LEA ON LEA.LocalEducationAgencyId = S.LocalEducationAgencyId 
LEFT OUTER JOIN edfi.EducationOrganization AS LEO ON LEO.EducationOrganizationId = LEA.LocalEducationAgencyId 
LEFT OUTER JOIN (SELECT LEOA1.* FROM edfi.EducationOrganizationAddress LEOA1
	LEFT OUTER JOIN edfi.AddressType AS LAT ON LEOA1.AddressTypeId = LAT.AddressTypeId
	WHERE LAT.ShortDescription = 'Physical') AS LEOA ON LEOA.EducationOrganizationId = LEO.EducationOrganizationId
LEFT OUTER JOIN edfi.StateAbbreviationType AS LSAT ON LSAT.StateAbbreviationTypeId = LEOA.StateAbbreviationTypeId 
LEFT OUTER JOIN (SELECT * FROM edfi.EducationOrganizationInstitutionTelephone WHERE InstitutionTelephoneNumberTypeId = (SELECT InstitutionTelephoneNumberTypeId FROM edfi.InstitutionTelephoneNumberType WHERE ShortDescription = 'Main')) AS LEOIT ON LEOIT.EducationOrganizationId = LEO.EducationOrganizationId
LEFT OUTER JOIN (SELECT * FROM edfi.EducationOrganizationInstitutionTelephone WHERE InstitutionTelephoneNumberTypeId = (SELECT InstitutionTelephoneNumberTypeId FROM edfi.InstitutionTelephoneNumberType WHERE ShortDescription = 'Fax')) AS LFEOIT ON LFEOIT.EducationOrganizationId = LEO.EducationOrganizationId
LEFT OUTER JOIN (SELECT SEOA1.* FROM edfi.StaffEducationOrganizationAssignmentAssociation SEOA1 
	LEFT OUTER JOIN edfi.StaffClassificationDescriptor AS SCD ON SCD.StaffClassificationDescriptorId = SEOA1.StaffClassificationDescriptorId 
	LEFT OUTER JOIN edfi.StaffClassificationType AS SCT ON SCD.StaffClassificationTypeId = SCT.StaffClassificationTypeId 
	WHERE SCT.ShortDescription = 'Superintendent')AS LSEOA ON LSEOA.EducationOrganizationId = LEO.EducationOrganizationId 
LEFT OUTER JOIN edfi.Staff AS LST ON LST.StaffUSI = LSEOA.StaffUSI 
LEFT OUTER JOIN (SELECT SEM1.* FROM edfi.StaffElectronicMail SEM1
	LEFT OUTER JOIN edfi.ElectronicMailType AS EMT ON EMT.ElectronicMailTypeId = SEM1.ElectronicMailTypeId
	WHERE EMT.ShortDescription IN ('Work', 'Organization')) AS LSEM ON LSEM.StaffUSI = LSEOA.StaffUSI
