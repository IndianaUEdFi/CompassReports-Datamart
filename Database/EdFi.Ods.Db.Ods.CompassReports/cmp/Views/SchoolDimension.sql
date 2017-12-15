CREATE VIEW [cmp].[SchoolDimension]
	AS 
	SELECT DISTINCT S.SchoolId
	 , EO.NameOfInstitution
	 , EOA.StreetNumberName
	 , EOA.BuildingSiteNumber
	 , EOA.City
	 , CAST(SAT.ShortDescription AS NVARCHAR(2)) AS [StateAbbreviation]
	 , EOA.PostalCode
	 , EOA.NameOfCounty
	 , EOIT.TelephoneNumber AS [MainInstitutionTelephone]
	 , FEOIT.TelephoneNumber AS [InstitutionFax]
	 , EO.WebSite
	 , CAST(CASE
			WHEN St.PersonalTitlePrefix IS NOT NULL THEN St.PersonalTitlePrefix + '. ' + St.FirstName + ' ' + St.LastSurname 
			ELSE St.FirstName + ' ' + St.LastSurname
		END AS NVARCHAR(182)) AS [PrincipalName]
	 , SEM.ElectronicMailAddress AS [PrincipalElectronicMailAddress]
	 , CAST('Grade Levels ' + SGL.MinGradeLevel + ' - ' + SGL.MaxGradeLevel AS NVARCHAR(10)) AS [GradeLevels]
	 , CAST('State Accredited' AS NVARCHAR(75)) AS [AccreditationStatus] --Placeholder for possible required extension
	 , S.LocalEducationAgencyId --Assuming they use the state identification codes
	 , LEO.NameOfInstitution AS [LEANameOfInstitution]
	 , LEOA.StreetNumberName AS LEAStreetNumberName
	 , LEOA.BuildingSiteNumber AS LEABuildingSiteNumber
	 , LEOA.City AS LEACity
	 , CAST(LSAT.ShortDescription AS NVARCHAR(2)) AS [LEAStateAbbreviation]
	 , LEOA.PostalCode AS LEAPostalCode
	 , LEOA.NameOfCounty AS LEANameOfCounty
	 , LEOIT.TelephoneNumber AS [LEAMainInstitutionTelephone]
	 , LFEOIT.TelephoneNumber AS [LEAInstitutionFax]
	 , LEO.WebSite AS LEAWebSite
	 , CAST(CASE
			WHEN LST.PersonalTitlePrefix IS NOT NULL THEN LST.PersonalTitlePrefix + '. ' + LST.FirstName + ' ' + LST.LastSurname 
			ELSE LST.FirstName + ' ' + LST.LastSurname
		END AS NVARCHAR(182)) AS [LEASuperintendentName]
	 , LSEM.ElectronicMailAddress AS [LEASuperintendentElectronicMailAddress]
FROM edfi.School S
LEFT JOIN edfi.EducationOrganization EO 
	ON EO.EducationOrganizationId = S.SchoolId
LEFT JOIN edfi.EducationOrganizationAddress EOA 
	ON EOA.EducationOrganizationId = EO.EducationOrganizationId
LEFT JOIN edfi.StateAbbreviationType SAT 
	ON SAT.StateAbbreviationTypeId = EOA.StateAbbreviationTypeId
LEFT JOIN edfi.AddressType AT 
	ON EOA.AddressTypeId = AT.AddressTypeId
LEFT JOIN edfi.EducationOrganizationInstitutionTelephone EOIT 
	ON EOIT.EducationOrganizationId = EO.EducationOrganizationId
LEFT JOIN edfi.InstitutionTelephoneNumberType ITNT 
	ON ITNT.InstitutionTelephoneNumberTypeId = EOIT.InstitutionTelephoneNumberTypeId
LEFT JOIN edfi.EducationOrganizationInstitutionTelephone FEOIT	
	ON FEOIT.EducationOrganizationId = EO.EducationOrganizationId
LEFT JOIN edfi.InstitutionTelephoneNumberType FITNT 
	ON FITNT.InstitutionTelephoneNumberTypeId = FEOIT.InstitutionTelephoneNumberTypeId
LEFT JOIN edfi.StaffEducationOrganizationAssignmentAssociation SEOA 
	ON SEOA.EducationOrganizationId = EO.EducationOrganizationId
LEFT JOIN edfi.StaffClassificationDescriptor SCD 
	ON SCD.StaffClassificationDescriptorId = SEOA.StaffClassificationDescriptorId
LEFT JOIN edfi.StaffClassificationType SCT 
	ON SCD.StaffClassificationTypeId = SCT.StaffClassificationTypeId
LEFT JOIN edfi.Staff St 
	ON St.StaffUSI = SEOA.StaffUSI
LEFT JOIN edfi.StaffElectronicMail SEM 
	ON SEM.StaffUSI = SEOA.StaffUSI
