# KAUST Ibex Cluster Cheatsheet

A quick reference guide for managing jobs, checking limits, and troubleshooting on the KAUST Ibex HPC cluster.

---

## 1. Checking Your Limits & Quotas
Before submitting, check if you have resources available.

### Compute Limits (CPUs, GPUs, Time)
Check your user-specific association limits (Max jobs, Max Walltime, etc.):
```bash
sacctmgr show association user=$USER format=Account,Partition,QOS,GrpTRES,MaxTRESPerJob,MaxWall,MaxJobs
```

If the previous command returns empty, check the limits for the 'normal' QoS:
```bash
sacctmgr show qos normal format=Name,MaxTRESPerJob,MaxJobs,MaxWall,GrpTRES
```

### Storage Quotas
Check the limit for your Home directory (usually 200GB):
```bash
quota -s
```

Check the limit for your Scratch/User directory (usually 1.5TB+):
```bash
df -h /ibex/user/$USER
```

---

## 2. Job Monitoring
Track the status of your jobs in the queue.

### Basic Queue Checks
Show only your specific running or pending jobs:
```bash
squeue --me
```

Show the estimated start time for your pending jobs:
```bash
squeue --me --start
```

Show detailed configuration and status for a specific job ID:
```bash
scontrol show job <JOB_ID>
```

### Understanding Pending Reasons
Get a long explanation of why a job is pending (filters for the "Reason" line):
```bash
scontrol show job <JOB_ID> | grep "Reason"
```
* **`(Priority)`**: You are waiting in line.
* **`(Resources)`**: Waiting for enough CPUs/GPUs to free up.
* **`(ReqNodeNotAvail)`**: Maintenance is upcoming, or specific nodes you asked for are down.
* **`(AssociationJobLimit)`**: You hit your max CPU/GPU limit allowed by policy.

---

## 3. Node & Partition Info
See what hardware is available on the cluster.

### Check Partitions (Queues)
List all partitions and their up/down status:
```bash
sinfo
```

Check specific details of the batch partition (e.g., time limit, max CPUs):
```bash
scontrol show partition batch
```

### Check Available GPUs
List which nodes have GPUs and display their specific types:
```bash
ginfo
```

---

## 4. Troubleshooting & Debugging
How to inspect what is actually happening inside your job.

### Interactive "Dry Run"
Request an interactive session for debugging (1 GPU, 4 CPUs, 1 hour):
```bash
srun --partition=batch --gpus=1 --cpus-per-task=4 --mem=16G --time=1:00:00 --pty bash
```

### Inspecting a Running Job
1.  **Find the node:** Run `squeue --me` and look at the `NODELIST` column.
2.  **SSH into the node** (replace `<node_name>` with the actual node ID, e.g., `gpu214-06`):
    ```bash
    ssh <node_name>
    ```
3.  **Check CPU usage** to see if your cores are active or idle:
    ```bash
    htop -u $USER
    ```
4.  **Check GPU usage** to watch utilization in real-time:
    ```bash
    watch -n 1 nvidia-smi
    ```

---

## 5. Job Submission Templates
Standard headers for your `.slurm` scripts.

### Standard GPU Job (A100/V100/etc.)
Use this for most deep learning tasks.
* **Partition:** `batch`
* **Resources:** 1 GPU, 8 CPUs, 64GB RAM
* **Time:** 24 hours

```bash
#!/bin/bash
#SBATCH --job-name=my_experiment
#SBATCH --partition=batch
#SBATCH --gpus=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --time=24:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

module load python/3.10
module load cuda/11.8

srun python my_script.py
```

### V100 Specific (For Legacy Hardware)
Use this if you need to target V100s specifically. Note that V100s do not support `bfloat16` (use `float16` instead).
* **Constraint:** Explicitly requests `v100` hardware
* **Resources:** 1 GPU, 8 CPUs, 32GB RAM

```bash
#!/bin/bash
#SBATCH --partition=batch
#SBATCH --gpus=1
#SBATCH --constraint=v100
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=12:00:00

# Your commands...
```

---

## 6. Useful Shortcuts / Aliases
Add these to your `~/.bashrc` file to speed up your workflow.

### Queue Management
Shortcut for checking your queue:
```bash
alias sq='squeue --me'
```

Shortcut for checking estimated start times:
```bash
alias sqs='squeue --me --start'
```

Watch your queue in real-time (updates every 2 seconds). Great for seeing exactly when a job starts:
```bash
alias sqw='watch -n 2 squeue --me'
```

List your jobs with a cleaner, specific format (ID, Partition, Name, State, Time, Nodes):
```bash
alias sq_clean='squeue --me --format="%.10i %.15P %.30j %.10T %.10M %.10L %.6D %R"'
```

Get full details of a specific job (usage: `sjob 12345`):
```bash
alias sjob='scontrol show job'
```

**Danger Zone:** Cancel **ALL** of your active and pending jobs immediately:
```bash
alias scancelall='scancel -u $USER'
```

### Interactive Sessions
Shortcut for launching a quick interactive GPU session (debug mode - 30 mins):
```bash
alias idebug='srun --partition=debug --gpus=1 --cpus-per-task=4 --mem=16G --time=00:30:00 --pty bash'
```

Request a standard GPU node interactively for 2 hours (good for coding/debugging):
```bash
alias igpu='srun --partition=batch --gpus=1 --cpus-per-task=4 --mem=32G --time=2:00:00 --pty bash'
```

Request a CPU-only node interactively (good for compiling or file management):
```bash
alias icpu='srun --partition=batch --cpus-per-task=4 --mem=16G --time=2:00:00 --pty bash'
```

### Storage & Navigation
Check both Home and Scratch quotas in one command:
```bash
alias myquota='echo "--- HOME ---"; quota -s; echo ""; echo "--- SCRATCH ---"; df -h /ibex/user/$USER'
```

Jump straight to your user directory on Scratch (where your big data should be):
```bash
alias cdscratch='cd /ibex/user/$USER'
```

### Node Monitoring (Run inside a compute node)
Watch GPU usage updates every 1 second:
```bash
alias gpuwatch='watch -n 1 nvidia-smi'
```

Check CPU usage only for your specific user processes:
```bash
alias myusage='htop -u $USER'
```
