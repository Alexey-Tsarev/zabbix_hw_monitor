#!/bin/sh

SCRIPT_DIR="$(realpath "$(dirname "$0")")"

PASS=0
FAIL=0

# get discovery list (chip|feature per line)
DISCOVERY_JSON=$("${SCRIPT_DIR}/hwmon_discovery.sh" 2>/dev/null)
if [ -z "${DISCOVERY_JSON}" ]; then
    echo "FAIL: hwmon_discovery.sh returned nothing"
    exit 1
fi

# split on },{
DISCOVERY_LIST=$(printf '%s' "${DISCOVERY_JSON}" | \
    sed 's/},{/}\n{/g' | \
    sed -n 's/.*"{#CHIP}":"\([^"]*\)","{#FEATURE}":"\([^"]*\)".*/\1|\2/p')

TOTAL=$(printf '%s\n' "${DISCOVERY_LIST}" | grep -c '.')
echo "Discovered sensors: ${TOTAL}"

# test each sensor
while IFS='|' read -r chip feature; do
    result=$("${SCRIPT_DIR}/hwmon_value.sh" "${chip}" "${feature}" 2>/dev/null || true)

    if [ -n "${result}" ]; then
        echo "OK: ${chip},${feature} => ${result}"
        PASS=$((PASS + 1))
    else
        echo "ER: ${chip},${feature} => ${result}"
        FAIL=$((FAIL + 1))
    fi
done << EOF
${DISCOVERY_LIST}
EOF

echo ""
echo "=== Summary ==="
echo "Total: ${TOTAL}"
echo "OK:    ${PASS}"
echo "ERROR: ${FAIL}"
