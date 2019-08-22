#!/bin/sh
# 此脚本路径：/etc/storage/serverchan_script.sh
# 自定义设置 - 脚本 - 自定义 Crontab 定时任务配置，可自定义启动时间
source /etc/storage/script/init.sh
export PATH='/etc/storage/bin:/tmp/script:/etc/storage/script:/opt/usr/sbin:/opt/usr/bin:/opt/sbin:/opt/bin:/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin'
export LD_LIBRARY_PATH=/lib:/opt/lib
serverchan_enable=`nvram get serverchan_enable`
serverchan_enable=${serverchan_enable:-"0"}
serverchan_sckey=`nvram get serverchan_sckey`
serverchan_notify_1=`nvram get serverchan_notify_1`
serverchan_notify_2=`nvram get serverchan_notify_2`
serverchan_notify_3=`nvram get serverchan_notify_3`
serverchan_notify_4=`nvram get serverchan_notify_4`
mkdir -p /tmp/var
resub=1
# 获得外网地址
    arIpAddress() {
    curltest=`which curl`
    if [ -z "$curltest" ] || [ ! -s "`which curl`" ] ; then
        #wget --no-check-certificate --quiet --output-document=- "https://www.ipip.net" | grep "IP地址" | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1
        wget --no-check-certificate --quiet --output-document=- "http://members.3322.org/dyndns/getip" | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1
        #wget --no-check-certificate --quiet --output-document=- "ip.6655.com/ip.aspx" | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1
        #wget --no-check-certificate --quiet --output-document=- "ip.3322.net" | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1
    else
        #curl -L -k -s "https://www.ipip.net" | grep "IP地址" | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1
        curl -k -s "http://members.3322.org/dyndns/getip" | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1
        #curl -k -s ip.6655.com/ip.aspx | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1
        #curl -k -s ip.3322.net | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1
    fi
    }
# 读取最近外网地址
    lastIPAddress() {
        inter="/etc/storage/lastIPAddress"
        cat $inter
    }

while [ "$serverchan_enable" = "1" ];
do
serverchan_enable=`nvram get serverchan_enable`
serverchan_enable=${serverchan_enable:-"0"}
serverchan_sckey=`nvram get serverchan_sckey`
serverchan_notify_1=`nvram get serverchan_notify_1`
serverchan_notify_2=`nvram get serverchan_notify_2`
serverchan_notify_3=`nvram get serverchan_notify_3`
serverchan_notify_4=`nvram get serverchan_notify_4`

//add line by CaoJie in 2019.8.14
cat /proc/1/net/arp | tail -n +2 | grep -v "^$" | awk -F " " '{ if ($3!=0x0) print ""$4""}' | tr [a-z] [A-Z] > /tmp/online_device

dmesg -c && iwpriv ra0 show stainfo
dmesg | tail -n +7 | awk -F " " '{if($1!="")print ""$1""}' >> /tmp/online_device

sleep 1

dmesg -c && iwpriv rai0 show stainfo
dmesg | tail -n +7 | awk -F " " '{if($1!="")print ""$1""}' >> /tmp/online_device

awk -F ","  'NR==FNR{a[$1]=1}NR>FNR{if($2 in a){print""$1","$2","$3","$4","$5",0"}else{print""$1","$2","$3","$4","$5",1"}}' /tmp/online_device /tmp/static_ip.inf > /tmp/static_ip_new.inf

cp /tmp/static_ip_new.inf /tmp/static_ip.inf

//logger -t "【微信推送】" "刷新：/tmp/static_ip.inf"



//

curltest=`which curl`
ping_text=`ping -4 114.114.114.114 -c 1 -w 2 -q`
ping_time=`echo $ping_text | awk -F '/' '{print $4}'| awk -F '.' '{print $1}'`
ping_loss=`echo $ping_text | awk -F ', ' '{print $3}' | awk '{print $1}'`
if [ ! -z "$ping_time" ] ; then
    echo "ping：$ping_time ms 丢包率：$ping_loss"
 else
    echo "ping：失效"
