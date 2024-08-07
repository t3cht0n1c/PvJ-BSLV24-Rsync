import sys
import re
from scapy.all import *
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger()

def is_valid_ip(ip):
    pattern = re.compile(r"^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$")
    return bool(pattern.match(ip))

def is_valid_port(port):
    return 0 < port <= 65535

def is_host_alive(target_ip):
    icmp = IP(dst=target_ip)/ICMP()
    logger.info(f"Sending ICMP ping to {target_ip}")
    response = sr1(icmp, timeout=2, verbose=0)
    
    if response:
        logger.info(f"Received ICMP response from {target_ip}")
        return True
    else:
        logger.warning(f"No ICMP response from {target_ip}")
        return False

def create_synack_connection(target_ip, target_port):
    if not is_host_alive(target_ip):
        sys.exit(1)
    
    syn = IP(dst=target_ip)/TCP(dport=target_port, flags='S')
    logger.info(f"Sending SYN packet to {target_ip}:{target_port}")
    syn_ack = sr1(syn, timeout=2, verbose=0)
    
    if syn_ack and syn_ack.haslayer(TCP) and syn_ack[TCP].flags == 'SA':
        logger.info(f"Received SYN-ACK from {target_ip}:{target_port}")
        
        ack = IP(dst=target_ip)/TCP(dport=target_port, flags='A', seq=syn_ack.ack, ack=syn_ack.seq + 1)
        logger.info(f"Sending ACK packet to {target_ip}:{target_port}")
        send(ack, verbose=0)
        
        logger.info("Connection established successfully!")
        
        fin = IP(dst=target_ip)/TCP(dport=target_port, flags='FA', seq=ack.seq, ack=ack.ack)
        logger.info(f"Sending FIN packet to {target_ip}:{target_port}")
        fin_ack = sr1(fin, timeout=2, verbose=1)  # Enable verbose for debugging
        
        if fin_ack and fin_ack.haslayer(TCP):
            if fin_ack[TCP].flags == 'FA':
                logger.info(f"Received FIN-ACK from {target_ip}:{target_port}")
                
                final_ack = IP(dst=target_ip)/TCP(dport=target_port, flags='A', seq=fin_ack.ack, ack=fin_ack.seq + 1)
                send(final_ack, verbose=0)
                
                logger.info("Connection closed gracefully!")
                sys.exit(0)
            elif fin_ack[TCP].flags == 'R':
                logger.info(f"Received RST from {target_ip}:{target_port}. Considering connection closed gracefully.")
                sys.exit(0)
        else:
            if fin_ack:
                fin_ack.show()
            logger.warning(f"No FIN-ACK received from {target_ip}:{target_port}")
            sys.exit(1)
    else:
        if syn_ack:
            syn_ack.show()
        logger.warning(f"No SYN-ACK received from {target_ip}:{target_port}")
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        logger.error("Usage: python script_name.py <target_ip> <target_port>")
        sys.exit(1)
    
    target_ip = sys.argv[1]
    try:
        target_port = int(sys.argv[2])
    except ValueError:
        logger.error("Port number must be an integer")
        sys.exit(1)
    
    if not is_valid_ip(target_ip):
        logger.error("Invalid IP address format")
        sys.exit(1)
    
    if not is_valid_port(target_port):
        logger.error("Invalid port number. Must be between 1 and 65535")
        sys.exit(1)
    
    create_synack_connection(target_ip, target_port)
