#!/bin/bash
free -m | awk '/Mem:/{printf "%.1fG/%.1fG (%.0f%%)", $3/1024, $2/1024, $3/$2*100}'