```
cat << 'EOF' > ~/jupyter-binding/jupyter_vscode.slurm
#!/bin/bash
#SBATCH --job-name=jupyter_vscode
#SBATCH --gpus=1
#SBATCH --time=02:00:00
#SBATCH --mem=32G
#SBATCH --output=/dev/null

# Clean up previous connection files
rm -f ~/jupyter-binding/.jupyter_ready
rm -f ~/jupyter-binding/.jupyter_log

# Activate your exact environment
source ~/miniforge3/etc/profile.d/conda.sh
conda activate CS225

# Assign variables
PORT=8888
NODE=$(hostname)

# Start Jupyter Lab in the background, logging the output
jupyter lab --no-browser --port=$PORT --ip=$NODE > ~/jupyter-binding/.jupyter_log 2>&1 &
JUPYTER_PID=$!

# Wait until Jupyter fully boots and prints the token to the log
while ! grep -q "token=" ~/jupyter-binding/.jupyter_log; do
    sleep 2
done

# Extract the exact node name and token string
TOKEN=$(grep -oP '(?<=token=)[a-zA-Z0-9]+' ~/jupyter-binding/.jupyter_log | head -n 1)

# Write the final credentials for your local machine to read
echo "$NODE:$TOKEN" > ~/jupyter-binding/.jupyter_ready

# Keep the SLURM job alive until the 2-hour time limit is hit
wait $JUPYTER_PID
EOF
```
