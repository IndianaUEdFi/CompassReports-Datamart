<#
.SYNOPSIS
    Deploy dacpac using SqlPackage.exe.
.DESCRIPTION
     Module to Deploy dacpac using SqlPackage.exe.
.PARAMETER SqlPackagePath
  The path to the SqlPackage.exe.  It must be version 12.0.1295 or higher.
#>
Param (
	[String]$script:SqlPackagePath = "Default"
	)
if ($SqlPackagePath -eq "Default") {
	$SqlPackagePath = Get-ChildItem -Path "${env:ProgramFiles(x86)}\Microsoft SQL Server\" -Recurse -Filter "sqlpackage.exe" | Sort-Object {[Version]$_.VersionInfo.ProductVersion} -Descending | select -ExpandProperty FullName -First 1
}
if (Test-Path $SqlPackagePath) {
	$SqlPackageResolvedPath = Resolve-Path $SqlPackagePath
	$sqlpackageexe = get-item $SqlPackageResolvedPath
	if ([Version]$sqlpackageexe.VersionInfo.ProductVersion -lt "12.0.1295") {
		Write-Error "The version of $SqlPackageResolvedPath is $($sqlpackageexe.VersionInfo.ProductVersion).  It needs to be at least 12.0.1295 due to how error reporting is handled."
	}
}
Else {
	Write-Error "SQLPackage.exe not found at $SqlPackagePath.  Have you installeed the Microsoft SQL Server Data-Tier Application Framework?  At least April 2014 version."
	exit 1
}
<#
.SYNOPSIS
	Deploy dacpac using SqlPackage.exe.
.DESCRIPTION
	Deploy dacpac using SqlPackage.exe.
	Options based on Profile additional properties:
		To update existing databases based on a Regular Expression, add the TargetDatabaseNameMatch property, with a value of the Regular Expresion to the Property Group in the sqlproj file.
		To Restore from a backup before applying the dacpac, add the RestoreFromBackup property, with a value of the path to the backup file to the Property Group in the sqlproj file.
		To Backup a database after deployment, add the BackupPath property, with a value to the path of the backup file you wish to create.
.PARAMETER DacpacPath
	The path to the dacpac file.
.PARAMETER PublishProfilePath
	The path to the xml profile.
.EXAMPLE
   # Deploy a dacpac
   Install-DacPac -DacpacPath "MyDacPac.dacpac" -PublishProfilePath "MyProfile.publish.xml"
