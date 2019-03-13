#!/bin/bash

/usr/local/lsws/bin/lswsctrl start
/usr/bin/tail -F /usr/local/lsws/logs/error.log
/usr/local/lsws/bin/lswsctrl stop
