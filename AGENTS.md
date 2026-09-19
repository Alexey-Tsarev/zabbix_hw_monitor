You are writing a support for getting sensors data from hardware to Zabbix server.
We are interested in: temperatures, fans, volts.

## Architecture
- Scripts: `hwmon_discovery.sh` (pure sysfs LLD), `hwmon_value.sh` (sensor plugin + sysfs fallback)
- Chip names must match `sensors -u` output (e.g., `coretemp-isa-0000`, `nvme-pci-0400`)

## Zabbix 7.0 Template
- Template: `hwmon_template.yaml` (YAML format)
- Key: `hwmon.value[{#CHIP},{#FEATURE}]` (not built-in `sensor[]`)
- NVMe unsupported by built-in plugin — `hwmon_value.sh` falls back to sysfs
- Triggers:
  - temp >= `{$HW.TEMP.MAX:"{#CHIP}"}` (70°C default, 90°C for `^coretemp-isa-|^k10temp-`)
  - fan stopped
  - nodata 10m

## Deployment
- Scripts: `/etc/zabbix/scripts/` on hosts
- UserParameter: `/etc/zabbix/zabbix_agent2.d/hwmon.conf` on hosts
- After deploying hwmon.conf: `sudo systemctl restart zabbix-agent2`
