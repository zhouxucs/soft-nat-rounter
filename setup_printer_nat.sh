PRINTER_IP=10.0.0.0/24
#PRINTER_SUBNET=192.168.1.0/24
THIS_INTERNAL_IP=192.168.43.182
#INTERNAL_SUB_NET=10.0.0.0/24
#PRINTER_PORT=80

sudo iptables -t nat -A POSTROUTING -s ${PRINTER_IP} -j SNAT --to-source ${THIS_INTERNAL_IP}
#sudo iptables -t nat -A PREROUTING -d 10.0.0.111 -p tcp --dport 80 -j DNAT --to-destination 192.168.1.2
sudo iptables -A FORWARD -s ${PRINTER_IP} -j ACCEPT
sudo iptables -A FORWARD -d ${PRINTER_IP} -j ACCEPT
#sudo iptables -t nat -A PREROUTING -d ${THIS_INTERNAL_IP} -p tcp --dport ${PRINTER_PORT} -j DNAT --to-destination ${PRINTER_IP}
#sudo iptables -t nat -A PREROUTING -s ${INTERNAL_SUB_NET} -d ${THIS_INTERNAL_IP} -p tcp -j DNAT --to-destination ${PRINTER_IP}
