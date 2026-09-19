#!/bin/sh

SCRIPT_DIR="$(realpath "$(dirname "$0")")"
. "${SCRIPT_DIR}/hwmon_lib.sh"

SYSFS="${HW_SENSORS_SYSFS:-/sys/class/hwmon}"

for d in "${SYSFS}"/hwmon[0-9]*; do
    if [ ! -d "${d}" ]; then
        continue
    fi

    chip=$(chip_name "${d}")
    if [ $? -ne 0 ]; then
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

    for f in "${d}${loc}"/*_input; do
        if [ ! -f "${f}" ]; then
            continue
        fi

        b=${f##*/}
        type=${b%%[0-9]*}

        case "${type}" in
        temp|fan|in)
            ;;
        *)
            continue
            ;;
        esac

        feature=${b%_input}

        case "${type}" in
        temp)
            u="°C"
            ;;
        fan)
            u="rpm"
            ;;
        *)
            u="V"
            ;;
        esac

        printf '%s\t%s\t%s\t%s\n' "${chip}" "${feature}" "${type}" "${u}"
    done
done | awk -F'\t' '
function esc(s){
    gsub(/\\/,"\\\\",s)
    gsub(/"/,"\\\"",s)
    return s
}
BEGIN{
    printf "{\"data\":["
}
{
    if(f) printf ","
    f=1
    printf "{\"{#CHIP}\":\"%s\",\"{#FEATURE}\":\"%s\",\"{#TYPE}\":\"%s\",\"{#UNIT}\":\"%s\"}",esc($1),esc($2),$3,$4
}
END{
    printf "]}\n"
}'
