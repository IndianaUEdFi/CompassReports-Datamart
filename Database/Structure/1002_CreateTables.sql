CREATE TABLE cmp.DemographicJunkDimension (
    DemographicKey INT IDENTITY(1,1) NOT NULL,
	GradeLevel NVARCHAR(50) NOT NULL,
	GradeLevelSort NVARCHAR(10) NOT NULL,
	Ethnicity NVARCHAR(50) NOT NULL,
	FreeReducedLunchStatus NVARCHAR(50) NOT NULL,
	SpecialEducationStatus NVARCHAR(50) NOT NULL,
	EnglishLanguageLearnerStatus NVARCHAR(50) NOT NULL,
	ExpectedGraduationYear SMALLINT,
	CONSTRAINT PK_DemographicJunkDimension PRIMARY KEY ([DemographicKey]) 
	)

CREATE TABLE cmp.SchoolDimension (
	SchoolKey INT NOT NULL,
	NameOfInstitution NVARCHAR(75)NOT NULL ,
	StreetNumberName NVARCHAR(150) NOT NULL,
	BuildingSiteNumber NVARCHAR(20) NULL,
	City NVARCHAR(30) NOT NULL,
	StateAbbreviation NVARCHAR(2) NOT NULL,
	PostalCode NVARCHAR(17) NOT NULL,
	NameOfCounty NVARCHAR(30) NOT NULL,
	MainInstitutionTelephone NVARCHAR(24) NOT NULL,
	InstitutionFax NVARCHAR(24) NOT NULL,
	WebSite NVARCHAR(255) NOT NULL,
	PrincipalName NVARCHAR(182) NOT NULL,
	PrincipalElectronicMailAddress NVARCHAR(128) NOT NULL,
	GradeLevels NVARCHAR(10) NOT NULL,
	AccreditationStatus NVARCHAR(75),
	LocalEducationAgencyKey INT NOT NULL,
	LEANameOfInstitution NVARCHAR(75) NOT NULL,
	LEAStreetNumberName NVARCHAR(150) NOT NULL,
	LEABuildingSiteNumber NVARCHAR(20) NULL,
	LEACity NVARCHAR(30)NOT NULL ,
	LEAStateAbbreviation NVARCHAR(2) NOT NULL,
	LEAPostalCode NVARCHAR(17) NOT NULL,
	LEANameOfCounty NVARCHAR(30) NOT NULL,
	LEAMainInstitutionTelephone NVARCHAR(24) NOT NULL,
	LEAInstitutionFax NVARCHAR(24) NOT NULL,
	LEAWebSite NVARCHAR(255) NOT NULL,
	LEASuperintendentName NVARCHAR(182) NOT NULL,
	LEASuperintendentElectronicMailAddress NVARCHAR(128) NOT NULL,
	CONSTRAINT PK_SchoolDimension PRIMARY KEY (SchoolKey) 
	)

CREATE TABLE cmp.GoodCauseExemptionJunkDimension (
	GoodCauseExemptionKey INT IDENTITY(1,1) NOT NULL,
	GoodCauseExemption NVARCHAR(50) NOT NULL,
	CONSTRAINT PK_GoodCauseExemptionJunkDimension PRIMARY KEY (GoodCauseExemptionKey)
	)

CREATE TABLE cmp.AssessmentDimension (
	AssessmentKey INT IDENTITY(1,1) NOT NULL,
	AssessmentTitle NVARCHAR(60) NOT NULL,
	AssessedGradeLevel NVARCHAR(50) NOT NULL,
	AcademicSubject NVARCHAR(50) NOT NULL,
	MaxScore INT, 
	CONSTRAINT PK_AssessmentDimension PRIMARY KEY (AssessmentKey)
	)

CREATE TABLE cmp.PerformanceDimension (
	PerformanceKey INT IDENTITY (1,1) NOT NULL,
	PerformanceLevel NVARCHAR(50) NOT NULL,
	ScoreResult INT, 
	CONSTRAINT PK_PerformanceDimension PRIMARY KEY (PerformanceKey)
	)

CREATE TABLE cmp.SchoolYearDimension (
	SchoolYearKey SMALLINT NOT NULL,
	SchoolYearDescription NVARCHAR(50) NOT NULL,
	CONSTRAINT PK_SchoolYearDimension PRIMARY KEY (SchoolYearKey)
	)

CREATE TABLE cmp.GraduationStatusJunkDimension (
	GraduationStatusKey INT IDENTITY(1,1) NOT NULL,
	GraduationStatus NVARCHAR(50) NOT NULL,
	DiplomaType NVARCHAR(15) NOT NULL,
	GraduationWaiver NVARCHAR(15) NULL,
	CONSTRAINT PK_GraduationStatusJunkDimension PRIMARY KEY (GraduationStatusKey)
	)

