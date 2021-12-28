# Welcome
There are multiple templates in this repo which can be deployed. Please read the below information carefully to help you select the template to deploy and its associated UI.  
The deployment links for all are conveniently stored here at the top. Before deploying one, please read the information below to help you select the correct template and answer the required parameters.  
Enjoy!  
-  


| Type | Deploy | 
|:-------|:-------| 
| Deploy a VM | [![Deploy To Azure](https://docs.microsoft.com/en-us/azure/templates/media/deploy-to-azure.svg)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FSeanGreenbaum%2FAzure-VMCompute%2Fmaster%2Fmaster-v2.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FSeanGreenbaum%2FAzure-VMCompute%2Fmaster%2Fuimaster-v2.json) |  
| Deploy an AD Forest | [![Deploy To Azure](https://docs.microsoft.com/en-us/azure/templates/media/deploy-to-azure.svg)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FSeanGreenbaum%2FAzure-VMCompute%2Fmaster%2Fadforest.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FSeanGreenbaum%2FAzure-VMCompute%2Fmaster%2Fuiadforest.json) |  
| Deploy an additional DC | Coming soon! |  

# Deploy a VM
Primary deploy template files: Master-v2.json, uimaster-v2.json  
These JSON templates use linked templates to create multiple resources. It assumes you already have a vNet and a Subnet created in the Azure Resource Group. All objects are being located in the same Resource Group.  
- This is using managed disks.
- The licenses are all using Azure Hybrid Benefit licensing. This **requires you to license your OS per your existing Enterprise Agreement**.  

When running the deployment by clicking the Deploy button above, you will be prompted to answer several questions. The button uses the uimaster-v2.json file for a custom UI in the Azure Portal. The parameters are then passed to master-v2.json for actual build. master-v2.json depends on several of the other json files present in this repo to complete its tasks.  

## In the Basics section:  
- Subscription: This is the subscription you will deploy to.  
- Resource Group: This is the resource group the resources will be deployed to. The vNet and Subnet must already exist in this Resource Group  
- Region: This is the deploy to location in Azure. The vNet and Subnet must already exist in that location  
- VM Name: This is the name of the VM, both inside the OS and in the Azure Portal  
### VM Hardware subsection
- Qty: If building more than 1 VM, the VM Name above will have an iteration number added to the end. Ie. vm1, vm2, vm3...  
- VM SKU: Select the SKU of the VMs from the drop down  
- VNet Name: Name of the Virtual Network. Virtual Network must already exist in the selected Resource Group  
- VNet Subnet Name: Name of the Subnet for the above Virtual Network. Virtual Network must already exist  
- Accelerated Networking: Enable if VM sku supports. Disabled by default  
- Storage Type: StandardHDD, StandardSSD, PremiumSSD  
- Do you wish to configure data disks: Yes/No
    - If selecting No, then no additional questions. VM will not have any additional data disk attached at creation.
    - If selecting Yes, then additional questions are asked:
        - Number of Data Disks: Enter the number of data disks to be added to the VM
        - Data Disk host Caching: None/ReadOnly/ReadWrite
        - Size of data disks: Enter the size (in GB). All disks will be created of the same size.

### VM Software subsection
- Admin Username: This is the username of the built in admin account  
- Admin Password: This is the password of the built in admin account. This must be complex.  
- VM OS: Select the VM OS  
- VM OS Build: Use "latest" by default. If need a prior version, use PowerShell to determine the correct build value based on available options in Azure  
`Get-AzVMImage -Location <location> -PublisherName <PublisherName> -Offer <OfferName> -Skus <sku>`  
`Get-AzVMImage -Location EastUS -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2022-datacenter-smalldisk-g2`  
- Auto Shutdown Time: Based on an Azure Automation account which must already exist. Creates a Tag on the VM object with specfied value  
    - Accepted values: 1700, 2200, 2300, 2330, None  

## In the High Availability Options section:
This section covers the High Availability options for the VM(s) being deployed  

- Needs High Availability: Default option is No. Other options are Yes - Availability Zones, Yes - Availability Sets  
    - No. The current deployment does not have any HA requirements of the Azure Platform. No other questions asked  

    - Yes - Availability Zones. If set to Yes - Availability Zones, another drop down is exposed  
        - Availability Zone: 1, 2 or 3. Resources are deployed into the specified Zone  

    - Yes - Availability Sets. If set to Yes - Availability Sets, 2 new fields are exposed  
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


# Deploy an AD Forest
Primary deploy template files: adforest.json, uiadforest.json  
These JSON templates use linked templates to create multiple resources. It assumes you already have a vNet and a Subnet created in the Azure Resource Group. All objects will be located in the same Resource Group and Azure Region.
- These templates are using Managed Disks
- The VM is being configured with the Azure Hybrid Benefit licensing. This **requires you to license your OS per your existing Enterprise Agreement.**
- The deployment makes use of the CustomScriptExtension for Virtual Machines. As part of this deployment, an artifact file (PowerShell script) will be downloaded to the VM to complete the AD Forest build. This means the VM does require access to the internet for initial deployment. Specifically it requires access to https://raw.githubusercontent.com.  
- Domain Controllers in Azure require a seperate data disk be deployed and the related AD and SYSVOL files be stored on this data disk. This is required due to Active Directory database files need to be stored on disks which have Disk Caching **disabled**. These templates create a 4GB data disk with the correct disk caching settings. You can extend the size of the disk after Forest creation to an appropriate size.

When running the deployment by clicking the Deploy button above, you will be prompted to answer several questions. The button uses the uiadforest.json file for a custom UI in the Azure Portal. The parameters are then passed to adforest.json for actual build. adforest.json depends on several of the other json files present in this repo to complete its tasks.  

## In the Basics Section  
- Subscription: This is the subscription you will deploy to.  
- Resource Group: This is the resource group the resources will be deployed to. The vNet and Subnet must already exist in this Resource Group  
- Region: This is the deploy to location in Azure. The vNet and Subnet must already exist in that location  
- VM Name: This is the name of the VM, both inside the OS and in the Azure Portal  
### VM Hardware subsection
- VM SKU: Select the SKU of the VMs from the drop down  
- VNet Name: Name of the Virtual Network. Virtual Network must already exist in the selected Resource Group  
- VNet Subnet Name: Name of the Subnet for the above Virtual Network. Virtual Network must already exist  
- Static IP Address of the DC: Enter the IP address you wish the new Domain Controller to have. This IP address **must** be a valid IP address for the chosen Virtual Network and Subnet.
- Accelerated Networking: Enable if VM sku supports. Disabled by default  
- Storage Type: StandardHDD, StandardSSD, PremiumSSD  

### VM Software subsection
- Admin Username: This is the username of the built in admin account  
- Admin Password: This is the password of the built in admin account. This must be complex.  
- VM OS: Select the VM OS  
- VM OS Build: Use "latest" by default. If need a prior version, use PowerShell to determine the correct build value based on available option in Azure  
`Get-AzVMImage -Location <location> -PublisherName <PublisherName> -Offer <OfferName> -Skus <sku>`  
`Get-AzVMImage -Location EastUS -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2022-datacenter-smalldisk-g2`  
- Auto Shutdown Time: Based on an Azure Automation account which must already exist. Creates a Tag on the VM object with specfied value  
    - Accepted values: 1700, 2200, 2300, 2330, None  

## In the High Availability Options section:
This section covers the High Availability options for the VM(s) being deployed  

- Needs High Availability: Default option is No. Other options are Yes - Availability Zones, Yes - Availability Sets  
    - No. The current deployment does not have any HA requirements of the Azure Platform. No other questions asked  

    - Yes - Availability Zones. If set to Yes - Availability Zones, another drop down is exposed  
        - Availability Zone: 1, 2 or 3. Resources are deployed into the specified Zone  

    - Yes - Availability Sets. If set to Yes - Availability Sets, 2 new fields are exposed  
        - Availability Set Action: Existing or New. If Existing, then new VMs are added to an existing Availability Set. If New, then a new Availability Set is created.  
        - Availability Set Name: Name of the Availability Set. Create New or use Existing is determined based on prior input.  

## New AD Forest Options
This section is for naming your new AD Forest. You will need to supply both the DNS FQDN and the NetBIOS name of your new Forest.
- FQDN of new Forest: This is the full DNS name of the new forest. Ex: corp.contoso.com  
- NetBIOS Name of domain: This is the NetBIOS name of the new domain. Ex: corp

## Advanced Options
This section is for dev purposes. Default is No. Leave it at No unless instructed to use seperate configurations. Items present here may change based on any dev work I'm doing with the templates. Advanced options may not be production ready features yet, therefore should not be used.

## Review + Create
Here, review the settings and deploy the VM(s) as configured. Enjoy!  