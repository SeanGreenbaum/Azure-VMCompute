$domaindn = (Get-ADDomain).DistinguishedName

$data = Get-Content -Path "C:\ADForest Build\ADForest-oustructure.txt"
$Logfile = "C:\ADForest Build\BuildADForestOUStructure-Logfile.txt"

Add-Content $Logfile "Script start"
#Create OUs from file
$data | ForEach-Object {
    if (-not ($_.Split(",")[1]))
    {
        $myou = $_.Split(",")[0]
        $mypath = $domaindn
    }
    else
    {
        $myou = $_.Substring(0, $_.IndexOf(","))
        $mypath = $_.Substring($_.IndexOf(",")+1) + "," + $domaindn
    }
    $myname = $myou.Split("=")[1]
    Add-Content $Logfile $myname
    Add-Content $Logfile $mypath
    $output = New-ADOrganizationalUnit $myname -Path $mypath
    Add-content $LogFile $output
    Add-content $LogFile "---"
}
#Delete the scheduled task, its no longer needed
Add-Content $Logfile "Starting delete task"
$task = Get-ScheduledTask -TaskName "AD Forest Build post-reboot"
Unregister-ScheduledTask -InputObject $task -Confirm:$false