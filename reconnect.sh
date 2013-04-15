#!/bin/bash
max_reconnect_tryouts=10
max_ip_tests=2
sleep_t=5
sleep_t_test=3
fritz_address="http://fritz.box"
function getIP()
{
    ip=$(curl "$fritz_address:49000/upnp/control/WANIPConn1" -H "Content-Type: text/xml; charset='utf-8'" -H "SoapAction:urn:schemas-upnp-org:service:WANIPConnection:1#GetExternalIPAddress" -d "<?xml version='1.0' encoding='utf-8'?> <s:Envelope s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/' xmlns:s='http://schemas.xmlsoap.org/soap/envelope/'> <s:Body> <u:GetExternalIPAddress xmlns:u='urn:schemas-upnp-org:service:WANIPConnection:1' /> </s:Body> </s:Envelope>" -s | xmllint --xpath "//NewExternalIPAddress/text()" -)
    echo $ip
}

oldip=$(getIP)
echo "Old IP: $oldip"
for (( i=1;i<=$max_reconnect_tryouts;i++))
do
   echo "Starting Reconnect $i of $max_reconnect_tryouts ..."
   curl "$fritz_address:49000/upnp/control/WANIPConn1" -s -H "Content-Type: text/xml; charset='utf-8'" -H "SoapAction:urn:schemas-upnp-org:service:WANIPConnection:1#ForceTermination" -d "<?xml version='1.0' encoding='utf-8' ?><s:Envelope s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/' xmlns:s='http://schemas.xmlsoap.org/soap/envelope/'><s:Body><u:ForceTermination xmlns:u='urn:schemas-upnp-org:service:WANIPConnection:1' /></s:Body></s:Envelope>" > /dev/null
   sleep $sleep_t
   for (( l=1;l<=$max_ip_tests;l++))
   do     
     newip=$(getIP)
     echo "Actual IP: $newip"
     if [ $newip != $oldip ]; then
       echo "Reconnect succesfull"
       exit 0
     fi
     sleep $sleep_t_test
   done
done
echo "Reconnect failed"
exit 0
