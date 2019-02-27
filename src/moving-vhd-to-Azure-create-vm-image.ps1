AzureRM.Profile\Login-AzureRmAccount
$subscriptionName = "Your Subscription Name"
$subscriptionId = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
$tenantId ="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
$resourceGroupName = 'DRendon'
$location = 'EastUS'
$vhdName = 'kemp360central-v1.25.vhd'
$imageName = 'kempcentral25'
$containerName = "kempcentraldrtestcontainer"
$storageAccountName = "kempcentraldrtest"
 
Select-AzureRmSubscription -SubscriptionId $subscriptionId
  
#Select your default subscription on ARM
Get-AzureRmSubscription -SubscriptionId $subscriptionId -TenantId $tenantId | Set-AzureRmContext
  
#create new storage account
$storageAccount = New-AzureRmStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName -SkuName Standard_LRS -Location $location
$ctx = $storageAccount.Context
  
#create container
 
new-azurestoragecontainer -Name $containerName -Context $ctx -Permission blob
  
#set the local path from the vhd
$localPath = 'C:\Users\daver\Downloads\kemp360central\kemp360central-v1.25.vhd'
  
  
# set the url of the image and move the vhd, also use the -overwrite option since process might fail sporadically
# -overwrite solves the error Add-AzureRmVhd : The pipeline was not run because a pipeline is already running.
# Pipelines cannot be run concurrently
$urlOfUploadedImageVhd = ('https://' + $storageAccountName + '.blob.core.windows.net/' + $containerName  + '/' + $vhdName)
Add-AzureRmVhd -ResourceGroupName $resourceGroupName -Destination $urlOfUploadedImageVhd `
-LocalFilePath $localPath -OverWrite
  
# Create a managed image from the uploaded VHD
$imageConfig = New-AzureRmImageConfig -Location $location
 
#set the managed disk from the image
$imageConfig = Set-AzureRmImageOsDisk -Image $imageConfig -OsType Windows -OsState Generalized `
    -BlobUri $urlOfUploadedImageVhd
 
$image = New-AzureRmImage -ImageName $imageName -ResourceGroupName $resourceGroupName -Image $imageConfig
