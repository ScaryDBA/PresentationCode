$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = 'Server=WIN-8A2LQANSO51;Database=AdventureWorks2017;trusted_connection=true'

# parameters for sniffing
$RefCmd = New-Object System.Data.SqlClient.SqlCommand
$RefCmd.CommandText = "SELECT th.ReferenceOrderID,
       COUNT(th.ReferenceOrderID) AS RefCount
FROM dbo.TransactionHistory AS th
GROUP BY th.ReferenceOrderID;"
$RefCmd.Connection = $SqlConnection
$SqlAdapter.SelectCommand = $RefCmd
$RefData = New-Object System.Data.DataSet
$SqlAdapter.Fill($RefData)

# Causes bad parameter sniffing
$Sniffcmd = New-Object System.Data.SqlClient.SqlCommand
$Sniffcmd.CommandType = [System.Data.CommandType]'StoredProcedure'
$Sniffcmd.CommandText = "dbo.ProductTransactionHistoryByReference"
$Sniffcmd.Parameters.Add("@ReferenceOrderID",[System.Data.SqlDbType]"Int")
$Sniffcmd.Connection = $SqlConnection

# Clearing cache, every execution
$Freecmd = New-Object System.Data.SqlClient.SqlCommand
$Freecmd.CommandText = "DECLARE @plan_handle VARBINARY(64);

SELECT @plan_handle = deps.plan_handle
FROM sys.dm_exec_procedure_stats AS deps
WHERE deps.object_id = OBJECT_ID('dbo.ProductTransactionHistoryByReference');

DBCC FREEPROCCACHE(@plan_handle);"
$Freecmd.Connection = $SqlConnection

while(1 -ne 0)
{
    foreach($row in $RefData.Tables[0])
        {
        $RefID = $row[0]
        $SqlConnection.Open()
        $Sniffcmd.Parameters["@ReferenceOrderID"].Value = $RefID
        $Sniffcmd.ExecuteNonQuery() | Out-Null
        $SqlConnection.Close()

        $SqlConnection.Open()
        $Freecmd.ExecuteNonQuery() | Out-Null
        $SqlConnection.Close()
    }
}
