@(
    @{
        TestType     = 'proc'
        ObjectName   = 'insertDemoTable'
        Query        = "insertDemoTable 'Marcos'"
        ObjectExists = $true
        ErrorCheck   = $true
    },
    @{
        TestType     = 'proc'
        ObjectName   = 'deleteDemotable'
        Query        = "deleteDemotable 'Lucas'"
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