USE demoDB
GO
CREATE PROC insertDemoTable(
@nameList varchar(1000)
)
AS
IF SERVERPROPERTY('ProductMajorVersion') > 11
    INSERT demoTable
    SELECT value FROM STRING_SPLIT(@nameList, ',');
ELSE
    INSERT demoTable
    SELECT value FROM dbo.SplitString(@nameList, ',');
GO