CREATE TABLE cmp.AssessmentFact (
	DemographicKey INT NOT NULL,
	SchoolKey INT NOT NULL,
	SchoolYearKey SMALLINT NOT NULL,
	AssessmentKey INT NOT NULL,
	PerformanceKey INT NOT NULL,
	GoodCauseExemptionKey INT NOT NULL,
	AssessmentStudentCount INT NOT NULL,
	CONSTRAINT PK_AssessmentFact PRIMARY KEY ([DemographicKey], [SchoolKey], [SchoolYearKey],[AssessmentKey], [PerformanceKey], [GoodCauseExemptionKey]),
	CONSTRAINT FK_AssessmentFact_DemographicJunkDimension FOREIGN KEY (DemographicKey) REFERENCES cmp.DemographicJunkDimension (DemographicKey),
	CONSTRAINT FK_AssessmentFact_SchoolYearDimension FOREIGN KEY (SchoolYearKey) REFERENCES cmp.SchoolYearDimension (SchoolYearKey),
	CONSTRAINT FK_AssessmentFact_SchoolDimension FOREIGN KEY (SchoolKey) REFERENCES cmp.SchoolDimension (SchoolKey),
	CONSTRAINT FK_AssessmentFact_AssessmentDimension FOREIGN KEY (AssessmentKey) REFERENCES cmp.AssessmentDimension (AssessmentKey),
	CONSTRAINT FK_AssessmentFact_GoodCauseExemptionJunkDimension FOREIGN KEY (GoodCauseExemptionKey) REFERENCES cmp.GoodCauseExemptionJunkDimension (GoodCauseExemptionKey),
	CONSTRAINT FK_AssessmentFact_PerformanceDimension FOREIGN KEY (PerformanceKey) REFERENCES cmp.PerformanceDimension (PerformanceKey)
	)

CREATE TABLE cmp.EnrollmentFact (
	DemographicKey INT NOT NULL,
	SchoolKey INT NOT NULL,
	SchoolYearKey SMALLINT NOT NULL,
	EnrollmentStudentCount INT NOT NULL,
	CONSTRAINT PK_EnrollmentFact PRIMARY KEY ([DemographicKey], [SchoolKey], [SchoolYearKey]),
	CONSTRAINT FK_EnrollmentFact_DemographicJunkDimension FOREIGN KEY (DemographicKey) REFERENCES cmp.DemographicJunkDimension (DemographicKey),
	CONSTRAINT FK_EnrollmentFact_SchoolYearDimension FOREIGN KEY (SchoolYearKey) REFERENCES cmp.SchoolYearDimension (SchoolYearKey),
	CONSTRAINT FK_EnrollmentFact_SchoolDimension FOREIGN KEY (SchoolKey) REFERENCES cmp.SchoolDimension (SchoolKey)
	)

CREATE TABLE cmp.AttendanceFact (
	DemographicKey INT NOT NULL,
	SchoolKey INT NOT NULL,
	SchoolYearKey SMALLINT NOT NULL,
	TotalAbsences INT NOT NULL,
	TotalInstructionalDays INT NOT NULL,
	CONSTRAINT PK_AttendanceFact PRIMARY KEY ([DemographicKey], [SchoolKey], [SchoolYearKey]),
	CONSTRAINT FK_AttendanceFact_DemographicJunkDimension FOREIGN KEY (DemographicKey) REFERENCES cmp.DemographicJunkDimension (DemographicKey),
	CONSTRAINT FK_AttendanceFact_SchoolYearDimension FOREIGN KEY (SchoolYearKey) REFERENCES cmp.SchoolYearDimension (SchoolYearKey),
	CONSTRAINT FK_AttendanceFact_SchoolDimension FOREIGN KEY (SchoolKey) REFERENCES cmp.SchoolDimension (SchoolKey)
	)

CREATE TABLE cmp.GraduationFact (
	DemographicKey INT NOT NULL,
	SchoolKey INT NOT NULL,
	SchoolYearKey SMALLINT NOT NULL,
	GraduationStatusKey INT NOT NULL,
	GraduationStudentCount INT NOT NULL,
	CONSTRAINT PK_GraduationFact PRIMARY KEY ([DemographicKey], [SchoolKey], [SchoolYearKey], [GraduationStatusKey]),
	CONSTRAINT FK_GraduationFact_DemographicJunkDimension FOREIGN KEY (DemographicKey) REFERENCES cmp.DemographicJunkDimension (DemographicKey),
	CONSTRAINT FK_GraduationFact_SchoolYearDimension FOREIGN KEY (SchoolYearKey) REFERENCES cmp.SchoolYearDimension (SchoolYearKey),
	CONSTRAINT FK_GraduationFact_SchoolDimension FOREIGN KEY (SchoolKey) REFERENCES cmp.SchoolDimension (SchoolKey),
	CONSTRAINT FK_GraduationFact_GraduationStatusJunkDimension FOREIGN KEY (GraduationStatusKey) REFERENCES cmp.GraduationStatusJunkDimension (GraduationStatusKey)
	)