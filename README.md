# Master-v2 VMBuild
These JSON templates use linked templates to create multiple resources. It assumes you already have a vNet and a Subnet created in the Azure Resource Group. All objects are being located in the same Resource Group.  
- This is using managed disks.
- The licenses are all using Azure Hybrid Benefit licensing. This **requires you to license your OS per your existing Enterprise Agreement**.  

When running the deployment by clicking the Deploy button below, you will be prompted to answer several questions. The below button uses the uimaster-v2.json for a custom UI in the Azure Portal. The parameters are then passed to master-v2.json for actual build. master-v2.json depends on several of the other json files present in this repo to complete its tasks.  

## In the Basics section:  
- Subscription: This is the subscription you will deploy to.  
- Resource Group: This is the resource group the resources will be deployed to. The vNet and Subnet must already exist in this Resource Group  
- Region: This is the deploy to location in Azure. The vNet and Subnet must already exist in that location  
- VM Name: This is the name of the VM, both inside the OS and in the Azure Portal  
- Qty: If building more than 1 VM, the VM Name above will have an interation number added to the end. Ie. vm1, vm2, vm3...  
    - All numbers starts at 1  
- Admin Username: This is the username of the built in admin account  
- Admin Password: This is the password of the built in admin account. This must be complex.  
- VM SKU: Select the SKU of the VMs from the drop down  
- VM OS: Select the VM OS  
- VM OS Build: Use "latest" by default. If need a prior version, use PowerShell to determine the correct build value based on available option in Azure  
`Get-AzVMImage -Location <location> -PublisherName <PublisherName> -Offer <OfferName> -Skus <sku>`  
`Get-AzVMImage -Location EastUS -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2022-datacenter-smalldisk-g2`  
- Storage Type: StandardHDD, StandardSSD, PremiumSSD  
- VNet Name: Name of the Virtual Network. Virtual Network must already exist in the selected Resource Group  
- VNet Subnet Name: Name of the Subnet for the above Virtual Network. Virtual Network must already exist  
- Accelerated Networking: Enable if VM sku supports. Disabled by default  
- Auto Shutdown Time: Based on an Azure Automation script which must already exist. Creates a Tag on the VM object with specfied value  
    - Accepted values: 1700, 2200, 2300, 2330, None  

## In the High Availability Options section:
This section covers the High Availability options for the VM(s) being deployed  

- Needs High Availability: Default option is No. Other options are Yes - Availability Zones, Yes - Availability Sets  
### No
The current deployment does not have any HA requirements of the Azure Platform. No other questions asked  

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
    - Domain Join Username: This is the username to be used to complete the domain join. Username must be in the format **domain\username** or **username@domainFQDN**
    - Domain Join Password: This is the password for the above user account  

## Advanced Options
This section is for dev purposes. Default is No. Leave it at No unless instructed to use seperate configurations. Items present here may change based on any dev work I'm doing with the templates. Advanced options may not be production ready features yet, therefore should not be used.

## Review + Create
Here, review the settings and deploy the VM(s) as configured. Enjoy!

| Type | Deploy | 
|:-------|:-------| 
| Deploy a VM | [![Deploy To Azure](https://docs.microsoft.com/en-us/azure/templates/media/deploy-to-azure.svg)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FSeanGreenbaum%2FAzure-VMCompute%2FnewUI%2Fmaster-v2.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FSeanGreenbaum%2FAzure-VMCompute%2FnewUI%2Fuimaster-v2.json) | 
