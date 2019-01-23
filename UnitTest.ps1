# Add the current path to the PSModule path
$env:PSModulePath = $env:PSModulePath + ";" + $(pwd)

# Load the the logging module
Import-Module logging

# Set a err counter at the beginning for reporting purpose
$errcounter = 0

# Set a name of he report
$testreport = "testreport.txt"

# Create a worksapce for this test
$workspace = "unittestworkspace"
if ((Test-Path -Path $workspace)) {
    Remove-Item -Path $workspace
}
New-Item -ItemType Directory -Path $workspace

# Testing the log-info function
function test-loginfo {

    Write-host "Testing the log-info function"
    
    # Set the logfile name for this test
    $logfile = Join-Path $workspace "test-loginfo.log"

    # Negative testing, if nothing passed to the function, it should return 1
    $result = log-info
    If ($result -eq 1)
    {
        $msg = "log-info function Passed the Negative test"
        Write-host $msg
        $msg | Out-File -FilePath $testreport -Append -Encoding ascii
    }
    else 
    {
        $msg = "log-info function returns code is 1, Failed the Negative test"
        Write-host $msg
        $msg | Out-File -FilePath $testreport -Append -Encoding ascii
        $errcounter ++
    }

    # validate the syslog outputed to the logfile
    $result1 = log-info "Test1" -logfile $logfile
    $result2 = log-info "Test2" -logfile $logfile
    $result3 = log-info "Test3" -logfile $logfile
    If ( ($result1 -eq 1) -or ($result2 -eq 1) -or ($result3 -eq 1) )
    {
        $msg = "log-info function returns code is 1, failed the logfile output test"
        write-host $msg
        $msg | Out-File -FilePath $testreport -Append -Encoding ascii
        $errcounter ++
    }
    
    $file = Get-content $logfile
        
    $PriArr = @()
    $timestampArr = @()
    $hostnameArr = @()
    $appArr = @()
    $pidArr = @()
    $msgidArr = @()
    $structureddataArr = @()
    $msgArr = @()

    foreach ($line in $file)
    {
        $items = $line.Split(" ")
          
        # store Priority into an array to do further validation
        $PriArr += $items[0]

        # store the timestamp into an array to do further validation
        $timestampArr += $items[1]

        # store the hostname into an array to do further validation
        $HostnameArr += $items[2]

        # store the appname into an array to do further validation
        $appArr += $items[3]

        # store the process id into an array to do further validation
        $pidArr += $items[4]

        # store the message id into an array to do further validation
        $msgidArr += $items[5]

        # store the structureddata into an array to do further validation
        $structureddataArr += $items[6]

        # store the message into an array to do further validation
        $msgArr += $items[7]

        # If each line contains less than 8 items, this is a invalid rfc5424 syslog format
        if ($items.Count -lt 8)
        {
            $msg = "Invalid syslog format found in the logfile, it contains less than 8 fields, log-info failed the logfile output test"
            Write-Host $msg
            $msg | Out-File -FilePath $testreport -Append -Encoding ascii
            $errcounter ++
        }
    }

    # validate the Priority
    Foreach ($pri in $PriArr){
        
        # 1 Priority must have < and > wrap around it 
        If (!($Pri.StartsWith("<"))) {
            $msg = "Priority does not start with <"
            write-host $msg
            $msg | Out-File -FilePath $testreport -Append -Encoding ascii
        }
        if ( $($pri.ToCharArray())[-2] -ne ">" ){
            $msg = "Priority does not wrap around with >"
            write-host $msg
            $msg | Out-File -FilePath $testreport -Append -Encoding ascii
        }
        
        # 2 Priority must be no longer than 5 charactors (including the <> and the version number)
        If ( $pri.Length -gt 5) {
            $msg = "Priority is longer than 5 charactors"
            write-host $msg
            $msg | Out-File -FilePath $testreport -Append -Encoding ascii
        }
        
        # 3 Priority must be number

        # 4 Priority must end with a Version number and it must be a single digit number
        if ( $($($pri.ToCharArray())[-1]).ToInt16() ) {
            $msg = "Priority does not end with a version number"
            write-host $msg
            $msg | Out-File -FilePath $testreport -Append -Encoding ascii
        }

        # 5 Priority must be with in range, min = 0 * 8 + 6 = 6 , Max = 23 * 8 + 6 = 190 
    }        
    
    # validate the timestamp
    # timestamp must compliant with iso8601 standard
    # The "T" and "Z" characters in this syntax MUST be upper case.
    # Usage of the "T" character is REQUIRED.
    # Leap seconds MUST NOT be used, this means the second cannot be 60 https://tools.ietf.org/html/rfc3339#appendix-D
    # nano sec can not be longer than 6 digit 

    # validate the hostname
    # The hostname in the log should be the FQDN of the machine that run the unit test $([System.Net.Dns]::GetHostByName(($env:computerName))).Hostname

    # validate the appname
    # The appname should be the name of the unit test script UnitTest.ps1

    # validate the process ID
    # Pid must be a number

    # validate the message ID
    # it needs to be [info]

    # validate the structured data
    # it has be be the nilvalue "-" for now as the logging module doesn't support structured data at this stage

    # validate the message
    # confrim test1, test2 and test3 is in the message
}
# Run the log-info test
test-loginfo

# Set the environment variable
$env:logfile = "test.log"

log-info "Test"