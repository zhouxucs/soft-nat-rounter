WAN=wlan0
LAN=eth0
#PUBLIC_IP=172.20.10.5
INTERNAL_SUB_NET=10.0.0.0/24

#sudo iptables -t nat -A POSTROUTING -s ${INTERNAL_SUB_NET} -j SNAT --to-source ${PUBLIC_IP}
#sudo iptables -A FORWARD -s ${INTERNAL_SUB_NET} -j ACCEPT
sudo iptables -t nat -A POSTROUTING -s ${INTERNAL_SUB_NET} -o ${WAN} -j MASQUERADE
sudo iptables -A FORWARD -i ${LAN} -o ${WAN} -j ACCEPT
