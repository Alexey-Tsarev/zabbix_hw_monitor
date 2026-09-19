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
| Macro                                                                                  | Default | Description                                                                                                         |
|----------------------------------------------------------------------------------------|---------|---------------------------------------------------------------------------------------------------------------------|
| `{$HW.TEMP.MAX}`                                                                       | 70      | Default high temperature (°C)                                                                                       |
| `{$HW.TEMP.MAX:regex:"^coretemp-isa-\|^k10temp-\|^nct6797-isa-0a20,(temp7\|temp13)$"}` | 90      | High temperature for CPU sensors: Intel coretemp, AMD k10temp, nct6797 SMBUSMASTER 0 (temp7) and TSI0_TEMP (temp13) |

---
Good luck!  
Alexey Tsarev, Tsarev.Alexey@gmail.com
