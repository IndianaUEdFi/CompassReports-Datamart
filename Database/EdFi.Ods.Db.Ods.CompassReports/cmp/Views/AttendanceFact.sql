CREATE VIEW [cmp].[AttendanceFact]
	AS 
/* STUDENT ATTENDANCE DAYS COUNT */

/****** SCHOOL DAYS POSSIBLE  ******/
WITH CALENDAR AS
(
SELECT [SchoolId]
      ,[Date]
FROM [edfi].[CalendarDateCalendarEvent] CD
JOIN [edfi].[CalendarEventDescriptor] CDD
	ON CD.[CalendarEventDescriptorId] = CDD.[CalendarEventDescriptorId]
JOIN [edfi].[CalendarEventType] CET
	ON CET.[CalendarEventTypeId] = CDD.[CalendarEventTypeId]
	AND CET.[Description] IN ('Instructional day', 'Make-up day')
GROUP BY [SchoolId]
      ,[Date]
)

,SCHOOLDAYS AS
(
SELECT  [SchoolId],
		COUNT(DISTINCT [Date]) AS NumberOfSchoolDays,
		MIN([Date]) AS BeginDate,
		MAX([Date]) AS EndDate
FROM CALENDAR
GROUP BY SchoolId
)

,STUDENTCALENDAR AS
(
SELECT  SSA.[StudentUSI]
       ,SSA.[SchoolId]
	   ,SSA.[EntryDate]
	   ,CD.[Date]
	   ,[ExitWithdrawDate]
FROM [edfi].[StudentSchoolAssociation] SSA
JOIN CALENDAR CD
	ON CD.[SchoolId] = SSA.[SchoolId]
	AND SSA.[EntryDate] <= CD.[Date]
	AND ([ExitWithdrawDate] IS NULL OR [ExitWithdrawDate] >= CD.[Date])
)

,STUDENTPOSSIBLEDAYS AS
(
  SELECT [StudentUSI],
		[SchoolId],
		COUNT(DISTINCT [Date]) AS PossibleStudentAttendanceDays
 FROM STUDENTCALENDAR SC
 GROUP BY [StudentUSI],
		[SchoolId]
)

,STUDENTABSENTDAYS AS
(
SELECT [StudentUSI]
      ,[SchoolId]
      ,[SchoolYear]
      ,COUNT(DISTINCT [EventDate]) AS Absenses
FROM
(
SELECT [StudentUSI]
      ,[SchoolId]
      ,[SchoolYear]
      ,[EventDate]
FROM [edfi].[StudentSchoolAttendanceEvent] ATT
JOIN [edfi].[AttendanceEventCategoryDescriptor] ATD
	ON ATD.[AttendanceEventCategoryDescriptorId] = ATT.[AttendanceEventCategoryDescriptorId]
JOIN [edfi].[AttendanceEventCategoryType] ATC
	ON ATC.[AttendanceEventCategoryTypeId] = ATD.[AttendanceEventCategoryTypeId]
	AND ATC.Description IN ('Excused Absence', 'Unexcused Absence')
GROUP BY [StudentUSI]
      ,[SchoolId]
      ,[SchoolYear]
      ,[EventDate]
)A
GROUP BY [StudentUSI]
      ,[SchoolId]
      ,[SchoolYear]
)

,STUDENTATTENDANCERATE AS
(
SELECT SSA.[StudentUSI]
      ,SSA.[SchoolId]
	  ,CASE WHEN GLT.Description = 'First grade' THEN 'Grade 1'
			WHEN GLT.Description = 'Second grade' THEN 'Grade 2'
			WHEN GLT.Description = 'Third grade' THEN 'Grade 3'
			WHEN GLT.Description = 'Fourth grade' THEN 'Grade 4'
			WHEN GLT.Description = 'Fifth grade' THEN 'Grade 5'
			WHEN GLT.Description = 'Sixth grade' THEN 'Grade 6'
			WHEN GLT.Description = 'Seventh grade' THEN 'Grade 7'
			WHEN GLT.Description = 'Eighth grade' THEN 'Grade 8'
			WHEN GLT.Description = 'Ninth grade' THEN 'Grade 9'
			WHEN GLT.Description = 'Tenth grade' THEN 'Grade 10'
			WHEN GLT.Description = 'Eleventh grade' THEN 'Grade 11'
			WHEN GLT.Description = 'Twelfth grade' THEN 'Grade 12'
			WHEN GLT.Description = 'Preschool/Prekindergarten' THEN 'Pre-Kindergarten'
			WHEN GLT.Description = 'Kindergarten' THEN 'Kindergarten'
	   END AS GradeLevel
      ,SES.[SchoolYear]
	  ,PossibleStudentAttendanceDays
	  ,ISNULL(Absenses, 0) AS Absenses
FROM [edfi].[StudentSchoolAssociation] SSA
JOIN [edfi].[GradeLevelDescriptor] GLD
	ON SSA.[EntryGradeLevelDescriptorId] = GLD.[GradeLevelDescriptorId]
JOIN [edfi].[GradeLevelType] GLT
	ON GLT.[GradeLevelTypeId] = GLD.[GradeLevelTypeId]
JOIN STUDENTPOSSIBLEDAYS PD
	ON SSA.[StudentUSI] = PD.[StudentUSI]
	AND SSA.[SchoolId] = PD.[SchoolId]
JOIN [edfi].[Session] SES
	ON SES.[SchoolId] = SSA.[SchoolId]
 JOIN SCHOOLDAYS SD
	ON SD.[SchoolId] = PD.[SchoolId]
	AND PD.PossibleStudentAttendanceDays <= NumberOfSchoolDays
LEFT JOIN STUDENTABSENTDAYS ATT
	ON SSA.[StudentUSI] = ATT.[StudentUSI]
	AND SSA.[SchoolId] = ATT.[SchoolId]
GROUP BY SSA.[StudentUSI]
      ,SSA.[SchoolId]
	  ,GLT.Description 
      ,SES.[SchoolYear]
	  ,PossibleStudentAttendanceDays
	  ,ISNULL(Absenses, 0) 
)

SELECT  DD.DemographicId,
		SAR.SchoolId,
		SAR.SchoolYear,
		SUM(Absenses) AS TotalAbsences,
		SUM(PossibleStudentAttendanceDays) AS TotalInstructionalDays
FROM STUDENTATTENDANCERATE SAR
JOIN cmp.StudentEnrollment() SD
	ON SAR.StudentUSI = SD.StudentUSI
	AND SAR.SchoolId = SD.SchoolId
	AND SAR.GradeLevel = SD.GradeLevel
JOIN cmp.DemographicDim() DD
	ON SD.GradeLevel = DD.GradeLevel
	AND SD.Ethnicity = DD.Ethnicity
	AND SD.FreeReducedLunchStatus = DD.FreeReducedLunchStatus
	AND SD.SpecialEducationStatus = DD.SpecialEducationStatus
	AND SD.EnglishLanguageLearnerStatus = DD.EnglishLanguageLearnerStatus
	AND (SD.ExpectedGraduationYear = DD.ExpectedGraduationYear OR SD.ExpectedGraduationYear IS NULL)
GROUP BY SAR.SchoolId,
		SAR.SchoolYear,
		DD.DemographicId