#>
Function Install-DacPac {
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$true)]
		[ValidateScript({
			if(Test-Path $_) {
				$true
			}
			else {
				Throw "`"$_`" is not a valid path"
			}})]
		[String]$DacpacPath,
		[Parameter(Mandatory=$true)]
		[ValidateScript({
			if(Test-Path $_) {
				$true
			}
			else {
				Throw "`"$_`" is not a valid path"
			}})]
		[String]$PublishProfilePath,
		[String]$DatabaseNamePrefix = "",
		[String]$DatabaseNameOverride,
		[Switch]$DoNotRedactPasswords,
		[Switch]$OnlyIfNonExistent,
		[Switch]$WhatIf
	)
	$ErrorActionPreference = "Stop"

	$dacpacResolvedPath = Resolve-Path $DacpacPath
	$profilePackageResolvedPath = Resolve-Path $publishProfilePath

	#Capture Connection Properties from PublishProfile
	[xml]$ProfilePackage = Get-Content $ProfilePackageResolvedPath
	if ($DatabaseNameOverride) {
		$databaseName = $DatabaseNameOverride
	}
	else 
	{
		$databaseName = $DatabaseNamePrefix + $ProfilePackage.Project.PropertyGroup.TargetDatabaseName
	}
	
	if ($ProfilePackage.Project.PropertyGroup.RestoreFromBackup `
		-or $ProfilePackage.Project.PropertyGroup.TargetDatabaseNameMatch `
		-or $ProfilePackage.Project.PropertyGroup.BackupPath `
		-or $ProfilePackage.Project.PropertyGroup.PreEvalCommand`
		-or $OnlyIfNonExistent) {
		$conn = New-Object ('System.Data.SqlClient.SqlConnection')($ProfilePackage.Project.PropertyGroup.TargetConnectionString)
		Push-Location
		Import-Module SQLPS
		Pop-Location
		$s = New-Object ("Microsoft.SqlServer.Management.Smo.Server") ($conn)
	}
	if ($OnlyIfNonExistent) {
		if ($s.Databases.Name -contains $databaseName) {
			Write-Host "Database $databaseName Exists, not deploying"
			exit 0
		}
	}
	if ($ProfilePackage.Project.PropertyGroup.RestoreFromBackup) {
		#First, restore from the designated backup
		if (Test-Path $ProfilePackage.Project.PropertyGroup.RestoreFromBackup) {
			$restoreFromBackupResolvedPath = Resolve-Path $ProfilePackage.Project.PropertyGroup.RestoreFromBackup
			Restore-DbCore -server $s -databaseName $databaseName -backupFile $restoreFromBackupResolvedPath -action 'Database' -norecovery $false -replace $true -WhatIf:$WhatIf
			Write-Host "Restored database from $restoreFromBackupResolvedPath to database [$databaseName]."
		}
		else {
			Write-Error "Backup File not found at $($ProfilePackage.Project.PropertyGroup.RestoreFromBackup)"
			exit 1
		}
	}
	if ($ProfilePackage.Project.PropertyGroup.PreEvalCommand) {
		if ($s.Databases.Name -contains $databaseName) {
			if ($WhatIf) {
				Write-Host "What if: Executing $($ProfilePackage.Project.PropertyGroup.PreEvalCommand)"
			}
			else {
				Invoke-SqlCmd -ServerInstance $s.Name -Database $databaseName -Query $ProfilePackage.Project.PropertyGroup.PreEvalCommand
				$SQLSession = Invoke-Sqlcmd -Server $s.Name -Database $databaseName -Query "select @@spid as SessionID"
				Invoke-Sqlcmd -Server $s.Name -Database "master" -Query "KILL $($SQLSession.SessionID)"
			}
		}
	}
	
	if ($Whatif) {
		Write-Host "What if: Executing `"$SqlPackageResolvedPath`" /action:Publish /SourceFile:`"$dacpacResolvedPath`" /Profile:`"$ProfilePackageResolvedPath`" /TargetDatabaseName:`"$databaseName`""
	}
	else {
		& "$SqlPackageResolvedPath" /action:Publish /SourceFile:"$dacpacResolvedPath" /Profile:"$ProfilePackageResolvedPath" /TargetDatabaseName:"$databaseName"
	}

	[string]$templateDatabaseNameMatch = $databaseName
	if ($ProfilePackage.Project.PropertyGroup.TemplateDatabaseNameMatch) {
		$templateDatabaseNameMatch = $ProfilePackage.Project.PropertyGroup.TemplateDatabaseNameMatch 
	}

	if ($ProfilePackage.Project.PropertyGroup.BackupPath -and $databaseName -match $templateDatabaseNameMatch) {
		#Database sbould be backed up
		if (Test-Path $ProfilePackage.Project.PropertyGroup.BackupPath -IsValid) {
			if ($ProfilePackage.Project.PropertyGroup.BackupPath -match '.bak$') {
				$backupResolvedPath = $(Resolve-Path $([System.IO.Path]::GetDirectoryName($($ProfilePackage.Project.PropertyGroup.BackupPath)))).Path
				$backupResolvedPath = $backupResolvedPath + "\" + $([System.IO.Path]::GetFileName($($ProfilePackage.Project.PropertyGroup.BackupPath)))
			}
			else {
				$backupResolvedPath = $(Resolve-Path $ProfilePackage.Project.PropertyGroup.BackupPath).Path
				$backupResolvedPath = $backupResolvedPath + "\" + $databaseName + ".bak"
			}
			Backup-DbCore -server $s -databaseName $databaseName -backupDirectory $(split-path $backupResolvedPath -Parent) -backupFileName $(split-path $backupResolvedPath -Leaf) -action "Database" -WhatIf:$WhatIf
			Write-Host "Backed up database [$databaseName] to $backupResolvedPath."
		}
		else {
			Write-Error "Backup location $($ProfilePackage.Project.PropertyGroup.BackupPath) is not valid."
			exit 1
		}
	}

	#------ Now lets deal with databases that meet the naming convention that need to be upgraded too------
	$affectedDatabases = @($databaseName)
	# If the TargetDatabaseNameMatch parameter has been added to the Profile, use it.
	if ($ProfilePackage.Project.PropertyGroup.TargetDatabaseNameMatch) {
		#Get Datbases
		$matchedDbs = $s.Databases | select -ExpandProperty Name | where { $_ -match $ProfilePackage.Project.PropertyGroup.TargetDatabaseNameMatch -and $_ -ne $databaseName}
		foreach ($matchedDbName in $matchedDbs) {
			#Consider multi-threading if performance becomes an issue.
			if ($ProfilePackage.Project.PropertyGroup.PreEvalCommand) {
				if ($WhatIf) {
					Write-Host "What if: Executing $($ProfilePackage.Project.PropertyGroup.PreEvalCommand)"
				}
				else {
					Invoke-SqlCmd -ServerInstance $s.Name -Database $matchedDbName -Query $ProfilePackage.Project.PropertyGroup.PreEvalCommand
				}
			}
			if ($Whatif) {
				Write-Host "What if: Executing `"$SqlPackageResolvedPath`" /action:Publish /SourceFile:`"$dacpacResolvedPath`" /Profile:`"$ProfilePackageResolvedPath`" /TargetDatabaseName:`"$matchedDbName`""
			}
			else {
				& "$SqlPackageResolvedPath" /action:Publish /SourceFile:"$dacpacResolvedPath" /Profile:"$ProfilePackageResolvedPath" /TargetDatabaseName:"$matchedDbName"
			}
			if ($ProfilePackage.Project.PropertyGroup.BackupPath -and $matchedDbName -match $templateDatabaseNameMatch) {
				#Database sbould be backed up
				if (Test-Path $ProfilePackage.Project.PropertyGroup.BackupPath -IsValid) {
					if ($ProfilePackage.Project.PropertyGroup.BackupPath -match '.bak$') {
						$backupResolvedPath = $(Resolve-Path $([System.IO.Path]::GetDirectoryName($($ProfilePackage.Project.PropertyGroup.BackupPath)))).Path
						$backupResolvedPath = $backupResolvedPath + "\" + $([System.IO.Path]::GetFileName($($ProfilePackage.Project.PropertyGroup.BackupPath)))
					}
					else {
						$backupResolvedPath = $(Resolve-Path $ProfilePackage.Project.PropertyGroup.BackupPath).Path
						$backupResolvedPath = $backupResolvedPath + "\" + $matchedDbName + ".bak"
					}
					Backup-DbCore -server $s -databaseName $matchedDbName -backupDirectory $(split-path $backupResolvedPath -Parent) -backupFileName $(split-path $backupResolvedPath -Leaf) -action "Database" -WhatIf:$WhatIf
					Write-Host "Backed up database [$matchedDbName] to $backupResolvedPath."
				}
				else {
					Write-Error "Backup location $($ProfilePackage.Project.PropertyGroup.BackupPath) is not valid."
					exit 1
				}
			}
			$affectedDatabases += $matchedDbName
		}
	}
	Write-Host "Affected Databases"
	Write-Host $affectedDatabases
	if (Test-Path Function:\Set-OctopusVariable) {
			Set-OctopusVariable -name "AffectedDatabases" -value $([String]::Join(",",$affectedDatabases))
		}
	if (!($DoNotRedactPasswords)) {
		#Redact Connection String Password
		$cString = New-Object System.Data.Common.DbConnectionStringBuilder
		$cString.set_ConnectionString($ProfilePackage.Project.PropertyGroup.TargetConnectionString)
		$profileModified = $false
		if ($cString["integrated security"] -ne "True") {
			$cString.Password = "Redacted"
			$profileModified = $true
		}
		$ProfilePackage.Project.PropertyGroup.TargetConnectionString = $cString.ConnectionString

		#Redact Properites that end in password
		foreach ($cmdVariable in $ProfilePackage.Project.ItemGroup.SqlCmdVariable | Where {$_.Include -like '*Password'}) {
			if ($cmdVariable.Value -ne "false") {
				$cmdVariable.Value = "Redacted"
				$profileModified = $true
			}
		}
		if ($profileModified) {
			if ($Whatif) {
				Write-Host "What if: Saving Redacted File with contents:"
				write-host $ProfilePackage | Out-String
			}
			else {
				$ProfilePackage.Save($ProfilePackageResolvedPath)
			}
		}
	}
	if ($error) {exit 1}
}


