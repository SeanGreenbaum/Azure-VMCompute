# Azure-Master-VMBuild
These JSON templates use linked templates to create multiple resources. It assumes you already have a vNet and a Subnet created in the Azure Resource Group. All objects are being located in the same Resource Group.  
- This is using managed disks.
- The licenses are all using Azure Hybrid Benefit licensing. This requires you to license your OS per your existing Enterprise Agreement.  

When running the deployment by clicking the Deploy button below, you will be prompted to answer several questions.

## In the Basics section:  
- Subscription: This is the subscription you will deploy to.  
- Resource Group: This is the resource group the resources will be deployed to. The vNet and Subnet must already exist in this Resource Group  
- Region: This is the deploy to location in Azure. The vNet and Subnet must already exist in that location  
- VM Name: This is the name of the VM, both inside the OS and in the Azure Portal  
- Qty: If building more than 1 VM, the VM Name above will have an interation number added to the end. Ie. vm1, vm2, vm3...  
    All numbers starts at 1  
- Admin Username: This is the username of the built in admin account  
- Admin Password: This is the password of the built in admin account. This must be complex.  
- VM SKU: Select the SKU of the VMs from the drop down  
- OS Family: For a Windows Server, Select Windows Server. For a Windows client OS, select the appropriate family  
    For Windows clients, be sure the OS Family match the OS selected in the next drop down  
- VM OS: Select the VM OS  
    If using OS Family Windows Server, then only Server OS will be displayed  
    If using OS Family not Windows Server, then all Windows client OS will be displayed. Be sure to select the correct OS based on the OS Family above  
-VM OS Build: Use "latest" by default. If need a prior version, use PowerShell to determine the correct build value based on available option in Azure  
    Get-AzVMImage -Location <location> -PublisherName <PublisherName> -Offer <OfferName> -Skus <sku>  
    ex. Get-AzVMImage -Location EastUS -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2022-datacenter-smalldisk-g2  
- Storage Type: StandardHDD, StandardSSD, PremiumSSD  
- VNet Name: Name of the Virtual Network. Virtual Network must already exist in the selected Resource Group  
- VNet Subnet Name: Name of the Subnet for the above Virtual Network. Virtual Network must already exist  
- Accelerated Networking: Enable if VM sku supports. Disabled by default  
- Auto Shutdown Time: Based on an Azure Automation script which must already exist. Creates a Tag on the VM object with specfied value  
    Accepted values: 1700, 2200, 2300, 2330, None  

## In the High Availability Options section:
This section covers the High Availability options for the VM(s) being deployed  
- Needs High Availability: Default is No. If changed any other value, then more options are exposed.  
    Other options: Yes - Availability Zones  
                   Yes - Availability Sets  

### Yes - Availability Zones
If set to Yes - Availability Zones, another drop down is exposed  
- Availability Zone: 1, 2 or 3. Resources are deployed into the specified Zone  

### Yes - Availability Sets
If set to Yes - Availability Sets, 2 new fields are exposed  
- Availability Set Action: Existing or New. If Existing, then new VMs are added to an existing Availability Set. If New, then a new Availability Set is created.  
- Availability Set Name: Name of the Availability Set. Create New or use Existing is determined based on prior input.  

## Domain Join Options
This section covers running a post build extension which will cause the VMs to join the specified Active Directory domain. This domain must already exist, domain controllers must be accessible, and the DNS on the virtual network must already be configured to allow the new VM(s) to discover the domain.  
- Domain Join: Default is No. If changed to Yes, the additional prompts will be displayed  

- Domain to Join: This is the FQDN of the AD domain to join  
- Domain Join Username: This is the username to be used to complete the domain join. Username must be in the format domain\username or username@domainFQDN  
- Domain Join Password: This is the password for the above user account  

## Advanced Options
This section is for dev purposes. Default is No. Leave it at No unless instructed to use seperate configurations. Items present here may change based on any dev work I'm doing with the templates. Advanced options may not be production ready features yet, therefore should not be used.

## Review + Create
Here, review the settings and deploy the VM(s) as configured. Enjoy!



## In the Settings section: 

- VM Name: This is the name for your VM.  
*(If building 1 VM, this exact name is used. If building multiple VMs, this name is used as a number is added to the end of that name.*  
*For example, If you want to build 3 servers, and the VMName is "Test", the VMs will be named "Test1","Test2","Test3")*
- VM Count: This is the number of VMs to build. The JSON here limits the max to 10. This is a personal limit, not an Azure limit.  
- Admin Username: This is the built in -500 account user name. Administrator is reserved, requiring a different name. AzureAdmin is my personal choice. You can change this.  
- Admin Password: This will be the password for the -500 account specified above. Use whatever you want, but it must pass compliance check via Azure.  
- VM Size: Drop down list to select the size of the VM(s). These are the VM types I typically use for my testing.  
- VM OS: List of OS for the VMs. This is my personal list, not an exhaustive list of all available images in Azure.  
- Time Zone: Default time zone for the VM OS. These are my personal values.  
- License: If building a Windows Server OS, select Windows_Server. If a client OS, select Windows_Client.  
*This is enabling the Azure Hybrid Use Benefit on the VM.*
- Storage Type: If the VMSize you selected uses Premium storage, you need to select Premium_LRS. VM Sizes with an "s" in them use Premium storage.  
- VNet Name: Name of the vNet you want the NIC attached to.  
- VNet Subnet Name: Name of the Subnet that exists in the above vNet.  
- Accelerated Networking: If the selected VM Size supports Accelerated Networking, and if you want to enable it, select True.  
- Auto Shutdown Time: This creates a tag on the VM with the value from the drop down. If using Azure Automation for auto VM shutdown, it will use this tag and shut down the VM.  
*(For this to work, it does require you to build Azure Automation and scripting to use this tag.)*
- Needs AV Set: Dropdown options "No", "Existing", "New". If an Availability Set is not needed, select No.  
*If an Availability Set is needed, and there is already an Existing one available, select Existing.  
If an Availability Set is needed, and there is not already one, select New.*
- AV Set Name: Name of the AV Set.  
*If you selected "No" above, this name is ignored. If selected "Existing" or "New" this name is used for creating/joining the AV Set.*

Deploy a VM <a href="https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FSeanGreenbaum%2FAzure-VMCompute%2FnewUI%2Fmaster-v2.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FSeanGreenbaum%2FAzure-VMCompute%2FnewUI%2Fuimaster-v2.json" target="_blank">
    <img src="https://docs.microsoft.com/en-us/azure/templates/media/deploy-to-azure.svg"/> </a>
