USE demoDB
GO
CREATE PROC insertDemoTable(
@nameList varchar(1000)
)
AS

-- this will fail 

INSERT demoTable
SELECT value FROM STRING_SPLIT(@nameList, ',');

-- the fix

-- IF SERVERPROPERTY('ProductMajorVersion') > 11
--     INSERT demoTable
--     SELECT value FROM STRING_SPLIT(@nameList, ',');
-- ELSE
--     INSERT demoTable
--     SELECT value FROM dbo.SplitString(@nameList, ',');
GO
