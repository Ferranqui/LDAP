#!/bin/bash
route add -net 192.168.3.0/24 dev enp0s8
iptables -t nat -A POSTROUTING ! -d 192.168.3.0/24 -o enp0s3 -j SNAT --to-source 192.168.28.158

