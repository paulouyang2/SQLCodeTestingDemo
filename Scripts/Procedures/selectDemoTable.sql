USE demoDB
GO
CREATE OR ALTER PROC selectDemoTable
AS
SELECT name, hash = CHECKSUM(name) from demoTable
GO
