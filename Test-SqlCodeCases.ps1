@(
    @{
        TestType     = 'proc'
        ObjectName   = 'deleteDemotable'
        Query        = "deleteDemotable 'Marcos'"
        ObjectExists = $true
        ErrorCheck   = $true
    },
    @{
        TestType     = 'proc'
        ObjectName   = 'insertDemoTable'
        Query        = "insertDemoTable 'Marcos'"
        ObjectExists = $true
        ErrorCheck   = $true
    }
)