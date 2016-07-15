# About

Zabbix template for monitoring [Beanstalkd](http://kr.github.io/beanstalkd/) tubes.

## Requirements

- `netcat`

## Installation

1. Copy `beanstalkd-processor.sh` to the scripts directory.

    ```
    cp beanstalkd-processor.sh /etc/zabbix/scripts
    chmod 750 /etc/zabbix/scripts/beanstalkd-processor.sh
    chown zabbix:zabbix /etc/zabbix/scripts/beanstalkd-processor.sh
    ```

    If you use non-standard host/port of Beanstalkd, please specify `BEANSTALK_HOST` and `BEANSTALK_PORT` variables.

2. Include `beanstalkd.conf` to the Zabbix agent configuration file.

    ```
    cp beanstalkd.conf /etc/zabbix/zabbix-agentd.d 
    ```

    Ensure, that your `zabbix-agent.conf` contains `Include` directive. Otherwise you have to paste the content to the end of file.

3. Add cron job from `zabbix` user via `crontab` command:

    ```
    sudo -u zabbix crontab -e
    ```

    It should looks similar like that:

    ```
    */10 * * * * /etc/zabbix/scripts/beanstalkd-processor.sh fetch &>/dev/null
    ```

Done. Now you can import `zbx_beanstalkd.xml` file to the Zabbix.

## Usage

Import `zbx_beanstalkd.xml` to the Zabbix. After awhile you'll see metrics which has been automatically discovered via installed script. 

## License

MIT

