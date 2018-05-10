iptables一共有3个table，分别是filter，nat和xxx。其中filter表是默认的表，如果不用-t参数指定，默认使用iptables命令时是对filter表进行修改。每个table有若干个chain，每个chain有若干个规则和一个policy。对iptables的配置就是针对某一个table的rru若干个chains，增加或者删除规则。

# 配置NAT

假设NAT主机有两个网卡，一块连接公网，IP地址为10.0.0.1，另一块连接内网，IP地址为192.168.1.1。NAT主机可以实现两个功能：一是内网（192.168.1.0/24）中的主机可以通过NAT访问外网；二是外网的主机可以通过NAT访问内网主机提供的服务。

## 1. 内网访问外网

修改内网主机发往公网报文的源地址。我们需要在iptables的nat表的POSTROUTING链上增加规则：

    sudo iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -j SNAT --to-source 10.0.0.1

同时我们需要在filter表的forword链上增加规则，允许NAT主机转发来自192.168.1.0/24网段的地址

    sudo iptables -A FORWARD -s 192.168.1.0/24 -j ACCEPT

同时，为了外网返回的报文能够回到内网，我们要允许主机转发发往192.168.1.0/24网段的地址
```
sudo iptables -A FORWARD -d 192.168.1.0/24 -j ACCEPT
``` 
如果公网网卡是动态获得IP地址的，可以使用下面的方法设置：
```
sudo iptables -t nat -A POSTROUTING -s ${INTERNAL_SUB_NET} -o ${WAN} -j MASQUERADE
sudo iptables -A FORWARD -i eth0 -o wlan0 -j ACCEPT
```
## 2. 外网访问内网主机

这里主要使用目的地址转换和端口映射

公网通过NAT访问内网主机需要在nat表的PREROUTING链上修改目的地址。之所以要在PREROUTING链上做是因为目的地址的修改必须发生在路由之前，这样路由才能把报文发送到修改后的目的地址。

    sudo iptables -t nat -A PREROUTING  -d 10.0.0.1 -p tcp -j DNAT --to-destination 192.168.1.2

这样NAT会把所有发给10.0.0.1的报文转发给内网的192.168.1.2主机。

上述规则还可以加上源地址限制，只允许符合条件的公网地址访问内网主机：

    sudo iptables -t nat -A PREROUTING -s 10.0.0.0/24 -d 10.0.0.1 -p tcp -j DNAT --to-destination 192.168.1.2

这样一来，就只有10.0.0.0/24这个网段的公网地址可以访问到内网的192.168.1.2主机

如果我们仅开放内网主机的某一个服务，可以做端口映射：

    sudo iptables -t nat -A PREROUTING -d 10.0.0.1 -p tcp 80 --dport -j DNAT --to-destination 192.168.1.2

还可以把公网地址的端口映射为内网主机不同的端口：

    sudo iptables -t nat -A PREROUTING -d 10.0.0.1 -p tcp 80 --dport -j DNAT --to-destination 192.168.1.2:8080
