# This is a library for standize the logging to RFC5424 format
# https://tools.ietf.org/html/rfc5424.html


# logging function
function log-info()
{
    [CmdletBinding()]
    Param  
    (
        [alias("message")][string]$logstring,
        [string]$logfile = $env:logfile,
        [string]$color,
        [string]$app = $env:app,
        [string]$SessionID = $env:SessionID,
        [ValidateRange(0,23)][int16]$Facility = $env:facility
    )   
    
    Process {

        # Set the Severity level https://tools.ietf.org/html/rfc5424.html#section-6.2.1
        $Severity = 6
        $Version = 1

        #If no facility is passed into the function we use local0 for the default https://tools.ietf.org/html/rfc5424.html#section-6.2.1
        If (!$Facility)
        {
            $Facility = 16
        }

        # Calculate the priority, The Priority value is calculated by first multiplying the Facility number by 8 and then adding the numerical value of the Severity. 
        $Priority = '<' + (($Facility * 8) + $Severity) + '>'

	    if (!$logstring) 
	    { 
		    write-host "Error!!! no log is passed to the logging function" -foregroundcolor red
		    return 1
	    }
	
	    if (!$app)
	    {
            # check if the command is invoked inside a runspace (interactive powershell session) or external request (call from a script)
            If ($MyInvocation.CommandOrigin -eq "Runspace")
            {
                # This is running directly from a powershell session
                # Get the Parent PID 
                $ppid = (Get-WmiObject win32_process | Where-Object processid -eq  $pid).parentprocessid
                # Set the app name to the Process name of the Parent Pid
                $app = (Get-Process -Id $ppid).ProcessName                
            }
            else
            {    
                # This is running from a script
                $app = $MyInvocation.ScriptName
                if ($app)
                {
                    # Set the name to the calling script name if this script is called from another script / function
                    $app = $MyInvocation.ScriptName.Replace((Split-Path $MyInvocation.ScriptName),'').TrimStart('\')
                }
                else
                {
                    # If we still cant get the calling script name, we just leave it as "-"
                    $app = "powershell-$($env:username)"
                }
            }
	    }
	
	    if (!$SessionID)
	    {
    		$SessionID = $PID
    	}
	
    	if (!$color) {$color = "white"}
	    write-host $logstring -foregroundcolor $color
	    if ($logfile) 
	    {
            $CurrentDateTime = get-date -format "yyyy-MM-ddTHH:mm:ss.ffffffzzz"	
            $FQDN = $([System.Net.Dns]::GetHostByName(($env:computerName))).Hostname
		    $logstring =  "$Priority$Version $CurrentDateTime $FQDN $app $sessionID [INFO] - $logstring"
            $logstring | out-file -Filepath $logfile -append -encoding ASCII -ErrorVariable err
            if ($err)
            {
                write-host "Error!!! failed to write the log to $logfile"
                write-host "$err"
                return 1
            }
        }	    
    }
}

function log-error()
{
    [CmdletBinding()]
	Param  
    (
        [alias("message")][string]$logstring,
        [string]$logfile = $env:logfile,
        [string]$color,
        [string]$app = $env:app,
        [string]$SessionID = $env:SessionID,
        [ValidateRange(0,23)][int16]$Facility = $env:Facility
    )   

    Process {

        # Set the Severity level https://tools.ietf.org/html/rfc5424.html#section-6.2.1
        $Severity = 3
        $Version = 1

        #If no facility is passed into the function we use local0 for the default https://tools.ietf.org/html/rfc5424.html#section-6.2.1
        If (!$Facility)
        {
            $Facility = 16
        }

        # Calculate the priority, The Priority value is calculated by first multiplying the Facility number by 8 and then adding the numerical value of the Severity. 
        $Priority = '<' + (($Facility * 8) + $Severity) + '>'

	    if (!$logstring) 
	    { 
    		write-host "Error!!! no log is passed to the logging function" -foregroundcolor $color
		    return 1
	    }
	
        if (!$app)
	    {
            # check if the command is invoked inside a runspace (interactive powershell session) or external request (call from a script)
            If ($MyInvocation.CommandOrigin -eq "Runspace")
            {
                # This is running directly from a powershell session
                # Get the Parent PID 
                $ppid = (Get-WmiObject win32_process | Where-Object processid -eq  $pid).parentprocessid
                # Set the app name to the Process name of the Parent Pid
                $app = (Get-Process -Id $ppid).ProcessName                
            }
            else
            {    
                # This is running from a script
                $app = $MyInvocation.ScriptName
                if ($app)
                {
                    # Set the name to the calling script name if this script is called from another script / function
                    $app = $MyInvocation.ScriptName.Replace((Split-Path $MyInvocation.ScriptName),'').TrimStart('\')
                }
                else
                {
                    # If we still cant get the calling script name, we just leave it as "-"
                    $app = "powershell-$($env:username)"
                }
            }               
	    }
		
    	if (!$SessionID)
	    {   
    		$SessionID = $pid
    	}
	
    	if (!$color) {$color = "Red"}
    	write-host $logstring -foregroundcolor $color
    	if ($logfile) 
    	{
	    	$CurrentDateTime = get-date -format "yyyy-MM-ddTHH:mm:ss.ffffffzzz"	
            $FQDN = $([System.Net.Dns]::GetHostByName(($env:computerName))).Hostname
		    $logstring =  "$Priority$Version $CurrentDateTime $FQDN $app $sessionID [ERROR] - $logstring"        
            $logstring | out-file -Filepath $logfile -append -encoding ASCII -ErrorVariable err
            if ($err)
            {
                write-host "Error!!! failed to write the log to $logfile"
                write-host "$err"
                return 1
            }
        }	
    }
}

function log-debug()
{
    [CmdletBinding()]
	Param  
    (
        [alias("message")][string]$logstring,
        [string]$logfile = $env:logfile,
        [string]$color,
        [string]$app = $env:app,
        [string]$SessionID = $env:SessionID,
        [ValidateRange(0,23)][int16]$Facility = $env:Facility
    )   

    Process {
        
        # Set the Severity level https://tools.ietf.org/html/rfc5424.html#section-6.2.1
        $Severity = 7
        $Version = 1

        #If no facility is passed into the function we use local0 for the default https://tools.ietf.org/html/rfc5424.html#section-6.2.1
        If (!$Facility)
        {
            $Facility = 16
        }

        # Calculate the priority, The Priority value is calculated by first multiplying the Facility number by 8 and then adding the numerical value of the Severity. 
        $Priority = '<' + (($Facility * 8) + $Severity) + '>'

	    if ($DebugPreference -ne "SilentlyContinue")
	    {
		    if (!$logstring) 
		    { 
			    write-host "Error!!! no log is passed to the logging function" -foregroundcolor $color
			    return 1
		    }
	
		    if (!$app)
	        {
                # check if the command is invoked inside a runspace (interactive powershell session) or external request (call from a script)
                If ($MyInvocation.CommandOrigin -eq "Runspace")
                {
                    # This is running directly from a powershell session
                    # Get the Parent PID 
                    $ppid = (Get-WmiObject win32_process | Where-Object processid -eq  $pid).parentprocessid
                    # Set the app name to the Process name of the Parent Pid
                    $app = (Get-Process -Id $ppid).ProcessName                
                }
                else
                {    
                    # This is running from a script
                    $app = $MyInvocation.ScriptName
                    if ($app)
                    {
                        # Set the name to the calling script name if this script is called from another script / function
                        $app = $MyInvocation.ScriptName.Replace((Split-Path $MyInvocation.ScriptName),'').TrimStart('\')
                    }
                    else
                    {
                        # If we still cant get the calling script name, we just leave it as "-"
                        $app = "powershell-$($env:username)"
                    }
                }
	        }
		
    		if (!$SessionID)
	    	{
		    	$SessionID = $pid
		    }
	
		    if (!$color) {$color = "Yellow"}
		    write-host $logstring -foregroundcolor $color
		    if ($logfile) 
		    {
                $CurrentDateTime = get-date -format "yyyy-MM-ddTHH:mm:ss.ffffffzzz"	
                $FQDN = $([System.Net.Dns]::GetHostByName(($env:computerName))).Hostname
                $logstring =  "$Priority$Version $CurrentDateTime $FQDN $app $sessionID [DEBUG] - $logstring"
                $logstring | out-file -Filepath $logfile -append -encoding ASCII -ErrorVariable err
                if ($err)
                {
                    write-host "Error !!! failed to write the log to $logfile"
                    write-host "$err"
                    return 1
                }
            }
        }            
	}
}

function log-verbose()
{
    [CmdletBinding()]
	Param  
    (
        [alias("message")][string]$logstring,
        [string]$logfile = $env:logfile,
        [string]$color,
        [string]$app = $env:app,
        [string]$SessionID = $env:SessionID,
        [ValidateRange(0,23)][int16]$Facility = $env:Facility
    )   

    Process {
        
        # Set the Severity level https://tools.ietf.org/html/rfc5424.html#section-6.2.1
        $Severity = 7
        $Version = 1

        #If no facility is passed into the function we use local0 for the default https://tools.ietf.org/html/rfc5424.html#section-6.2.1
        If (!$Facility)
        {
            $Facility = 16
        }

        # Calculate the priority, The Priority value is calculated by first multiplying the Facility number by 8 and then adding the numerical value of the Severity. 
        $Priority = '<' + (($Facility * 8) + $Severity) + '>'

	    if ($VerbosePreference -ne "SilentlyContinue")
	    {
		    if (!$logstring) 
		    { 
			    write-host "Error!!! no log is passed to the logging function" -foregroundcolor $color
			    return 1
		    }
	
		    if (!$app)
	        {
                # check if the command is invoked inside a runspace (interactive powershell session) or external request (call from a script)
                If ($MyInvocation.CommandOrigin -eq "Runspace")
                {
                    # This is running directly from a powershell session
                    # Get the Parent PID 
                    $ppid = (Get-WmiObject win32_process | Where-Object processid -eq  $pid).parentprocessid
                    # Set the app name to the Process name of the Parent Pid
                    $app = (Get-Process -Id $ppid).ProcessName                
                }
                else
                {    
                    # This is running from a script
                    $app = $MyInvocation.ScriptName
                    if ($app)
                    {
                        # Set the name to the calling script name if this script is called from another script / function
                        $app = $MyInvocation.ScriptName.Replace((Split-Path $MyInvocation.ScriptName),'').TrimStart('\')
                    }
                    else
                    {
                        # If we still cant get the calling script name, we just leave it as "-"
                        $app = "powershell-$($env:username)"
                    }
                }
	        }
		
    		if (!$SessionID)
	    	{
		    	$SessionID = $pid
		    }
	
		    if (!$color) {$color = "Blue"}
		    write-host $logstring -foregroundcolor $color
		    if ($logfile) 
		    {
                $CurrentDateTime = get-date -format "yyyy-MM-ddTHH:mm:ss.ffffffzzz"	
                $FQDN = $([System.Net.Dns]::GetHostByName(($env:computerName))).Hostname
                $logstring =  "$Priority$Version $CurrentDateTime $FQDN $app $sessionID [VERBOSE] - $logstring"
                $logstring | out-file -Filepath $logfile -append -encoding ASCII -ErrorVariable err
                if ($err)
                {
                    write-host "Error !!! failed to write the log to $logfile"
                    write-host "$err"
                    return 1
                }
            }
        }            
	}
}


function log-rotate ()
{
    Param (
        [String]$logfile = $env:logfile,
        [String]$oldlogfolder
    )

    # If logfile doesn't exist, just skip the logrotate
    If (!(Test-Path $logfile))
    {
        Write-host "$logfile does not exist, skipping the logrotate"
        return 1
    }
    else 
    {
        # Check the old log folder and create it if it doesn't exist
        if (!(Test-Path -PathType Container $oldlogfolder))
        {
            write-host "$oldlogfolder does not exist, creating it..."
            New-Item -ItemType Directory -Path $oldlogfolder -ErrorVariable err
            if ($err)
            {
                Write-Warning "Error!!! Failed to create $oldlogfile"
                Write-Warning "$err"
                return 1                
            }
            else 
            {
                Write-host "Successfully created $oldlogfolder"    
            }
        }
        
        # Get the last modify date of the logfile
        $lastmodify = (Get-ItemProperty -Path $logfile).LastWriteTime
    
        # Get today date
        $Today = Get-Date

        # check if the logfile is old
        if (($lastmodify).Date -lt ($Today.Date))
        {
            write-host "$logfile is old, renaming it with a timestamp..."
            $Oldlogfile = $lastmodify.ToString("ddMMyyyy") + '-' + $logfile
            # Check if there is an old log with the same name in the old log folder, if so, rotate it before the rename & move
            If (Test-Path (Join-Path $oldlogfolder $oldlogfile))
            {
                Write-host "$Oldlogfile already exist in $OldLogFolder, rotating it before moving the log"
                # Sort the file in natural order and Descending https://stackoverflow.com/questions/5427506/how-to-sort-by-file-name-the-same-way-windows-explorer-does
                $Files = Get-ChildItem -file $oldlogfolder | Sort-Object -Descending { [regex]::Replace($_.Name, '\d+', { $args[0].Value.PadLeft(20) }) }
                foreach ($file in $Files)
                {
                    $Filename = $file.Name
                    $FileFullPath = $File.FullName
                    Write-Verbose "Working on file $Filename"              
                    $Counter = 999
                    Do
                    {                   
                        $NewCounter = $Counter + 1
                        $FileToRotate = $Oldlogfile + '.' + $Counter
                        $FileAfterRotate = $Oldlogfile + '.' + $NewCounter

                        Write-Verbose "FileToRotate: $FileToRotate FileAfterRotate: $FileAfterRotate"

                        if ($FileName -eq $FileToRotate)
                        {
                            Write-host "Renaming $FileToRotate to $FileAfterRotate"
                            Rename-Item -LiteralPath $FileFullPath -NewName $FileAfterRotate -ErrorVariable err
                            if ($err)
                            {
                                Write-Warning "Failed to rotate $FileToRotate"
                                Write-Warning "$err"         
                                return 1
                            }
                        }
                        $Counter--
                    }
                    Until ($Counter -eq -1)
                }
                Rename-Item -LiteralPath $OldLogFolder\$Oldlogfile -NewName "$OldLogFile.0" -ErrorVariable err
                if ($err)
                {
                    Write-Warning "Failed to Rotate $oldlogfile"
                    Write-Warning "$err"
                    return 1
                }
            }
            Rename-Item -LiteralPath $logfile -NewName $Oldlogfile
            Move-Item -LiteralPath $Oldlogfile -Destination $oldlogfolder -ErrorVariable err
            if (!$err)
            {
                write-host "Successfully rotated the $logfile to $oldlogfolder\$oldlogfile"
                return 0
            }
            else 
            {
                Write-Warning "Failed to rotate $logfile"
                Write-Warning "$err" 
                return 1
            }
        }
    }
}

# Function to Archive the log
function Log-Archive () 
{
    Param (
        [string]$Source,
        [alias("Archive")][string]$Destination,
        [int16]$LogRetention = $env:LogRetention
    )    

    # Validate the source 
    If (!(Test-Path $Source))
    {
        Write-Warning "Error!!! $Source does not exist, not going ahead with the archive process"
        return 1
    }
    else 
    {
        # validate the Source
        try 
        {
            $SourceFolder = [System.IO.FileInfo]$Source    
        }
        catch 
        {
            $ErrMsg = $_.Exception.Message
            Write-Warning "$ErrMsg"
            Write-Warning "$Source is not a valid path, exiting the log archive process"
            return 1                   
        }
        # Check if source is a file or folder
        $SourcFolderExtenstion = $SourceFolder.Extension
        If ($SourcFolderExtenstion)
        {
            Write-Warning "Error!!! $Source is a file, it needs to be a folder, not going ahead with the log archive process"
            return 1
        }

        # validate the destination
        Try 
        {
            $ArchiveFile = [System.IO.FileInfo]$Destination
        }  
        Catch 
        {
            $ErrMsg = $_.Exception.Message
            Write-Warning "$ErrMsg"
            Write-Warning "$Destination is not a valid path, exiting the log archive process"
            return 1
        }
        
        # Check if destination is a file or folder
        $ArchiveFileExtension = $ArchiveFile.Extension
        If (!$ArchiveFileExtension)
        {
            Write-Warning "Error!!! $Destination is a folder, it needs to be a file, not going ahead with the log archive process"
            return 1
        }
        else 
        {
            # Check the folder and create it if it doesn't exist
            $ArchiveFilePath = Split-Path $Destination
            If (!(Test-Path -PathType Container $ArchiveFilePath))
            {
                write-host "$ArchiveFilePath does not exist, creating it..."
                New-Item -ItemType Directory -Path "$ArchiveFilePath" -ErrorVariable err
                if ($err)
                {
                    Write-Warning "Error!!! Failed to create $ArchiveFilePath"
                    Write-Warning "$err"
                    Write-Warning "This is a fatal error, exiting the log Archive process..."
                    return 1
                }
                else 
                {
                    Write-Host "Successfully created $ArchiveFilePath"    
                }                
            }    
        }
        
        # Passed all validation, start the log archive process

        # Build an array of all file that needs to be archive
        $ArchiveFileArr = Get-ChildItem -File $Source | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$Logretention)}
        Foreach ($File in $ArchiveFileArr)
        {
            $FileToAdd = $File.FullName
            Compress-Archive -LiteralPath $FileToAdd -Update -DestinationPath $Destination -ErrorVariable err
            if ($err)
            {
                Write-Warning "Failed to archive $FileToAdd to $Destination"
                return 1
            }
            Remove-Item -Force -Path $FileToAdd
        }        
        return 0
    }
}

# Set an alias for backward compability 
Set-Alias -Name log -Value log-info
Set-Alias -Name logarchive -Value Log-Archive
Set-Alias -Name logrotate -Value Log-Rotate

# Export only the necessary function and Alias
Export-ModuleMember -Function log-info, log-error, log-debug, log-verbose, log-archive, log-rotate -Alias log, logarchive, logrotate