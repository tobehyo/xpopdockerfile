#!/bin/sh
echo Start XPOP
/xpop/bin/xpopserver start && tail -f > /dev/null