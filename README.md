# PS-Logging
This is a powershell module that provide logging to file as well as outputting it in console. Normally you can just use write-host and pipe those text into a log file but its lacking information like hostname, timestamp ...etc , this logging module will automatically append those things for you. You will have to specify the full path or the relative path to the logfile and set it in the enviornmental variable $env:logfile

For logging, it provide three logging level

1. Log-Info
2. Log-Error
3. Log-Debug

Each log level will inject a tag inside the log line to indicate the log level.

Apart from the log function above, it also provide a log rotation (log-rotate) and log archive (log-archive) function. The log archive function uses Compress-Archive cmdlet which is only available in powershell 5.0 and above. 

Log-Rotate:
This function only support daily rotation for now and require the location of the logfile you wanted to rotate as well as the folder name of where you want to rotated (old) log reside on. The rotated log will have a ddMMyyyy prefix to it. If the old log folder has a file with the same name, it will automatically rename the duplicated file with a counter at the end, this counter goes up to 999 and after that it will be over written. The lower the counter number means the log is newer. 

Log-Archive:
This function scan a folder you specify (sourcefolder) and will pack all file within that folder that falls into the retention ($env:LogRetention) you specify into a archive file using the Compress-Archive cmdlet. It also require you to specify the name of the archived file (Destination)

To use this library, you need to either place it into the default powershell module path $env:PSModulePath or you have to add the path where this module reside to the $env:PSModulePath like this

```
Param (

    # Set the working directory
    [string]$WorkDir = (Split-Path $MyInvocation.MyCommand.Path),

    # custom library location 
    [string]$lib = (join-path $WorkDir "lib")
)
# if library location is a relative path, append the working directory in front to make it a absolute path
If (!([System.IO.Path]::IsPathRooted($lib)))
{
    $lib = (join-path $WorkDir $lib)        
}

# Add the custom library location in the the PSModulePath env variable 
$env:PSModulePath = $env:PSModulePath + ";$lib"

# Load the logging module
Import-Module logging -ErrorAction Stop

```

If you are loading this in a interactive powershell session, assuming you place the module in the current folder

```
$env:PSModulePath = $env:PSModulePath + ";$pwd"
import-module logging

```

The .psm file will have to be place inside a folder in the $env:PSModulePath
