param (
    [Parameter(Mandatory=$false)][string]$DomainName = "contoso.com",
    [Parameter(Mandatory=$false)][string]$DomainNetBIOSName = "contoso",
    [Parameter(Mandatory=$false)][string]$Password = "P@ssword1"
)

$LogFile = "C:\Windows\Temp\ADForestLog.txt"

Add-Content -Path $LogFile "Domain Name $DomainName"
Add-Content -Path $LogFile "Domain NetBIOS Name $DomainNetBIOSName"

#Format data disk
Add-Content -Path $LogFile "Preparing data disk"
$rawdisks = get-disk | Where-Object {$_.PartitionStyle -eq "RAW"}
Initialize-Disk $rawdisks.Number
get-disk $rawdisks.Number | New-Partition -UseMaximumSize -AssignDriveLetter | Format-Volume -FileSystem NTFS -NewFileSystemLabel "AD Data" -Confirm:$false
$datadriveletter = (Get-Partition -DiskNumber $rawdisks.Number -PartitionNumber 2).DriveLetter

#Install AD Role and Features
Add-Content -Path $LogFile "Installing Windows Features"
Install-WindowsFeature -Name AD-Domain-Services,RSAT-AD-Tools

#Set variables and install AD Forest
Add-Content -Path $LogFile "Starting AD Forest install"
$ADDBPath = $datadriveletter + ":\Windows\NTDS"
$ADLogPath = $datadriveletter + ":\Windows\NTDS"
$ADSysVolPath = $datadriveletter + ":\Windows\SYSVOL"
$ADSafeModePasswordSecure = ConvertTo-SecureString $Password -AsPlainText -Force
Install-ADDSForest -CreateDnsDelegation:$false -DatabasePath $ADDBPath -DomainName $DomainName -DomainNetbiosName $DomainNetBIOSName -InstallDns:$true -LogPath $ADLogPath -NoRebootOnCompletion:$true -SysvolPath $ADSysVolPath -Force:$true -SafeModeAdministratorPassword $ADSafeModePasswordSecure

#Configure the local DNS Server service to forward to the Azure DNS service if VM is in Azure
Add-Content -Path $LogFile "Checking if in Azure"
$thisserver = Invoke-RestMethod -Headers @{"Metadata"="true"} -Method GET -Uri "http://169.254.169.254/metadata/instance?api-version=2021-02-01" | ConvertTo-Json -Depth 64
if ($thisserver) 
{
    Set-DnsServerForwarder -IPAddress 168.63.129.16
}

#Set NIC DNS to local IP address
Add-Content -Path $LogFile "Setting local DNS on NIC"
$ipaddress = (Get-NetIPConfiguration -InterfaceAlias Ethernet).IPv4Address.IPAddress
$curDNSAddress = (Get-DnsClientServerAddress -InterfaceAlias Ethernet).ServerAddresses
if ([string]::Compare($ipaddress, $curDNSAddress, $true) -ne "0") 
{
    Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddresses $ipaddress
}

#Need to test adding OUs before reboot or does this need to be a one time scheduled task and another ps1 script to complete OU builds
Add-Content -Path $LogFile "Initiating reboot in 60 seconds"
cmd.exe /c "shutdown /r /t 60"
#Cant use Restart-Computer due to no countdown timer
