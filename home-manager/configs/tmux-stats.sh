#!/bin/bash
RAM=$(free -m | awk '/Mem:/{printf "%.1fG/%.1fG (%.0f%%)", $3/1024, $2/1024, $3/$2*100}')
GPU=$(nvidia-smi --query-gpu=memory.used,memory.total,utilization.gpu --format=csv,noheader,nounits 2>/dev/null | awk -F", " '{printf "%dMB/%dMB (%d%%)", $1, $2, $3}')
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
echo "RAM: $RAM | CPU: ${CPU}% | GPU: $GPU"