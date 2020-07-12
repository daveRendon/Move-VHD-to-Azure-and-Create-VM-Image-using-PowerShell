Connect-AzAccount
$subscriptionName = "AzureCloud"
$subscriptionId = "4d278909-443c-4183-b346-6c7922e8cd8e"
$tenantId ="683bfafa-12ed-49b9-a787-62b888e26600"
$resourceGroupName = 'DRendon-ECS'
$location = 'EastUS'
$vhdName = 'ecs-conn-manager.vhd'
$imageName = 'ecs-conn-manager'
$containerName = "ecsconnmanager"
$storageAccountName = "ecsconnmanager"

#Set the Subscription to use in the current session
Set-AzContext -SubscriptionId $subscriptionId

#create new storage account
$storageAccount = New-AzStorageAccount -ResourceGroupName $resourceGroupName -AccountName $storageAccountName -SkuName Standard_LRS -Location $location
$ctx = $storageAccount.Context

#create storage container
New-AzStorageContainer -Name $containerName -Context $ctx -Permission blob

#set the local path from the vhd
$localPath = 'C:\Users\daver\Downloads\ECM\ECS-Connection-Manager-Microsoft-HyperV\ecs-conn-manager.vhd'

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