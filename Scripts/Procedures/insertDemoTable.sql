USE demoDB
GO
CREATE OR ALTER PROC insertDemoTable(
@nameList varchar(1000)
)
AS

INSERT demoTable
VALUES (@nameList)

-- change 1

-- INSERT demoTable
-- SELECT value FROM STRING_SPLIT(@nameList, ',');






-- change 2

-- IF SERVERPROPERTY('ProductMajorVersion') > 11
--     INSERT demoTable
--     SELECT value FROM STRING_SPLIT(@nameList, ',');
-- ELSE
--     INSERT demoTable
--     SELECT value FROM dbo.SplitString(@nameList, ',');
-- GO
