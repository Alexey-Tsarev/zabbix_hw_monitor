#!/bin/sh

# Shared functions for the hwmon scripts. This file must be sourced

# Builds a chip identifier in the very same format as `sensors -u` prints
chip_name() {
    d=$1
    name=""

    if [ -r "${d}/name" ]; then
        name=$(head -1 "${d}/name")
    fi

    if [ -z "${name}" ]; then
        if [ -r "${d}/device/name" ]; then
            name=$(head -1 "${d}/device/name")
        fi
    fi

    if [ -z "${name}" ]; then
        return 1
    fi

    if [ ! -L "${d}/device" ]; then
        printf '%s-virtual-0\n' "${name}"
        return
    fi

    link=$(readlink "${d}/device")
    dev=${link##*/}
    sub=""

    for l in "${d}/device/subsystem" "${d}/device/bus"; do
        if [ -L "${l}" ]; then
            link=$(readlink "${l}")
            sub=${link##*/}
            break
        fi
    done

    case "${sub}" in
    acpi)
        printf '%s-acpi-0\n' "${name}"
        ;;
    thermal)
        case "${name}" in
        acpitz*)
            printf '%s-acpi-0\n' "${name}"
            ;;
        *)
            printf '%s-virtual-0\n' "${name}"
            ;;
        esac
        ;;
    pci)
        a=${dev%%:*}
        rest=${dev#*:}
        b=${rest%%:*}
        rest=${rest#*:}
        c=${rest%%.*}
        d=${rest#*.}
        if [ -n "${a}" ] && [ -n "${b}" ] && [ -n "${c}" ] && [ -n "${d}" ]; then
            printf '%s-pci-%04x\n' "${name}" $(( (0x${a}<<16)+(0x${b}<<8)+(0x${c}<<3)+0x${d} ))
        else
            printf '%s\n' "${dev}"
        fi
        ;;
    platform|of_platform)
        printf '%s-isa-%04x\n' "${name}" "${dev##*.}"
        ;;
    nvme)
        p=$(readlink -f "${d}/device")
        bdf=""
        while [ "${p}" != "/" ]; do
            bdf=${p##*/}
            case "${bdf}" in
            [0-9a-f][0-9a-f][0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f].[0-7])
                break
                ;;
            esac
            bdf=""
            p=${p%/*}
        done

        if [ -n "${bdf}" ]; then
            b=${bdf#*:}
            b=${b%%:*}
            rest=${bdf#*:}
            rest=${rest#*:}
            c=${rest%%.*}
            d=${rest#*.}
            printf '%s-pci-%04x\n' "${name}" $(( (0x${b}<<8)+(0x${c}<<3)+0x${d} ))
        else
            printf '%s\n' "${dev}"
        fi
        ;;
    ieee80211)
        p=$(readlink -f "${d}/device")
        p=$(dirname "${p}")
        p=$(dirname "${p}")
        plat=${p##*/}
        addr=${plat%%.*}
        if [ -n "${addr}" ]; then
            printf '%s-isa-%s\n' "${name}" "${addr}"
        else
            printf '%s\n' "${dev}"
        fi
        ;;
    mdio_bus)
        id=${dev##*:}
        if [ -n "${id}" ]; then
            num=$(printf '%d' "0x${id}" 2>/dev/null)
            if [ -z "${num}" ]; then
                num=${id}
            fi
            printf '%s-mdio-%s\n' "${name}" "${num}"
        else
            printf '%s\n' "${dev}"
        fi
        ;;
    *)
        printf '%s\n' "${dev}"
        ;;
    esac
}
