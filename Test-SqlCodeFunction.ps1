function Test-SqlCode {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$ServerInstance,
        [Parameter(Mandatory)]
        [string]$Database,
        [ValidateSet("schema", "data", "proc")]
        [Parameter(Mandatory)]
        [string]$TestType,
        [Parameter(Mandatory)]
        [string]$ObjectName,
        [switch]$ObjectExists,
        [System.Object[]]$TableDefinition,
        [System.Object[]]$IndexDefinition,
        [string]$Query,
        [string[]]$AllRowValues,
        [string[]]$FirstRowValue,
        [string[]]$ColumnNames,
        [int]$NumberOfRows,
        [switch]$ErrorCheck,
        [System.Object[]]$ProcParam,
        [PSCredential]$Credential,
        [string]$VersionString
    )

    $paramSqlCmd = @{
        ServerInstance       = $ServerInstance
        Database             = $Database
        Credential           = $Credential
        ErrorAction          = 'Stop'
        IncludeSqlUserErrors = $true
    }

    if ($TestType -eq 'data' -or $TestType -eq 'proc') {
        if ($Query -eq '') {
            throw '-Query is mandatory when -TestType is "data" or "proc"'
        }
        else {
            try {
                $resultError = $null
                $resultQuery = @(Invoke-Sqlcmd @paramSqlCmd -Query $Query)
            }
            catch {
                $resultError = @($_.Exception.Message)
                $resultQuery = @()
            }
        }
    }

    $keys = $PSBoundParameters.Keys

    describe "$VersionString $ObjectName $TestType test" {
        switch ($keys) {
            'ObjectExists' {
                it 'should return object id' -TestCases @(
                    @{
                        ObjectName  = $ObjectName
                        ParamSqlCmd = $paramSqlCmd
                    }
                ) {
                    $query = "select oid = object_id('$ObjectName')"
                    $r = Invoke-Sqlcmd @ParamSqlCmd -Query $query
                    $r.obid | Should -Not -Be ''
                }
            }
            'TableDefinition' {
                it 'should return table definition' -TestCases @(
                    @{
                        ObjectName      = $ObjectName
                        TableDefinition = $TableDefinition
                        ParamSqlCmd     = $paramSqlCmd
                    }
                ) {
                    $paramOther = @{
                        Query    = "sp_help $ObjectName"
                        OutputAs = 'DataSet'
                    }
                    $r = Invoke-Sqlcmd @ParamSqlCmd @paramOther
                    $r.Tables[1].ItemArray | Should -Be $TableDefinition
                }
            }
            'IndexDefinition' {
                it 'should return index definition' -TestCases @(
                    @{
                        ObjectName      = $ObjectName
                        IndexDefinition = $IndexDefinition
                        ParamSqlCmd     = $paramSqlCmd
                    }
                ) {
                    $query = "sp_helpindex $ObjectName"
                    $r = Invoke-Sqlcmd @ParamSqlCmd -Query $query
                    $r.ItemArray | Should -Be $IndexDefinition
                }
            }
            'AllRowValues' {
                it 'should return all row values' -TestCases @(
                    @{
                        ResultQuery  = $resultQuery
                        AllRowValues = $AllRowValues
                    }
                ) {
                    $ResultQuery.ItemArray | Should -Be $AllRowValues
                }
            }
            'FirstRowValue' {
                it 'should return first row value' -TestCases @(
                    @{
                        ResultQuery   = $resultQuery
                        FirstRowValue = $FirstRowValue
                    }
                ) {
                    $resultQuery[0].ItemArray | Should -Be $FirstRowValue
                }
            }
            'ColumnNames' {
                it 'should return column names' -TestCases @(
                    @{
                        ResultQuery = $resultQuery
                        ColumnNames = $ColumnNames
                    }
                ) {
                    $resultQuery[0].Table.Columns.ColumnName |
                    Should -Be $ColumnNames
                }
            }
            'NumberOfRows' {
                it 'should return number of rows' -TestCases @(
                    @{
                        ResultQuery  = $resultQuery
                        NumberOfRows = $NumberOfRows
                    }
                ) {
                    $resultQuery.Count | Should -Be $NumberOfRows
                }
            }
            'ProcParam' {
                it 'should return parameter definition' -TestCases @(
                    @{
                        ObjectName  = $ObjectName
                        ProcParam   = $ProcParam
                        ParamSqlCmd = $paramSqlCmd
                    }
                ) {
                    $paramOther = @{
                        Query    = "sp_help $ObjectName"
                        OutputAs = 'DataSet'
                    }
                    $r = Invoke-Sqlcmd @ParamSqlCmd @paramOther
                    $r.Tables[1].ItemArray | Should -Be $ProcParam
                }
            }
            'ErrorCheck' {
                it 'should not return error' -TestCases @(
                    @{
                        ResultError = $resultError
                    }
                ) {
                    {
                        if ($null -ne $ResultError) {
                            throw $ResultError
                        }
                    } | Should -Not -Throw
                }
            }
        }
    }
}