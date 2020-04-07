@( 
    @{
        procedure           = "insertDemoTable 'Mateo,Lucas,Pablo'"
        database            = "demoDB"  
        expectedRowsEq      = 0
        queryStateBefore    = "truncate table demoTable; select 'Empty'"
        expectedStateBefore = "Empty"
    }
    ,@{
        procedure           = "deleteDemotable 'Lucas'"
        database            = "demoDB"  
        expectedRowsEq      = 0
        queryStateBefore    = "select name from demoTable where name = 'Lucas'"
        expectedStateBefore = "Lucas"
        queryStateAfter     = "if not exists(select * from demoTable where name = 'Lucas') select 'Not Exists'"
        expectedStateAfter  = "Not Exists"
    }
    ,@{
        procedure           = "selectDemotable"
        database            = "demoDB"  
        expectedRowsGt      = 1
        expectedColumnNames = "name", "hash"
        expectedValues      = "Mateo"
    }
    ,@{
        procedure           = "updateDemotable 'Pablo', 'Pedro'"
        database            = "demoDB"  
        expectedRowsEq      = 0
        queryStateBefore    = "select name from demoTable where name = 'Pablo'"
        expectedStateBefore = "Pablo"
        queryStateAfter     = "select name from demoTable where name = 'Pedro'"
        expectedStateAfter  = "Pedro"

    }
)
