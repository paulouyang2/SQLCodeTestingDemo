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
    },
    @{
        TestType     = 'proc'
        ObjectName   = 'updateDemotable'
        Query        = "updateDemotable 'Pablo', 'Pedro'"
        ObjectExists = $true
        ErrorCheck   = $true
    }
)