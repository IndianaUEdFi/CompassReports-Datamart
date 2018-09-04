/* Load GoodCauseExemptionJunkDimension */
MERGE INTO cmp.GoodCauseExemptionJunkDimension AS Target
USING (
VALUES ('Good Cause Exemption Granted')
	  ,('No Good Cause Exemption Granted')
	  ,('Not Applicable')) AS Source(GoodCauseExemption) ON Target.[GoodCauseExemption]=Source.[GoodCauseExemption]
WHEN NOT MATCHED BY TARGET THEN
	INSERT 	([GoodCauseExemption])
	VALUES 	(Source.[GoodCauseExemption]) 
WHEN NOT MATCHED BY SOURCE THEN
	DELETE;
