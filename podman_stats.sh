#!/bin/bash
#
# podman_stats.sh
# (c) 2024 Max Voit
# local check for Checkmk parsing Podman container stats
# will create a service named "Podman-Stats"
#
# changelog:
# MV 2024-08-20
# 	initial version

# constants
SERVICE_NAME="Podman-Stats"

# WARN and CRIT thresholds for CPU and memory usage
CPU_WARN=80
CPU_CRIT=90
MEM_WARN=80
MEM_CRIT=90

# output variables
cmk_status=3
metrics=""
comment="unexpected error occurred"

# function to parse podman stats and generate metrics
parse_podman_stats () {
    local container_stats
    container_stats=$(su - ghoulbel -c "podman stats --no-stream --format 'table {{.Name}}\t{{.CPUPerc}}\t{{.MemPerc}}'" 2>/dev/null)
    
    if [[ -z "$container_stats" ]]; then
        comment="no container stats found"
        cmk_status=2
        return
    fi

    # Skip the header line
    read -r _ <<< "$container_stats"
    
    local cpu_percentage
    local mem_percentage
    local container_name

    while read -r container_name cpu_percentage mem_percentage; do
        # Remove the percentage sign from the CPU and memory usage
        cpu_percentage_value=$(echo "$cpu_percentage" | sed 's/%//')
        mem_percentage_value=$(echo "$mem_percentage" | sed 's/%//')

        if [[ -z "$cpu_percentage_value" || -z "$mem_percentage_value" ]]; then
            continue
        fi

        # Append percentage data for CPU and memory usage
        metrics+="${container_name}_cpu=${cpu_percentage_value}%;${CPU_WARN};${CPU_CRIT}"
        metrics+="|${container_name}_mem=${mem_percentage_value}%;${MEM_WARN};${MEM_CRIT}"

        # Update status based on thresholds
        if awk "BEGIN {exit !($cpu_percentage_value > $CPU_CRIT)}"; then
            cmk_status=2
        elif awk "BEGIN {exit !($cpu_percentage_value > $CPU_WARN)}"; then
            cmk_status=1
        else
            cmk_status=0
        fi

        if awk "BEGIN {exit !($mem_percentage_value > $MEM_CRIT)}"; then
            cmk_status=2
        elif awk "BEGIN {exit !($mem_percentage_value > $MEM_WARN)}"; then
            cmk_status=1
        else
            cmk_status=0
        fi

    done <<< "$container_stats"

    if [[ $cmk_status -eq 3 ]]; then
        comment="unexpected error occurred while parsing Podman stats"
    else
        comment="Container stats collected successfully"
    fi
}

# Run the function to parse Podman stats
parse_podman_stats

# Output in correct Checkmk local check format
echo "$cmk_status \"$SERVICE_NAME\" $metrics $comment"
