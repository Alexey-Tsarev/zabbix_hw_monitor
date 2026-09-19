#!/bin/sh

CHIP="$1"
FEATURE="$2"

if [ -z "${CHIP}" ] || [ -z "${FEATURE}" ]; then
    exit 1
fi

SCRIPT_DIR="$(realpath "$(dirname "$0")")"
. "${SCRIPT_DIR}/hwmon_lib.sh"

SYSFS="${HW_SENSORS_SYSFS:-/sys/class/hwmon}"

# Get data via sensor plugin
line=$(zabbix_agent2 -t "sensor[${CHIP},${FEATURE}]" 2>/dev/null)

case "${line}" in
*'[s|'*)
    val=${line#*[s|}
    val=${val%%]*}
    printf '%s\n' "${val}"
    exit 0
    ;;
esac

# fallback to sysfs
for d in "${SYSFS}"/hwmon[0-9]*; do
    if [ ! -d "${d}" ]; then
        continue
    fi

    chip=$(chip_name "${d}")
    if [ $? -ne 0 ]; then
        continue
    fi

    if [ "${chip}" != "${CHIP}" ]; then
        continue
    fi

    loc=""
    if [ ! -r "${d}/name" ]; then
        loc="/device"
    fi

    if [ "${loc}" = "/device" ]; then
        if [ ! -r "${d}/device/name" ]; then
            continue
        fi
    fi

    f="${d}${loc}/${FEATURE}_input"
    if [ ! -f "${f}" ]; then
        continue
    fi

    case "${FEATURE}" in
    temp*)
        awk '{printf "%.6f", $1/1000}' "${f}"
        ;;
    *)
        awk '{printf "%.6f", $1}' "${f}"
        ;;
    esac

    exit 0
done

exit 1
