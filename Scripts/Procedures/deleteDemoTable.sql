USE DemoDB
GO
CREATE OR ALTER PROC deleteDemoTable (
@name varchar(50)
)
AS
DELETE demoTable
WHERE name = @name
GO