fi
if [ ! -z "$ping_time" ] ; then
echo "online"
if [ "$serverchan_notify_1" = "1" ] ; then
    hostIP=$(arIpAddress)
    hostIP=`echo $hostIP | head -n1 | cut -d' ' -f1`
    if [ "$hostIP"x = "x"  ] ; then
        curltest=`which curl`
        if [ -z "$curltest" ] || [ ! -s "`which curl`" ] ; then
            [ "$hostIP"x = "x"  ] && hostIP=`wget --no-check-certificate --quiet --output-document=- "ip.6655.com/ip.aspx" | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1`
            [ "$hostIP"x = "x"  ] && hostIP=`wget --no-check-certificate --quiet --output-document=- "http://members.3322.org/dyndns/getip" | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1`
            [ "$hostIP"x = "x"  ] && hostIP=`wget --no-check-certificate --quiet --output-document=- "ip.3322.net" | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1`
            [ "$hostIP"x = "x"  ] && hostIP=`wget --no-check-certificate --quiet --output-document=- "https://www.ipip.net/" | grep "IP地址" | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1`
        else
            [ "$hostIP"x = "x"  ] && hostIP=`curl -k -s ip.6655.com/ip.aspx | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1`
            [ "$hostIP"x = "x"  ] && hostIP=`curl -k -s "http://members.3322.org/dyndns/getip" | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1`
            [ "$hostIP"x = "x"  ] && hostIP=`curl -k -s ip.3322.net | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1`
            [ "$hostIP"x = "x"  ] && hostIP=`curl -L -k -s "https://www.ipip.net" | grep "IP地址" | grep -E -o '([0-9]+\.){3}[0-9]+' | head -n1 | cut -d' ' -f1`
        fi
    fi
    lastIP=$(lastIPAddress)
    if [ "$lastIP" != "$hostIP" ] && [ ! -z "$hostIP" ] ; then
    sleep 60
        hostIP=$(arIpAddress)
        hostIP=`echo $hostIP | head -n1 | cut -d' ' -f1`
        lastIP=$(lastIPAddress)
    fi
    if [ "$lastIP" != "$hostIP" ] && [ ! -z "$hostIP" ] ; then
        logger -t "【互联网 IP 变动】" "目前 IP: ${hostIP}"
        logger -t "【互联网 IP 变动】" "上次 IP: ${lastIP}"
        curl -s "http://sc.ftqq.com/$serverchan_sckey.send?text=【PDCN_"`nvram get computer_name`"】互联网IP变动" -d "&desp=${hostIP}" &
        logger -t "【微信推送】" "互联网IP变动:${hostIP}"
        echo -n $hostIP > /etc/storage/lastIPAddress
    fi
fi
if [ "$serverchan_notify_2" = "1" ] ; then
    # 获取接入设备名称
    touch /tmp/var/newhostname.txt
	echo "已登记设备列表" > /tmp/var/newhostname.txt
    #cat /tmp/syslog.log | grep 'Found new hostname' | awk '{print $7" "$8}' >> /tmp/var/newhostname.txt
	cat /tmp/static_ip_new.inf | grep -v "^$" | awk -F "," '{ if ( $6 == 0 ) print ""$1" "$2" "$3""}' > /tmp/var/newhostname.txt
	
	
    # 读取以往接入设备名称
    touch /etc/storage/hostname.txt
	[ ! -s /etc/storage/hostname.txt ] && echo "已登记设备列表" > /etc/storage/hostname.txt
    # 获取新接入设备名称
	awk -F " "  'NR==FNR{a[$1]=1}NR>FNR{if($1 in a){}else{print""$1" "$2" "$3""}}' /etc/storage/hostname.txt /tmp/var/newhostname.txt > /tmp/var/newhostname不重复.txt

    if [ -s "/tmp/var/newhostname不重复.txt" ] ; then
        content=`awk -F " " '{print "IP"$1", MAC: "$2"\n\nName: "$3"\n\n\n"}' /tmp/var/newhostname不重复.txt`
        curl -s "http://sc.ftqq.com/SCU34310T59d5701493a443f694e73757af5989f25bc72eff8281e.send?text="`nvram get computer_name`"_New_drivec_online" -d "&desp=${content}" &
        logger -t "ServerChan.sh" "New_drivec_online:${content}"
        cat /tmp/var/newhostname不重复.txt >> /etc/storage/hostname.txt
    fi
