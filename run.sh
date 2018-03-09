#!/bin/bash

echo "${TZ:-UTC}" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

