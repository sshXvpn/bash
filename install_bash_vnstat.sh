#!/bin/bash

if [ -x "$(command -v vnstat)" ]; then
    /etc/init.d/vnstat stop >/dev/null 2>&1

    vnstat_dir=$(find / -type d -name "vnstat-*" 2>/dev/null | sort -r | head -n 1)

    if [ -n "$vnstat_dir" ]; then
        make uninstall -C "$vnstat_dir" >/dev/null 2>&1
    else
        echo "vnStat installation directory not found. Skipping uninstallation."
    fi
fi

wget -q https://humdi.net/vnstat/vnstat-2.6.tar.gz
tar zxvf vnstat-2.6.tar.gz
cd vnstat-2.6

./configure --prefix=/usr --sysconfdir=/etc >/dev/null 2>&1
make >/dev/null 2>&1
make install >/dev/null 2>&1

cd

vnstat -u -i $NET

sed -i 's/Interface "eth0"/Interface "'"$NET"'"/g' /etc/vnstat.conf

chown vnstat:vnstat /var/lib/vnstat -R

systemctl enable vnstat >/dev/null 2>&1

/etc/init.d/vnstat restart >/dev/null 2>&1

rm -f /root/vnstat-2.6.tar.gz >/dev/null 2>&1
rm -rf /root/vnstat-2.6 >/dev/null 2>&1