LEFT JOIN edfi.ElectronicMailType EMT 
	ON EMT.ElectronicMailTypeId = SEM.ElectronicMailTypeId
LEFT JOIN (
			SELECT S.SchoolId
		 , CASE
			WHEN MIN(S.GradeLevelCode) = -1 THEN 'PK'
			WHEN MIN(S.GradeLevelCode) = 0 THEN 'K'
			WHEN MIN(S.GradeLevelCode) <= 9 THEN '0'+ CAST(MIN(GradeLevelCode) AS nvarchar)
			ELSE CAST(MIN(GradeLevelCode) AS nvarchar)
		   END AS [MinGradeLevel]
		 , CASE
			WHEN MAX(S.GradeLevelCode) = -1 THEN 'PK'
			WHEN MAX(S.GradeLevelCode) = 0 THEN 'K'
			WHEN MAX(S.GradeLevelCode) < 9 THEN '0'+ CAST(MAX(GradeLevelCode) AS nvarchar)
			ELSE CAST(MAX(GradeLevelCode) AS nvarchar)
		   END AS [MaxGradeLevel]
	FROM (
		SELECT SGL.SchoolId
			 ,GLT.CodeValue
			 		 ,CASE
				WHEN GLT.CodeValue = 'Preschool/Prekindergarten' THEN -1
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
				ELSE 13
			   END AS [GradeLevelCode]
		FROM edfi.SchoolGradeLevel SGL
		JOIN edfi.GradeLevelDescriptor GLD ON GLD.GradeLevelDescriptorId = SGL.GradeLevelDescriptorId
		JOIN edfi.GradeLevelType GLT ON GLT.GradeLevelTypeId = GLD.GradeLevelTypeId
			) S
	GROUP BY S.SchoolId
	) SGL 
		ON SGL.SchoolId = S.SchoolId
LEFT JOIN edfi.LocalEducationAgency LEA 
	ON LEA.LocalEducationAgencyId = S.LocalEducationAgencyId
LEFT JOIN edfi.EducationOrganization LEO 
	ON LEO.EducationOrganizationId = LEA.LocalEducationAgencyId
LEFT JOIN edfi.EducationOrganizationAddress LEOA 
	ON LEOA.EducationOrganizationId = LEO.EducationOrganizationId
LEFT JOIN edfi.StateAbbreviationType LSAT 
	ON LSAT.StateAbbreviationTypeId = LEOA.StateAbbreviationTypeId
LEFT JOIN edfi.AddressType LAT 
	ON LEOA.AddressTypeId = LAT.AddressTypeId
LEFT JOIN edfi.EducationOrganizationInstitutionTelephone LEOIT 
	ON LEOIT.EducationOrganizationId = LEO.EducationOrganizationId
LEFT JOIN edfi.InstitutionTelephoneNumberType LITNT 
	ON LITNT.InstitutionTelephoneNumberTypeId = LEOIT.InstitutionTelephoneNumberTypeId
LEFT JOIN edfi.EducationOrganizationInstitutionTelephone LFEOIT	
	ON LFEOIT.EducationOrganizationId = LEO.EducationOrganizationId
LEFT JOIN edfi.InstitutionTelephoneNumberType LFITNT 
	ON LFITNT.InstitutionTelephoneNumberTypeId = LFEOIT.InstitutionTelephoneNumberTypeId
LEFT JOIN edfi.StaffEducationOrganizationAssignmentAssociation LSEOA 
	ON LSEOA.EducationOrganizationId = LEO.EducationOrganizationId
LEFT JOIN edfi.StaffClassificationDescriptor LSCD 
	ON LSCD.StaffClassificationDescriptorId = LSEOA.StaffClassificationDescriptorId
LEFT JOIN edfi.StaffClassificationType LSCT 
	ON LSCD.StaffClassificationTypeId = LSCT.StaffClassificationTypeId
LEFT JOIN edfi.Staff LST 
	ON LST.StaffUSI = LSEOA.StaffUSI
LEFT JOIN edfi.StaffElectronicMail LSEM 
	ON LSEM.StaffUSI = LSEOA.StaffUSI
LEFT JOIN edfi.ElectronicMailType LEMT 
	ON LEMT.ElectronicMailTypeId = LSEM.ElectronicMailTypeId
WHERE  ITNT.ShortDescription = 'Main'
AND FITNT.ShortDescription = 'Fax'
AND SCT.ShortDescription = 'Principal'
AND AT.ShortDescription = 'Physical'
AND LITNT.ShortDescription = 'Main'
AND LFITNT.ShortDescription = 'Fax'
AND LSCT.ShortDescription = 'Superintendent'
AND LAT.ShortDescription = 'Physical'
AND EMT.ShortDescription IN ('Work','Organization')
AND LEMT.ShortDescription IN ('Work','Organization')
