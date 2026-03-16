$erroParada = "Stop"

function TestarAdministrador {
    $identidadeAtual = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principalAtual = New-Object Security.Principal.WindowsPrincipal($identidadeAtual)
    $ehAdministrador = $principalAtual.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if ($ehAdministrador -eq $false) {
        Write-Host "execute como administrador." -ForegroundColor Red
        exit 1
    }
}

function ReiniciarDispositivoPnP {
    param (
        [string]$idInstancia,
        [string]$nome
    )

    try {
        Write-Host "reiniciando: $nome" -ForegroundColor Yellow
        Disable-PnpDevice -InstanceId $idInstancia -Confirm:$false -ErrorAction Stop
        Start-Sleep -Seconds 2
        Enable-PnpDevice -InstanceId $idInstancia -Confirm:$false -ErrorAction Stop
        Start-Sleep -Milliseconds 700
    }
    catch {
        Write-Host "falha: $nome" -ForegroundColor Red
    }
}

TestarAdministrador

$dispositivosUsb = Get-PnpDevice -PresentOnly | Where-Object {
    $_.InstanceId -like "USB\*" -or $_.Class -eq "USB"
}

#coisas
$dispositivosUsb = $dispositivosUsb | Where-Object {
    $_.FriendlyName -notmatch "keyboard" -and
    $_.FriendlyName -notmatch "teclado" -and
    $_.FriendlyName -notmatch "mouse" -and
    $_.FriendlyName -notmatch "hid-compliant mouse" -and
    $_.FriendlyName -notmatch "hid keyboard device"
}

$dispositivosUsb = $dispositivosUsb | Sort-Object InstanceId -Unique

foreach ($dispositivoAtual in $dispositivosUsb) {
    ReiniciarDispositivoPnP -idInstancia $dispositivoAtual.InstanceId -nome $dispositivoAtual.FriendlyName
}

Write-Host "reinício usb concluído." -ForegroundColor Green