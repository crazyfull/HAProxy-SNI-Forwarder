#!/bin/bash

INPUT="domains.csv"
OUTPUT="/etc/haproxy/haproxy.cfg"

if [[ ! -f "$INPUT" ]]; then
cat <<EOF > "$INPUT"
#sample
metrics.fivem.net,104.21.64.1:443
kahvand.com,104.21.64.1:443
ee.mojz.ir,104.21.64.1:443
EOF
echo "Sample domains.csv created."
exit 1
fi

cat <<EOF > "$OUTPUT"
global
    log /dev/log local0
    log /dev/log local1 notice
    maxconn 100000
    user haproxy
    group haproxy
    daemon

defaults
    log     global
    mode    tcp
    option  tcplog
    timeout connect 10s
    timeout client  1m
    timeout server  1m

frontend https-in
    bind *:443
    mode tcp
    tcp-request inspect-delay 5s
    tcp-request content accept if { req_ssl_hello_type 1 }
EOF

while IFS= read -r line; do
    [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
    domain=$(echo "$line" | cut -d',' -f1)
    clean_name=$(echo "$domain" | sed 's/[^a-zA-Z0-9]/_/g')
    echo "    use_backend ${clean_name}_backend if { req_ssl_sni -i $domain }" >> "$OUTPUT"
done < "$INPUT"

echo "    tcp-request content reject" >> "$OUTPUT"
echo "" >> "$OUTPUT"
echo "# === Backend Definitions ===" >> "$OUTPUT"

while IFS= read -r line; do
    if [[ "$line" =~ ^#(.*)$ ]]; then
        group=$(echo "${BASH_REMATCH[1]}" | sed 's/[^a-zA-Z0-9]/_/g')
        continue
    fi
    [[ -z "$line" ]] && continue
    domain=$(echo "$line" | cut -d',' -f1)
    ipport=$(echo "$line" | cut -d',' -f2)
    clean_name=$(echo "$domain" | sed 's/[^a-zA-Z0-9]/_/g')
    echo "backend ${clean_name}_backend" >> "$OUTPUT"
    echo "    mode tcp" >> "$OUTPUT"
    echo "    server ${clean_name}_srv $ipport" >> "$OUTPUT"
    echo "" >> "$OUTPUT"
done < "$INPUT"

haproxy -c -f "$OUTPUT"
service haproxy restart
