#!/bin/sh

URLS="${*:-http://cachefly.cachefly.net/100mb.test}"

human_rate() {
    # expects bits per second
    bps="$1"
    awk -v bps="$bps" 'BEGIN {
        if (bps >= 1000000) printf "%.2f Mbps", bps / 1000000;
        else if (bps >= 1000) printf "%.2f Kbps", bps / 1000;
        else printf "%.0f bps", bps;
    }'
}

human_bytes() {
    bytes="$1"
    awk -v b="$bytes" 'BEGIN {
        if (b >= 1073741824) printf "%.2f GB", b / 1073741824;
        else if (b >= 1048576) printf "%.2f MB", b / 1048576;
        else if (b >= 1024) printf "%.2f KB", b / 1024;
        else printf "%d B", b;
    }'
}

for url in $URLS; do
    echo "Testing: $url"

    # curl -w gives structured output; speed_download is in bytes/sec
    result=$(curl -L -o /dev/null --silent \
        -w "%{speed_download} %{size_download} %{time_total}" \
        "$url")
    rc=$?

    if [ $rc -ne 0 ]; then
        echo "curl failed with exit code $rc"
        continue
    fi

    speed_bps=$(echo "$result" | awk '{print $1}')
    size_bytes=$(echo "$result" | awk '{print $2}')
    time_sec=$(echo "$result" | awk '{print $3}')

    # convert bytes/sec -> bits/sec for human_rate
    speed_bits=$(awk -v s="$speed_bps" 'BEGIN { printf "%.0f", s * 8 }')

    echo "  Downloaded: $(human_bytes "$size_bytes")"
    echo "  Time:       ${time_sec}s"
    echo "  Speed:      $(human_rate "$speed_bits")"
    echo
done