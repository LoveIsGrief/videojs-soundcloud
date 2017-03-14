XVFB=/usr/bin/Xvfb
XVFBARGS=":99 -ac -screen 0 1024x768x24"
PIDFILE=/tmp/cucumber_xvfb_99.pid
case "$1" in
  start)
    echo -n "Starting virtual X frame buffer: Xvfb"
    /sbin/start-stop-daemon --start --pidfile $PIDFILE --make-pidfile --background --exec $XVFB -- $XVFBARGS
    ;;
  stop)
    echo -n "Stopping virtual X frame buffer: Xvfb"
    /sbin/start-stop-daemon --stop --pidfile $PIDFILE
    rm -f $PIDFILE
    ;;
  restart)
    $0 stop
    $0 start
    ;;
  *)
    echo "Usage: /etc/init.d/xvfb {start|stop|restart}"
    exit 1
    ;;
esac
