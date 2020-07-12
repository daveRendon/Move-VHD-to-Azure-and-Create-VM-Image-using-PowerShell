Connect-AzAccount
$subscriptionName = "AzureCloud"
$subscriptionId = "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx"
$tenantId ="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxx"
$resourceGroupName = 'Your-Resource-Group-Name'
$location = 'EastUS'
$vhdName = 'Your-VHD-Name.vhd'
$imageName = 'Your-Image-Name'
$containerName = "Your-Container-Name"
$storageAccountName = "Your-Storage-Account-Name"

#Set the Subscription to use in the current session
Set-AzContext -SubscriptionId $subscriptionId

#create new storage account
$storageAccount = New-AzStorageAccount -ResourceGroupName $resourceGroupName -AccountName $storageAccountName -SkuName Standard_LRS -Location $location
$ctx = $storageAccount.Context

#create storage container
New-AzStorageContainer -Name $containerName -Context $ctx -Permission blob

#set the local path from the vhd
$localPath = 'Path-to-Your-VHD-File.vhd'

# set the url of the image and move the vhd, also use the -overwrite option since process might fail sporadically
# -overwrite solves the error Add-AzureRmVhd : The pipeline was not run because a pipeline is already running.
# Pipelines cannot be run concurrently
$urlOfUploadedImageVhd = ('https://' + $storageAccountName + '.blob.core.windows.net/' + $containerName  + '/' + $vhdName)
Add-AzVhd -ResourceGroupName $resourceGroupName -Destination $urlOfUploadedImageVhd `
-LocalFilePath $localPath -OverWrite

# Create a managed image from the uploaded VHD
$imageConfig = New-AzImageConfig -Location $location

#set the managed disk from the image
$imageConfig = Set-AzImageOsDisk -Image $imageConfig -OsType Windows -OsState Generalized `
    -BlobUri $urlOfUploadedImageVhd

#Create image
$image = New-AzImage -ImageName $imageName -ResourceGroupName $resourceGroupName -Image $imageConfig