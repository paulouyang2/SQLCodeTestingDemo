USE demoDB
GO
CREATE PROC selectDemoTable
AS
SELECT name, hash = CHECKSUM(name) from demoTable
GO