<#
    .Synopsis
    Get a valid log and/or data file location for e.g. database restores. 
    .Description
    Query a db server SMO and return a valid log and/or data file location for 
    database restores. If the server has set a DefaultFile property, return it.
    If not, use the MasterDBPath property.
	********************************************************************
	
	This code taken from the database-management module, and used here for self-containment.  Should be imported as a module after cleanup. 		
	
	********************************************************************
#>
function Get-SmoFileLocation {
    [cmdletbinding()]
    param(
        [Parameter(mandatory=$true)] [Microsoft.SqlServer.Management.Smo.Server] $server,
        [Parameter(mandatory=$true)] [ValidateSet("Data","Log")] [string] $fileType
    )
    $SmoProps = @{
        Data = @{
            Default = "DefaultFile"
            Master = "MasterDBPath"
        }
        Log = @{
            Default = "DefaultLog"
            Master = "MasterDBLogPath"
        }
    }
    foreach ($ft in $fileType) {
        $default = $server.$($SmoProps.$ft.Default)
        $master = $server.$($SmoProps.$ft.Master)
        if ($default) {
            write-verbose "Using Default at '$default' for the $ft files"
            return $default
        }
        else {
            write-verbose "Using Master at '$master' for the $ft files"
            return $master
        }
    }
}

