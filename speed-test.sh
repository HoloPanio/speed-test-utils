#!/bin/sh

URLS="${*:-http://cachefly.cachefly.net/100mb.test}"

human_rate() {
    bps="$1"
    awk -v bps="$bps" 'BEGIN {
        if (bps >= 1000000) printf "%.2f Mbps", bps / 1000000;
        else if (bps >= 1000) printf "%.2f Kbps", bps / 1000;
        else printf "%.0f bps", bps;
    }'
}

for url in $URLS; do
    echo "Testing: $url"
    tmpfile="/tmp/curl_speedtest_$$.tmp"
    trap 'rm -f "$tmpfile"' EXIT INT TERM

    curl -L -o /dev/null --progress-bar "$url" 2>"$tmpfile"
    rc=$?

    if [ $rc -ne 0 ]; then
        echo "curl failed with exit code $rc"
        cat "$tmpfile"
        rm -f "$tmpfile"
        continue
    fi

    summary=$(tail -n 1 "$tmpfile")
    rm -f "$tmpfile"

    size=$(echo "$summary" | awk '{print $(NF-2)}')
    speed=$(echo "$summary" | awk '{print $NF}')

    echo
    echo "Final transfer summary: $summary"
    echo "Average speed: $speed"
    echo

done