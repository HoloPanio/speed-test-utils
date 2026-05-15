#!/bin/sh

URLS="
https://ash-speed.hetzner.com/100MB.bin
http://cachefly.cachefly.net/100mb.test
"

for url in $URLS; do
    echo "Testing: $url"

    start=$(date +%s)
    out=$(wget -O /dev/null "$url" 2>&1)
    end=$(date +%s)

    secs=$((end - start))
    [ "$secs" -le 0 ] && secs=1

    size=$(echo "$out" | awk '
        /Length:/ {
            gsub(/[(),]/,"",$2);
            print $2;
            exit
        }')

    if [ -n "$size" ]; then
        mbps=$(awk -v bytes="$size" -v secs="$secs" 'BEGIN { printf "%.2f", (bytes * 8) / secs / 1000000 }')
        echo "Time: ${secs}s  Speed: ${mbps} Mbps"
    else
        echo "Could not parse file size; raw wget output follows:"
        echo "$out"
    fi

    echo
done