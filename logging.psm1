# This is a library for standize the logging 

# logging function
function log-info()
{
	Param  
    (                 
        [alias("message")][string]$logstring,
		[string]$logfile = $env:logfile,
		[string]$color,
		[string]$app = $env:app,
		[string]$SessionID = $env:SessionID
    )   
	
	if (!$logstring) 
	{ 
		write-host "Error!!! no log is passed to the logging function" -foregroundcolor red
		return
	}
	
	if (!$app)
	{
		$app = "UnknownApp"
	}
	
	if (!$SessionID)
	{
		$SessionID = "-"
	}
	
	if (!$color) {$color = "white"}
	write-host $logstring -foregroundcolor $color
	if ($logfile) 
	{
		$CurrentDateTime = get-date -format "MMM dd yyyy HH:mm:ss"		
		$logstring =  "$CurrentDateTime $([System.Net.Dns]::GetHostByName(($env:computerName))).Hostname) $app [" + $sessionID + "] [INFO] : $logstring"
		$logstring | out-file -Filepath $logfile -append -encoding ASCII
	}	
}

# Set an alias for backward compability 
Set-Alias -Name log -Value log-info

function log-error()
{
	Param  
    (                 
		[alias("message")][string]$logstring,
		[string]$logfile = $env:logfile,
		[string]$color,
		[string]$app = $env:app,
		[string]$SessionID = $env:SessionID				
    )   
    
	if (!$logstring) 
	{ 
		write-host "Error!!! no log is passed to the logging function" -foregroundcolor red
		return
	}
	
	if (!$app)
	{
		$app = "UnknownApp"
	}
		
	if (!$SessionID)
	{
		$SessionID = "-"
	}
	
	if (!$color) {$color = "Red"}
	write-host $logstring -foregroundcolor $color
	if ($logfile) 
	{
		$CurrentDateTime = get-date -format "MMM dd yyyy HH:mm:ss"
		$logstring =  "$CurrentDateTime $([System.Net.Dns]::GetHostByName(($env:computerName))).Hostname) $app [" + $sessionID + "] [ERROR] : $logstring"
		$logstring | out-file -Filepath $logfile -append -encoding ASCII
		
	}
}

function log-debug()
{
	Param  
    (                 
		[alias("message")][string]$logstring,
		[string]$logfile = $env:logfile,
		[string]$color,
		[string]$app = $env:app,
		[string]$SessionID = $env:SessionID,
		[string]$debug			
    )   
	
	if (($debug) -and ($debug -ne "SilentlyContinue"))
	{
		if (!$logstring) 
		{ 
			write-host "Error!!! no log is passed to the logging function" -foregroundcolor red
			return
		}
	
		if (!$app)
		{
			$app = "UnknownApp"
		}
		
		if (!$SessionID)
		{
			$SessionID = "-"
		}
	
		if (!$color) {$color = "Yellow"}
		write-host $logstring -foregroundcolor $color
		if ($logfile) 
		{
			$CurrentDateTime = get-date -format "MMM dd yyyy HH:mm:ss"
			$logstring =  "$CurrentDateTime $([System.Net.Dns]::GetHostByName(($env:computerName))).Hostname) $app [" + $sessionID + "] [DEBUG] : $logstring"
			$logstring | out-file -Filepath $logfile -append -encoding ASCII
		}	
	}
}


function logrotate ()
{
    Param (
        [String]$logfile = $env:logfile,
        [String]$oldlogfolder
    )

    # If logfile doesn't exist, just skip the logrotate
    If (!(Test-Path $logfile))
    {
        Write-host "$logfile does not exist, skipping the logrotate"
        Return 1
    }
    else 
    {
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
                                Write-Warning "This is a fatal error, exiting the script..."
                                Exit 1
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
                    Write-Warning "This is a fatal error, exiting the script..."
                    Exit 1
                }
            }
            Rename-Item -LiteralPath $logfile -NewName $Oldlogfile
            Move-Item -LiteralPath $Oldlogfile -Destination $oldlogfolder -ErrorVariable err
            if (!$err)
            {
                write-host "Successfully rotated the $logfile to $oldlogfolder\$oldlogfile"
            }
            else 
            {
                Write-Warning "Failed to rotate $logfile"
                Write-Warning "$err" 
            }
        }
    }
}

# Function to Archive the log
function LogArchive () 
{
    Param (
        [string]$Source,
        [string]$Destination,
        [int16]$LogRetention = $env:LogRetention
    )    

    # Validate the source 
    If (!(Test-Path $Source))
    {
        Write-Warning "Error!!! $Source does not exist, not going ahead with the archive process"
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
            Return 1                   
        }
        # Check if source is a file or folder
        $SourcFolderExtenstion = $SourceFolder.Extension
        If ($SourcFolderExtenstion)
        {
            Write-Warning "Error!!! $Source is a file, it needs to be a folder, not going ahead with the log archive process"
            Return 1
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
            Return 1
        }
        
        # Check if destination is a file or folder
        $ArchiveFileExtension = $ArchiveFile.Extension
        If (!$ArchiveFileExtension)
        {
            Write-Warning "Error!!! $Destination is a folder, it needs to be a file, not going ahead with the log archive process"
            Return 1
        }
        else 
        {
            # Check the folder if it doesn't exist
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
                    Return 1
                }
                else 
                {
                    Write-Host "Successfully created $ArchiveFilePath"    
                }                
            }    
        }
        
        # Passed all validation, start the log archive process

        # Build an array of all file that needs to be archive
        $ArchiveFileArr = Get-ChildItem -File $Source | where { $_.LastWriteTime -lt (Get-Date).AddDays(-$Logretention)}
        Foreach ($File in $ArchiveFileArr)
        {
            $FileToAdd = $File.FullName
            Compress-Archive -LiteralPath $FileToAdd -Update -DestinationPath $Destination -ErrorVariable err
            if ($err)
            {
                Write-Warning "Failed to archive $FileToAdd to $Destination"
            }
            Remove-Item -Force -Path $FileToAdd
        }        
    }
}