#	********************************************************************
#	
#	This code taken from the database-management module, and used here for self-containment.  
# 	Made modification to pass server instead of server name, and added WhatIf switch
#	Should be imported as a module after cleanup. 		
#	
#	********************************************************************
Function Restore-DbCore {
    [cmdletbinding()]
    param(
		[parameter(mandatory=$true,ParameterSetName="SMOServer")] [Microsoft.SqlServer.Management.Smo.Server] $server, 
		[parameter(mandatory=$true,ParameterSetName="ServerName")] [string] $sqlServer, 
		[parameter(mandatory=$true)] [string] $databaseName, 
		[parameter(ParameterSetName="ServerName")][string] $username, 
		[parameter(ParameterSetName="ServerName")][System.Security.SecureString] $password,
        [parameter(mandatory=$true)] [string] $backupFile,
        [Hashtable] $usersToReassociate,
        [string] $dataPath,
        [string] $logPath,
		[parameter(mandatory=$true)] [string] $action, 
		[boolean] $norecovery, 
		[parameter(mandatory=$true)] [boolean] $replace,
		[Switch]$WhatIf
    )

    trap [Exception] {
        write-error $("ERROR: " + $_.Exception.ToString());
        break;
    }

	if($PSCmdlet.ParameterSetName -eq "ServerName") {
    	$server = Get-Server $sqlServer $username $password
	}
    $smoRestore = New-Object("Microsoft.SqlServer.Management.Smo.Restore")

    # Add the bak file as a device
    $backupDevice = New-Object("Microsoft.SqlServer.Management.Smo.BackupDeviceItem") ($backupFile, "File")
    $smoRestore.Devices.Add($backupDevice)

    if (-not $dataPath) { $dataPath = Get-SmoFileLocation -server $server -filetype data }
    if (-not $logPath)  { $logPath  = Get-SmoFileLocation -server $server -filetype log }
   
   foreach ($row in $smoRestore.ReadFileList($server).Rows) {
       if ([IO.Path]::GetExtension($row[1]) -eq ".ldf") {
            $designatedPath = $logPath
       }
       else {
            $designatedPath = $dataPath
       }
       $dbFilePath = $row[1]
       $dbFile = New-Object("Microsoft.SqlServer.Management.Smo.RelocateFile")
       $dbFile.LogicalFileName = $row[0]
       $dbFile.PhysicalFileName = [IO.Path]::Combine($dataPath, $databaseName + [IO.Path]::GetExtension($dbFilePath))
       Write-Host "dbFile.LogicalFileName = $($dbFile.LogicalFileName)"
       Write-Host "dbFile.PhysicalFileName = $($dbFile.PhysicalFileName )"
       $smoRestore.RelocateFiles.Add($dbFile) | out-null
    }   

   # Set options
   $smoRestore.Database = $databaseName
   $smoRestore.NoRecovery = $norecovery
   $smoRestore.ReplaceDatabase = $replace
   $smoRestore.Action = $action

   $backupSets = $smoRestore.ReadBackupHeader($server)
   $smoRestore.FileNumber = $backupSets.Rows.Count # Most recent backup in the set

   # Write-Host "DEBUG: backup sets in file: $($smoRestore.FileNumber)"

   # Show notifications
   $smoRestore.PercentCompleteNotification = 10

   #$smoRestoreDetails = $smoRestore.ReadBackupHeader($server)
   #"Database Name from Backup Header : " + $smoRestoreDetails.Rows[0]["DatabaseName"]

   if (!($WhatIf)) {
		# Forcibly close all connections on the target database
   		$server.KillAllProcesses($databaseName) 
   }
   else {
	   Write-Host "WhatIf: Kill all server proceses for '$databaseName'"
   }
	#create server users for db users to be re-assoicated
    if ($usersToReassociate -ne $null) {
        foreach ($user in $usersToReassociate.Keys) {
		   if (!($WhatIf)) {
	            write-host "Reassociating user: $user"
        	    Initialize-SqlLogin $null "$user" $usersToReassociate["$user"] -serverInstance $server
		   }
		   else {
			   Write-Host "WhatIf: Initializing Login '$user'"
   		   }
        }
    }

   # Restore the database
   # Trap { Write-Host -Fore Red -back White $_.Exception.ToString(); Break; };
   if (!($WhatIf)) {
	   $smoRestore.SqlRestore($server)
   }
   else {
	   Write-Host "WhatIf: Restoring '$databaseName'"
   }

   # Reassociate user accounts with logins on server
   # (Useful in scenarios where database is being restored on a different server)
   if ($usersToReassociate -ne $null) {
       $db = $server.Databases[$databaseName]

       foreach ($user in $usersToReassociate.Keys) {
			if (!($WhatIf)) {
					Write-Host "Reassociating user account '$user' ..."
					$query = "IF EXISTS (SELECT name FROM sys.database_principals WHERE name = `'$user`')"
					$query += "BEGIN `nALTER USER $user with LOGIN=$user `nEND"
					$db.ExecuteNonQuery($query)
			}
			else {
				Write-Host "WhatIf: Reassociating user account '$user'"
			}
       }
   }
}