fi
if [ "$serverchan_notify_4" = "1" ] ; then
    # 设备上、下线提醒
    # 获取接入设备名称
	run_time=$(date +%m-%d_%H:%M)
	echo $run_time
    touch /tmp/var/newhostname.txt
    echo "online device list" > /tmp/var/newhostname.txt
    #cat /tmp/syslog.log | grep 'Found new hostname' | awk '{print $7" "$8}' >> /tmp/var/newhostname.txt
	echo "zore"
    cat /tmp/static_ip_new.inf | grep -v "^$" | awk -F "," '{ if ( $6 == 0 ) print ""$2" "$3""}' >> /tmp/var/newhostname.txt
    # 读取以往上线设备名称
    touch /etc/storage/hostname_上线.txt
    [ ! -s /etc/storage/hostname_上线.txt ] && echo "online device list" > /etc/storage/hostname_上线.txt
    # 上线
    #awk 'NR==FNR{a[$0]++} NR>FNR&&a[$0]' /etc/storage/hostname_上线.txt /tmp/var/newhostname.txt > /tmp/var/newhostname相同行_上线.txt
    #awk 'NR==FNR{a[$0]++} NR>FNR&&!a[$0]' /tmp/var/newhostname相同行_上线.txt /tmp/var/newhostname.txt > /tmp/var/newhostname不重复_上线.txt
	echo "one"
	
	awk -F " "  'NR==FNR{a[$1]=1}NR>FNR{if($1 in a){}else{print""$1" "$2" '$run_time'"}}' /etc/storage/hostname_上线.txt /tmp/var/newhostname.txt > /tmp/var/newhostname不重复_上线.txt
	
    if [ -s "/tmp/var/newhostname不重复_上线.txt" ] ; then
        content=`awk -F " " '{print ""$3",MAC: "$1"\n\nName: "$2"\n\n\n"}' /tmp/var/newhostname不重复_上线.txt`
        curl -s "http://sc.ftqq.com/$serverchan_sckey.send?text="`nvram get computer_name`"_Client_Online" -d "&desp=${content}" &
                logger -t "ServerChan.sh" "Client_Online:${content}"
        cat /tmp/var/newhostname不重复_上线.txt >> /etc/storage/hostname_上线.txt 
		
    fi
    #下线
	echo "two"
   awk -F " "  'NR==FNR{a[$1]=1}NR>FNR{if($1 in a){}else{print""$1" "$2" "$3""}}' /tmp/var/newhostname.txt /etc/storage/hostname_上线.txt > /tmp/var/newhostname不重复_下线.txt
   
    if [ -s "/tmp/var/newhostname不重复_下线.txt" ] ; then
        content=`awk -F " " '{print ""$3",MAC: "$1"\n\nName: "$2"\n\n\n"}' /tmp/var/newhostname不重复_下线.txt`
        curl -s "http://sc.ftqq.com/$serverchan_sckey.send?text="`nvram get computer_name`"_Client_Offline" -d "&desp=${content}" &
		logger -t "ServerChan.sh" "Client_Offline:${content}"
        #cat /tmp/var/newhostname.txt | grep -v "^$" > /etc/storage/hostname_上线.txt
		
	
		awk -F " "  'NR==FNR{a[$1]=1}NR>FNR{if($1 in a){print""$1" "$2" "$3""}else{}}' /tmp/var/newhostname.txt /etc/storage/hostname_上线.txt > /etc/storage/hostname_上线_new.txt
		cp /etc/storage/hostname_上线_new.txt /etc/storage/hostname_上线.txt
		
    fi
fi
if [ "$serverchan_notify_3" = "1" ] && [ "$resub" = "1" ] ; then
    # 固件更新提醒
    [ ! -f /tmp/var/osub ] && echo -n `nvram get firmver_sub` > /tmp/var/osub
    rm -f /tmp/var/nsub
    wgetcurl.sh "/tmp/var/nsub" "$hiboyfile/osub" "$hiboyfile2/osub"
    if [ $(cat /tmp/var/osub) != $(cat /tmp/var/nsub) ] && [ -f /tmp/var/nsub ] ; then
        echo -n `nvram get firmver_sub` > /tmp/var/osub
        content="新的固件： `cat /tmp/var/nsub | grep -v "^$"` ，目前旧固件： `cat /tmp/var/osub | grep -v "^$"` "
        logger -t "【微信推送】" "固件 新的更新：${content}"
        curl -s "http://sc.ftqq.com/$serverchan_sckey.send?text=【PDCN_"`nvram get computer_name`"】固件更新提醒" -d "&desp=${content}" &
        echo -n `cat /tmp/var/nsub | grep -v "^$"` > /tmp/var/osub
    fi
fi
    resub=`expr $resub + 1`
    [ "$resub" -gt 360 ] && resub=1
else
echo "Internet down 互联网断线"
resub=1
fi
sleep 60
continue
done
