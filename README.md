# Hardware sensors monitoring for Zabbix (temperatures, fans, volts)
Monitors Linux hosts via Zabbix agent.

## Install
Copy scripts from `etc/zabbix/scripts` to your hosts at `/etc/zabbix/scripts` directory.

## Verify
```
/etc/zabbix/scripts/hwmon_discovery_checker.sh
```

## Restart
```
systemctl restart zabbix-agent2
/etc/init.d/zabbix_agentd restart # OpenWrt
```

## Zabbix Server
1. Import `zabbix_server_template/hwmon_template.yaml` (Configuration -> Templates -> Import).
2. Link the template `HW sensors by Zabbix agent` to the hosts.

## Macros
| Macro                     | Default | Description                                |
|---------------------------|---------|--------------------------------------------|
| `{$HW.TEMP.MAX}`          | 70      | High temperature threshold (°C)            |
| `{$HW.TEMP.MAX.CORETEMP}` | 90      | High temperature for fanless coretemp (°C) |

---
Good luck!  
Alexey Tsarev, Tsarev.Alexey@gmail.com
