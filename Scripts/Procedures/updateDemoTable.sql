USE demoDB
GO
CREATE PROC updateDemoTable (
@oldName varchar(50), @newName varchar(50)
)
AS
UPDATE demoTable
SET name = @newName
WHERE name = @oldName
GO
