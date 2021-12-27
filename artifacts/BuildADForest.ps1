param (
    [Parameter(Mandatory=$false)][string]$DomainName = "contoso.com",
    [Parameter(Mandatory=$false)][string]$DomainNetBIOSName = "contoso",
    [Parameter(Mandatory=$false)][string]$SafeModeAdminPassword = "P@ssword1"
)

#Format data disk
$rawdisks = get-disk | ? {$_.PartitionStyle -eq "RAW"}
Initialize-Disk $rawdisks.DiskNumber
get-disk $rawdisks.Number | New-Partition -UseMaximumSize -AssignDriveLetter | Format-Volume -FileSystem NTFS -NewFileSystemLabel "AD Data"
$datadriveletter = (Get-Partition -DiskNumber $rawdisks.DiskNumber -PartitionNumber 2).DriveLetter

#Set NIC DNS to local IP address
#$ipaddress = (Get-NetIPConfiguration -InterfaceAlias Ethernet).IPv4Address.IPAddress
#$curDNSAddress = (Get-DnsClientServerAddress -InterfaceAlias Ethernet).ServerAddresses
#if ([string]::Compare($ipaddress, $curDNSAddress, $true) -ne "0") 
#{
#    Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddresses $ipaddress
#}

#Install AD Role and Features
Install-WindowsFeature -Name AD-Domain-Services,RSAT-AD-Tools

#Set variables and install AD Forest
$ADDBPath = $datadriveletter + ":\Windows\NTDS"
$ADLogPath = $datadriveletter + ":\Windows\NTDS"
$ADSysVolPath = $datadriveletter + ":\Windows\SYSVOL"
$ADSafeModePasswordSecure = ConvertTo-SecureString $SafeModeAdminPassword -AsPlainText -Force
Install-ADDSForest -CreateDnsDelegation:$false -DatabasePath $ADDBPath -DomainName $DomainName -DomainNetbiosName $DomainNetBIOSName -InstallDns:$true -LogPath $ADLogPath -NoRebootOnCompletion:$true -SysvolPath $ADSysVolPath -Force:$true -SafeModeAdministratorPassword $ADSafeModePasswordSecure

#Configure the local DNS Server service to forward to the Azure DNS service if VM is in Azure
$thisserver = Invoke-RestMethod -Headers @{"Metadata"="true"} -Method GET -Uri "http://169.254.169.254/metadata/instance?api-version=2021-02-01" | ConvertTo-Json -Depth 64
if ($thisserver) 
{
    Set-DnsServerForwarder -IPAddress 168.63.129.16
}

Restart-Computer -Force
