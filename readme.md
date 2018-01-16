iptables一共有3个table，分别是filter，nat和xxx。每个table有若干个chain，每个chain有若干个规则和一个policy。对iptables的配置就是针对某一个table的rru若干个chains，增加或者删除规则。

# 配置NAT

假设NAT主机有两个网卡，一块连接公网，IP地址为10.0.0.1，另一块连接内网，IP地址为192.168.1.1。NAT主机可以实现两个功能：一是内网（192.168.1.0/24）中的主机可以通过NAT访问外网；二是外网的主机可以通过NAT访问内网主机提供的服务。

## 1. 内网访问外网

修改内网主机发往公网报文的源地址。我们需要在iptables的nat表的postroute链上增加规则：

iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -j SNAT --to-source 10.0.0.1

同时我们需要在filter表的forword链上增加规则，允许NAT主机转发来自192.168.1.0/24网段的地址

iptables -A FORWARD -s 192.168.1.0/24 -j ACCEPT

同时，为了外网返回的报文能够回到内网，我们要允许主机转发发往192.168.1.0/24网段的地址

iptables -A FORWARD -d 192.168.1.0/24 -j ACCEPT

## 2. 外网访问内网主机

这里主要使用目的地址转换和端口映射

