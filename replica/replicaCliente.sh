#!/bin/bash
/etc/init.d/slapd stop
slapadd -c -l /home/ubuntu/replica.ldif
/etc/init.d/slapd start
