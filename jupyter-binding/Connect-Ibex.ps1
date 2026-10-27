$User = ""
$LocalPort = 8080
$RemotePort = 8888

Write-Host "1. Contacting Ibex to request GPU and start Jupyter..." -ForegroundColor Cyan
# This single SSH command submits the job and waits until the ready file is generated
$Command = "sbatch ~/jupyter-binding/jupyter_vscode.slurm > /dev/null; while [ ! -f ~/.jupyter_ready ]; do sleep 5; done; cat ~/jupyter-binding/.jupyter_ready"
$Output = ssh ${User}@glogin.ibex.kaust.edu.sa $Command

if ($Output -match ":") {
    $Parts = $Output.Split(":")
    $Node = $Parts[0].Trim()
    $Token = $Parts[1].Trim()

    Write-Host "2. Server is alive on $Node! Opening background SSH tunnel..." -ForegroundColor Cyan
    # Starts the tunnel silently in the background so it doesn't freeze your terminal
    Start-Process ssh -ArgumentList "-N", "-L", "${LocalPort}:${Node}.ibex.kaust.edu.sa:${RemotePort}", "${User}@glogin.ibex.kaust.edu.sa" -WindowStyle Hidden

    $Url = "http://localhost:${LocalPort}/?token=${Token}"
    
    # Copy to Windows clipboard
    Set-Clipboard -Value $Url

    Write-Host "`n================================================="
    Write-Host "SUCCESS! The URL is securely copied to your clipboard." -ForegroundColor Green
    Write-Host $Url -ForegroundColor Yellow
    Write-Host "Go paste it directly into VS Code's Kernel Picker!"
    Write-Host "================================================="
} else {
    Write-Host "Something went wrong. Output was: $Output" -ForegroundColor Red
}
