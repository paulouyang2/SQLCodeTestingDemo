USE DemoDB
GO
CREATE PROC deleteDemoTable (
@name varchar(50)
)
AS
DELETE demoTable
WHERE name = @name
GO
