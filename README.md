# Azure-Master-VMBuild
These JSON templates use linked templates to create multiple resources. It assumes you already have a vNet and a Subnet created in the Azure Resource Group. All objects are being located in the same Resource Group.  
- This is using managed disks, and disabling Boot Diagnostics.
- The licenses types I build here are all using Azure Hybrid Benefit licensing.  
- This requires you to license your OS per your existing Enterprise Agreement.  

When running the deployment by clicking the Deploy button below, you will be prompted to answer several questions.

## In the Basics section:  
- Subscription: This is the subscription you will deploy to.  
- Resource Group: This is the resource group the resources will be deployed to. The vNet and Subnet must already exist in this Resource Group.  
- Location: This is the deploy to location in Azure. The vNet and Subnet must already exist in that location.  

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

Deploy a VM <a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FSeanGreenbaum%2FAzure-VMCompute%2Fmaster%2Fmaster.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/> </a>

Deploy a Data Disk <a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FSeanGreenbaum%2FAzure-VMCompute%2Fmaster%2Fdeploydisk.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/> </a>
    
Deploy a DC <a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FSeanGreenbaum%2FAzure-VMCompute%2Fmaster%2FDC-Deploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/> </a>
