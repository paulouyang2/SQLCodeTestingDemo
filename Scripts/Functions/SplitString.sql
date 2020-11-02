USE demoDB
GO
CREATE OR ALTER FUNCTION dbo.SplitString
(
    @List     nvarchar(max),
    @Delim    nvarchar(255)
)
RETURNS TABLE
AS
RETURN ( 
SELECT [value]
FROM
    ( 
    SELECT [value] = LTRIM(RTRIM(SUBSTRING(@List, [Number],
      CHARINDEX(@Delim, @List + @Delim, [Number]) - [Number])))
    FROM (SELECT Number = ROW_NUMBER() OVER (ORDER BY name)
        FROM sys.all_columns) AS x
    WHERE Number <= LEN(@List)
        AND SUBSTRING(@Delim + @List, [Number], DATALENGTH(@Delim)/2) = @Delim
    ) AS y
);
GO
