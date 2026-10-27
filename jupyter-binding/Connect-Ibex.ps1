$User = ""
$LocalPort = 8080
$RemotePort = 8888

Write-Host "1. Contacting Ibex to request GPU and start Jupyter..." -ForegroundColor Cyan

$Command = "sbatch ~/jupyter-binding/jupyter_vscode.slurm > /dev/null; while [ ! -f ~/jupyter-binding/.jupyter_ready ]; do sleep 5; done; cat ~/jupyter-binding/.jupyter_ready"
$Output = ssh ${User}@glogin.ibex.kaust.edu.sa $Command

# Use strict regex to ignore the ASCII banner and capture ONLY the Node and Token
if ($Output -match "(gpu\d+-\d+):([a-zA-Z0-9]+)") {
    $Node = $Matches[1]
    $Token = $Matches[2]

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

Write-Host "`n"
Read-Host -Prompt "Press Enter to close this window"
