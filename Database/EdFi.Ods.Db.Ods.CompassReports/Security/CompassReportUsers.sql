CREATE ROLE [CompassReportEtl]
GO

GRANT SELECT,EXECUTE ON SCHEMA :: cmp TO [CompassReportEtl];