Function Test-DatabaseExists([Microsoft.SqlServer.Management.Smo.Server]$server, $databaseName) {
    $found = $false
    #Makesure we have the latest database information.
    $server.Databases.Refresh($true)
    foreach ($db in $server.Databases) {
        if ($db.Name -eq $databaseName) {
            $found = $true
            break
        }
    }
    return $found
}

Function Backup-DbCore {
	[cmdletbinding()]
    param(
		[parameter(mandatory=$true,ParameterSetName="SMOServer")] [Microsoft.SqlServer.Management.Smo.Server] $server, 
		[parameter(mandatory=$true,ParameterSetName="ServerName")] [string] $sqlServer, 
		[parameter(mandatory=$true)] [string] $databaseName, 
		[parameter(ParameterSetName="ServerName")][string] $username = $null, 
		[parameter(ParameterSetName="ServerName")][System.Security.SecureString] $password = $null,
		[string]$backupDirectory, 
		[string]$backupFileName = $null, 
		[string]$action,
		[Switch]$WhatIf) 
 trap [Exception] { 
        write-error $("ERROR: " + $_.Exception.ToString()); 
        break; 
    }

	if($PSCmdlet.ParameterSetName -eq "ServerName") {
	    $server = Get-Server $sqlServer $username $password
	}
	else {
		$sqlServer = $server.Name
	}
    $local = @("localhost","127.0.0.1",$env:ComputerName,".",[System.Net.Dns]::GetHostByName("localhost").HostName)
	if (!([string]::IsNullOrEmpty($backupDirectory))){
		if (!($backupDirectory.EndsWith("\"))) {
			$backupDirectory += "\"
		}
	}
    if (Test-DatabaseExists $server $databaseName) {
		if($backupFileName -eq $null) {
			# Construct file names -- $timestamp = Get-Date -format yyyyMMddHHmmss
			if ($action -eq "log") {$bakFilePath = "$backupDirectory${databaseName}_log.bak"}
			else {$bakFilePath = "$backupDirectory$databaseName.bak"}
			$zipFilePath = "$backupDirectory$databaseName.zip"
		}
		else {
			$bakFilePath = "$backupDirectory$backupFileName"
		}
        
        #Run setup/clean up if the sql server isthe machine runing the script, or if it is a remote path.
        if($local -contains $server.Name -or ($backupDirectory.StartsWith("\\") -and (Test-Path "$([Io.Path]::GetPathRoot($backupDirectory))"))) {
            if (!($WhatIf)) {
				# Make sure the backup folder exists
    	        [IO.Directory]::CreateDirectory($backupDirectory) | Out-Null
			}
			ELSE{
				Write-Host "WhatIf: Creating Backup Directory"
			}

            # Delete the existing backup file
            if (Test-Path $bakFilePath) {
				if (!($WhatIf)) {
                	ri $bakFilePath
				}
				else {
					Write-Host "WhatIf: Delete $bakFilePath"
				}
            }
        }
        else { 
            Write-Host "The machine executing this script is not the the SQL Server and the backup path is not remote.`r`nLocal backup paths are local to the SQL server. Skipping preliminary backup path validations."
        }
        
        # Create a backup object
        $smoBackup = New-Object ("Microsoft.SqlServer.Management.Smo.Backup")
        
        $smoBackup.Action = $action
        $smoBackup.BackupSetDescription = "Full " + $action + " Backup for " + $databaseName
        $smoBackup.BackupSetName = $databaseName + " " + $action + " Backup"
        $smoBackup.CompressionOption = "On"
        $smoBackup.Database = $databaseName
        $smoBackup.MediaDescription = "Disk"
        $smoBackup.Devices.AddDevice($bakFilePath, "File")
        
		if (!($Whatif)) {
			$smoBackup.SqlBackup($server)
		}
		else {
			Write-Host "WhatIf: Back up $databaseName to $bakFilePath"
		}

        return $bakFilePath
    }
    else {
		if ($action -eq "log") {Write-Host "Cannot backup log, database: $databaseName`nIt was not found to exist on server: $sqlServer"}
        else {Write-Host "Cannot backup database: $databaseName`nIt was not found to exist on server: $sqlServer"}
    }
}




Export-ModuleMember -Function Install-DacPac
