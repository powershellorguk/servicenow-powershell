function Get-ServiceNowUserGroup{
    param(
        # Machine name of the field to order by
        [parameter(mandatory=$false)]
        [parameter(ParameterSetName='SpecifyConnectionFields')]
        [parameter(ParameterSetName='UseConnectionObject')]
        [parameter(ParameterSetName='SetGlobalAuth')]
        [string]$OrderBy='name',

        # Direction of ordering (Desc/Asc)
        [parameter(mandatory=$false)]
        [parameter(ParameterSetName='SpecifyConnectionFields')]
        [parameter(ParameterSetName='UseConnectionObject')]
        [parameter(ParameterSetName='SetGlobalAuth')]
        [ValidateSet("Desc", "Asc")]
        [string]$OrderDirection='Desc',

        # Maximum number of records to return
        [parameter(mandatory=$false)]
        [parameter(ParameterSetName='SpecifyConnectionFields')]
        [parameter(ParameterSetName='UseConnectionObject')]
        [parameter(ParameterSetName='SetGlobalAuth')]
        [int]$Limit=10,

        # Hashtable containing machine field names and values returned must match exactly (will be combined with AND)
        [parameter(mandatory=$false)]
        [parameter(ParameterSetName='SpecifyConnectionFields')]
        [parameter(ParameterSetName='UseConnectionObject')]
        [parameter(ParameterSetName='SetGlobalAuth')]
        [hashtable]$MatchExact=@{},

        # Hashtable containing machine field names and values returned rows must contain (will be combined with AND)
        [parameter(mandatory=$false)]
        [parameter(ParameterSetName='SpecifyConnectionFields')]
        [parameter(ParameterSetName='UseConnectionObject')]
        [parameter(ParameterSetName='SetGlobalAuth')]
        [hashtable]$MatchContains=@{},

        # Whether to return manipulated display values rather than actual database values.
        [parameter(mandatory=$false)]
        [parameter(ParameterSetName='SpecifyConnectionFields')]
        [parameter(ParameterSetName='UseConnectionObject')]
        [parameter(ParameterSetName='SetGlobalAuth')]
        [ValidateSet("true","false", "all")]
        [string]$DisplayValues='true',

        # Credential used to authenticate to ServiceNow
        [Parameter(ParameterSetName='SpecifyConnectionFields', Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [PSCredential]
        $ServiceNowCredential,

        # The URL for the ServiceNow instance being used
        [Parameter(ParameterSetName='SpecifyConnectionFields', Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ServiceNowURL,

        #Azure Automation Connection object containing username, password, and URL for the ServiceNow instance
        [Parameter(ParameterSetName='UseConnectionObject', Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [Hashtable]
        $Connection
    )

    # Query Splat
    $newServiceNowQuerySplat = @{
        OrderBy = $OrderBy
        OrderDirection = $OrderDirection
        MatchExact = $MatchExact
        MatchContains = $MatchContains
    }
    $Query = New-ServiceNowQuery @newServiceNowQuerySplat

    # Table Splat
    $getServiceNowTableSplat = @{
        Table = 'sys_user_group'
        Query = $Query
        Limit = $Limit
        DisplayValues = $DisplayValues
    }

    # Update the splat if the parameters have values
    if ($null -ne $PSBoundParameters.Connection)
    {
        $getServiceNowTableSplat.Add('Connection',$Connection)
    }
    elseif ($null -ne $PSBoundParameters.ServiceNowCredential -and $null -ne $PSBoundParameters.ServiceNowURL)
    {
         $getServiceNowTableSplat.Add('ServiceNowCredential',$ServiceNowCredential)
         $getServiceNowTableSplat.Add('ServiceNowURL',$ServiceNowURL)
    }

    # Perform query and return each object in the format.ps1xml format
    $Result = Get-ServiceNowTable @getServiceNowTableSplat
    $Result | ForEach-Object{$_.PSObject.TypeNames.Insert(0,"ServiceNow.UserAndUserGroup")}
    $Result
}
