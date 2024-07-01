#!/usr/bin/env python
import socket
import os

#hosts to avoid blacklisting
whitelist = ['127.0.0.1','localhost']

#ports to show as up to blacklisted clients
#Think about what the attacker will think if he sees different profiles before and after a scan
ports = ['21','80','445']

#IP to bind to.  Leave as empty string to bind to all available IPs
ADDR=''

#Port to bind to.  This will be the listening port.  A scan here will trigger the defenses
PORT = 443

#Name of blacklist file
filename = "blacklist"

def add_blacklist(ip):
	fi = open(filename,"a")
	fi.write(" "+ip)
	fi.close()

def check_blacklist(ip):
	fi = open(filename,"r")
	data = fi.read()
	fi.close()
	return ip in data

def blacklist(ip):
	if ip in whitelist or check_blacklist(ip):
		return False
	else:
		query = "iptables -A INPUT -s %s -p tcp ! --destination-port %s -j DROP" % (ip, PORT)
		os.system(query)
		for port in ports:
			query = "iptables -t nat -A PREROUTING -s %s -p tcp --dport %s -j REDIRECT --to-port %s" % (ip,port,PORT)
			os.system(query)
		add_blacklist(ip)
	return True

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind((ADDR,PORT))
s.listen(5)

while True:
	con, adr = s.accept()
	try:
		data = con.recv(2048)
		con.send("Protocol Error")
		con.close()
	except:
		print "Socket error"
	blacklist(adr[0])
