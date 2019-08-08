$SubscriptionID = 'ca638f2c-686f-4ae0-9525-f04b947a5491'
$ResourceGroup = "SC92B"
$VmName = 'sc92B'
$DiskName = 'SC92B-OS-2'

Function Login
{
    $needLogin = $true
    Try 
    {
        $content = Get-AzContext
        if ($content) 
        {
            $needLogin = ([string]::IsNullOrEmpty($content.Account))
        } 
    } 
    Catch 
    {
        if ($_ -like "*Run Connect-AzAccount to login*") 
        {
            $needLogin = $true
        } 
        else 
        {
            throw
        }
    }

    if ($needLogin)
    {
        Write-Host -ForegroundColor Green Logging into Azure
        Login-AzAccount
    }
}

Login

Write-Host -ForegroundColor Green "Set to the correct azure subscription"
Select-AzSubscription -SubscriptionId $SubscriptionID | Out-Null

# Get the VM 
Write-Host -ForegroundColor Green "Get the VM"
$vm = Get-AzVM -ResourceGroupName $ResourceGroup -Name $VmName 

# Make sure the VM is stopped\deallocated
Write-Host -ForegroundColor Green "Make sure the VM is stopped\deallocated"
Stop-AzVM -ResourceGroupName $ResourceGroup -Name $VmName -Force

# Get the new disk that you want to swap in
Write-Host -ForegroundColor Green "Get the new disk that you want to swap in"
$disk = Get-AzDisk -ResourceGroupName $ResourceGroup -Name $DiskName

# Set the VM configuration to point to the new disk  
Write-Host -ForegroundColor Green "Set the VM configuration to point to the new disk"
Set-AzVMOSDisk -VM $vm -ManagedDiskId $disk.Id -Name $disk.Name 

# Update the VM with the new OS disk
Write-Host -ForegroundColor Green "Update the VM with the new OS disk"
Update-AzVM -ResourceGroupName $ResourceGroup -VM $vm 

# Start the VM
Write-Host -ForegroundColor Green "Start the VM"
Start-AzVM -Name $vm.Name -ResourceGroupName $ResourceGroup
