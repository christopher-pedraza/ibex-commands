$User = ""
$LocalPort = 8080
$RemotePort = 8888

Write-Host "1. Contacting Ibex to request GPU and start Jupyter..." -ForegroundColor Cyan

$Command = "sbatch ~/jupyter-binding/jupyter_vscode.slurm > /dev/null; while [ ! -f ~/jupyter-binding/.jupyter_ready ]; do sleep 5; done; cat ~/jupyter-binding/.jupyter_ready"
$Output = ssh ${User}@glogin.ibex.kaust.edu.sa $Command

if ($Output -match ":") {
    $Parts = $Output.Split(":")
    $Node = $Parts[0].Trim()
    $Token = $Parts[1].Trim()

    Write-Host "2. Server is alive on $Node! Opening background SSH tunnel..." -ForegroundColor Cyan
    
    Start-Process ssh -ArgumentList "-N", "-L", "${LocalPort}:${Node}.ibex.kaust.edu.sa:${RemotePort}", "${User}@glogin.ibex.kaust.edu.sa" -WindowStyle Hidden

    $Url = "http://localhost:${LocalPort}/?token=${Token}"
    
    Set-Clipboard -Value $Url

    Write-Host "`n================================================="
    Write-Host "SUCCESS! The URL is securely copied to your clipboard." -ForegroundColor Green
    Write-Host $Url -ForegroundColor Yellow
    Write-Host "Go paste it directly into VS Code's Kernel Picker!"
    Write-Host "================================================="
} else {
    Write-Host "Something went wrong. Output was: $Output" -ForegroundColor Red
}

# Prevents the PowerShell window from auto-closing
Write-Host "`n"
Read-Host -Prompt "Press Enter to close this window"
