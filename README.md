# PS-Logging
This is a powershell module that provide logging to file, normally you can just use write-host and pipe those text into a log file but its lacking information like hostname, timestamp ...etc , this logging module will automatically append those things for you.

For logging, it provide three logging level

1. Log-Info
2. Log-Error
3. Log-Debug

Each log level will inject a tag inside the log line to indicate the log level.

Apart from the log function above, it also provide a log rotation and log archive function. The log archive function uses Compress-Archive cmdlet which is only available in powershell 5.0 and above. 


To use this library, you need to either place it into the default powershell module path $env:PSModulePath or you have to add the path where this module reside to the $env:PSModulePath like this

...
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
Import-Module logging.psm1 -ErrorAction Stop

...

The .psm file will have to be place inside a folder
