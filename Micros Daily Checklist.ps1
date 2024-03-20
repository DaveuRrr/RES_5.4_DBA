# Micros Daily Checklist ps1 file for GBMO, LLC written by David Bahena
Write-Host "GBMO, LLC Daily Checklist for Micros POS Stores"

# Variables for this Powershell
$date = Get-Date -UFormat %m-%d-%Y
$rota = (Get-Date).Adddays(-15).ToString("MM-dd-yyyy")
$sour = "D:\Micros\Database\Data\micros.db"
$dest = "D:\Micros\Database\Data\Archive\micros(" + $date + ").db"
$rt15 = "D:\Micros\Database\Data\Archive\micros(" + $rota + ").db"
    
# Start turning off the Database
Start-Process "CLControl" -ArgumentList "/System Idle" -NoNewWindow

# Loops while the CLControl is still turning off the database
While (Get-Process "CLControl" -ErrorAction SilentlyContinue)
    {
        Write-Host (Get-Date).ToString() "Database is still powering down"
        Start-Sleep -S 10
    }

$CLCStatus = (Start-Process "CLControl" -ArgumentList "/System Status" -PassThru -Wait -NoNewWindow).ExitCode
# Check to make sure the Database is off
While ($CLCStatus -ne 1)
    {
        Write-Host (Get-Date).ToString() "Database is still on, checking again in 10 seconds"
        $CLCStatus
        Start-Sleep -S 10
    }
If ($CLCStatus -eq 1)
    {
        Write-Host (Get-Date).ToString() "Database is off, Starting to make a Database copy"
    }


# Start making a copy
Start-Sleep -s 10
If(-Not (Test-Path "D:\Micros\Database\Data\Archive\"))
    {
        Write-Host "I created the Directory D:\Micros\Database\Data\Archive\ because it didn't exist"
        New-Item -ItemType directory -Path "D:\Micros\Database\Data\Archive\"
    }

If(Test-Path $sour)
    {
        Copy-Item $sour -Destination $dest
        Write-Host (Get-Date).ToString() "Copied" $sour "and renamed to" $dest
    }
    
# Removes the 15 day old copy
If(Test-Path $rt15)
    {
        Remove-Item $rt15
        Write-Host (Get-Date).ToString() "Removed the 15 day old database copy"
    }

# Rebuilds the database and removes the old Micros.log file #>
Start-Process "DM" -ArgumentList "-uid dba -pwd Password1 -R -Q" -NoNewWindow

# Loops while the DM is still running
While (Get-Process "DM" -ErrorAction SilentlyContinue)
    {
        Write-Host (Get-Date).ToString() "Rebuilding Database, please wait"
        Start-Sleep -S 60
    }


# Goes throught the Daily Checklist for Micros POS stores    
Write-Host (Get-Date).ToString() "Finished with the Rebuild. Starting the Daily Checklist"


# Stop Micros KDS Controller and deleting files for amnesia
Write-Host (Get-Date).ToString() "Stopping Micros KDS Controller"
Stop-Service -DisplayName "Micros KDS Controller" -Force
If(Test-Path C:\MICROS\Res\KDS\Etc\KDSPost.dat)
    {
        Remove-Item C:\MICROS\Res\KDS\Etc\KDSPost.dat
        Write-Host (Get-Date).ToString() "Deleted C:\MICROS\Res\KDS\Etc\KDSPost.dat"
    }
If(Test-Path C:\MICROS\Res\KDS\Etc\KdscOrderUpdate.bin)
    {
        Remove-Item C:\MICROS\Res\KDS\Etc\KdscOrderUpdate.bin
        Write-Host (Get-Date).ToString() "Deleted C:\MICROS\Res\KDS\Etc\KdscOrderUpdate.bin"
    }
If(Test-Path C:\MICROS\Res\KDS\Etc\KdscOrderUpdate.old)
    {
        Remove-Item C:\MICROS\Res\KDS\Etc\KdscOrderUpdate.old
        Write-Host (Get-Date).ToString() "Deleted C:\MICROS\Res\KDS\Etc\KdscOrderUpdate.old"
    }
If(Test-Path C:\MICROS\Res\KDS\Etc\KdscOrderImage.bin)
    {
        Remove-Item C:\MICROS\Res\KDS\Etc\KdscOrderImage.bin
        Write-Host (Get-Date).ToString() "Deleted C:\MICROS\Res\KDS\Etc\KdscOrderImage.bin"
    }
If(Test-Path C:\MICROS\Res\KDS\Etc\KdscOrderImage.old)
    {
        Remove-Item C:\MICROS\Res\KDS\Etc\KdscOrderImage.old
        Write-Host (Get-Date).ToString() "Deleted C:\MICROS\Res\KDS\Etc\KdscOrderImage.old"
    }
If(Test-Path C:\MICROS\Res\KDS\Etc\KdsController.log)
    {
        Remove-Item C:\MICROS\Res\KDS\Etc\KdsController.log
        Write-Host (Get-Date).ToString() "Deleted C:\MICROS\Res\KDS\Etc\KdsController.log"
    }

# Kills if ReportExporter is still running
If (Get-Process "ReportExporter.exe" -ErrorAction SilentlyContinue)
    {
        Stop-Process -Name "ReportExporter.exe" -Force
        Write-Host (Get-Date).ToString() "Killed ReportExporter.exe"
    }

# Kills if MicrosRemotinService is still running
If (Get-Process "MicrosRemotingService.exe" -ErrorAction SilentlyContinue)
    {
        Stop-Process -Name "MicrosRemotingService.exe" -Force
        Write-Host (Get-Date).ToString() "Killed MicrosRemotingService.exe"
    }

# Force Restarting Services
Write-Host (Get-Date).ToString() "Force Restarting Services"
Restart-Service -DisplayName "Micros Distributed Service Manager" -Force
Restart-Service -DisplayName "Micros Remoting Service" -Force
Restart-Service -DisplayName "Micros MDS HTTP Service" -Force
Restart-Service -DisplayName "Micros Credit Card Server" -Force

# Starting Micros KDS Controller"
Write-Host (Get-Date).ToString() + "Starting Micros KDS Controller"
Start-Service -DisplayName "Micros KDS Controller"

# Loading the Database to Front of House
Start-Process "CLControl" -ArgumentList "/System FOH" -NoNewWindow

# Loops while CLControl is still running
While (Get-Process "CLControl" -ErrorAction SilentlyContinue)
    {
        Write-Host (Get-Date).ToString() "Loading the Database to Front of House, Please wait"
        Start-Sleep -S 60
    }

# Rebooting all Micros Devices
Start-Process "RemoteReboot" -ArgumentList "/all" -NoNewWindow | Out-Null

# Loops while RemoteReboot is still running
While (Get-Process "RemoteReboot" -ErrorAction SilentlyContinue)
    {
        Write-Host (Get-Date).ToString() "Rebooting all Micros Devices, Please wait"
        Start-Sleep -S 60
    }

# Clearing the 3700d.log file   
Start-Process "CLControl" -ArgumentList "/clear" -NoNewWindow

# Loops while CLControl is still running
While (Get-Process "CLControl" -ErrorAction SilentlyContinue)
    {
        Write-Host (Get-Date).ToString() "Rotating the 3700d.log File"
        Start-Sleep -S 10 
    }
    
Write-Host "Finished with the Micros Daily Checklist"