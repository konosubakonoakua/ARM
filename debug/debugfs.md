# debugfs

## mount debugfs

Get root and mount debugfs, usually already mounted in armbian.

```shell
sudo mount -t debugfs none /sys/kernel/debug
```

## enable tracing (i2c e.g.)

```shell
sudo echo nop > /sys/kernel/debug/tracing/current_tracer
sudo echo 1 > /sys/kernel/debug/tracing/events/i2c/enable
sudo echo 1 > /sys/kernel/debug/tracing/tracing_on
```

### i2c tracing

Generate some traffic on i2c bus and view the tracing log

```shell
sudo i2cdetect -y 0
sudo cat /sys/kernel/debug/tracing/trace
```
