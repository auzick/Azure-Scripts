# I make copies of this script to sit on my desktop so I can easily turn on Azure VM's (usually because of auto-shutdown).

$SubscriptionID = ''
$ResourceGroup = ''
$VmName = ''

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

Function Get-Status([String]$rg, [String]$name){
    (Get-AzVM -Name $name -ResourceGroupName $rg -Status).Statuses | Where-Object Code -Like 'PowerState/*' | Select-Object -ExpandProperty DisplayStatus

}

Login
Write-Host -ForegroundColor Green Getting subscription.
Select-AzSubscription -SubscriptionId $SubscriptionID | Out-Null

If ((Get-Status $ResourceGroup $VmName) -eq 'VM Running'){
    Write-Host -ForegroundColor Green $VmName is already running.
    cmd /c pause 
    Return
}

Write-Host -ForegroundColor Green Starting VM.
Start-AzVM -NoWait -Name $VmName -ResourceGroupName $ResourceGroup | Out-Null

$Status = ''
$LastStatus = ''

Do{
    $LastStatus = $Status
    $Status = Get-Status $ResourceGroup $VmName
    if ([string]::IsNullOrEmpty($Status)){$Status = "Waiting for status"}
    if ($LastStatus -eq $Status){
        Write-Host -NoNewline '.'
    }
    else {
        Write-Host
        Write-Host -NoNewline $Status
    }
    Start-Sleep -Seconds 1
} Until ($Status -Like 'VM Running')

Write-Host
Write-Host
Write-Host -ForegroundColor Green Done.
cmd /c pause 
