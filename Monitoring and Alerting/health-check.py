import sys
import re
from scapy.all import *
import logging
import argparse
from colorama import init, Fore, Style

# Initialize colorama
init(autoreset=True)

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger()

def is_valid_ip(ip):
    pattern = re.compile(r"^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$")
    return bool(pattern.match(ip))

def is_valid_port(port):
    return 0 < port <= 65535

def is_host_alive(target_ip, quiet):
    icmp = IP(dst=target_ip)/ICMP()
    if not quiet:
        logger.info(f"{Fore.YELLOW}Sending ICMP ping to {target_ip}")
    response = sr1(icmp, timeout=2, verbose=0)
    
    if response:
        if not quiet:
            logger.info(f"{Fore.GREEN}Received ICMP response from {target_ip}")
        return True
    else:
        if not quiet:
            logger.warning(f"{Fore.RED}No ICMP response from {target_ip}")
        return False

def create_synack_connection(target_ip, target_port, quiet):
    if not is_host_alive(target_ip, quiet):
        return False
    
    syn = IP(dst=target_ip)/TCP(dport=target_port, flags='S')
    if not quiet:
        logger.info(f"{Fore.YELLOW}Sending SYN packet to {target_ip}:{target_port}")
    syn_ack = sr1(syn, timeout=2, verbose=0)
    
    if syn_ack and syn_ack.haslayer(TCP) and syn_ack[TCP].flags == 'SA':
        if not quiet:
            logger.info(f"{Fore.GREEN}Received SYN-ACK from {target_ip}:{target_port}")
        
        ack = IP(dst=target_ip)/TCP(dport=target_port, flags='A', seq=syn_ack.ack, ack=syn_ack.seq + 1)
        if not quiet:
            logger.info(f"{Fore.YELLOW}Sending ACK packet to {target_ip}:{target_port}")
        send(ack, verbose=0)
        
        if not quiet:
            logger.info(f"{Fore.GREEN}Connection established successfully!")
        
        fin = IP(dst=target_ip)/TCP(dport=target_port, flags='FA', seq=ack.seq, ack=ack.ack)
        if not quiet:
            logger.info(f"{Fore.YELLOW}Sending FIN packet to {target_ip}:{target_port}")
        fin_ack = sr1(fin, timeout=2, verbose=0)
        
        if fin_ack and fin_ack.haslayer(TCP):
            if fin_ack[TCP].flags == 'FA':
                if not quiet:
                    logger.info(f"{Fore.GREEN}Received FIN-ACK from {target_ip}:{target_port}")
                
                final_ack = IP(dst=target_ip)/TCP(dport=target_port, flags='A', seq=fin_ack.ack, ack=fin_ack.seq + 1)
                send(final_ack, verbose=0)
                
                if not quiet:
                    logger.info(f"{Fore.GREEN}Connection closed gracefully!")
                return True
            elif fin_ack[TCP].flags == 'R':
                if not quiet:
                    logger.info(f"{Fore.YELLOW}Received RST from {target_ip}:{target_port}. Considering connection closed gracefully.")
                return True
        else:
            if not quiet and fin_ack:
                fin_ack.show()
            if not quiet:
                logger.warning(f"{Fore.RED}No FIN-ACK received from {target_ip}:{target_port}")
            return False
    else:
        if not quiet and syn_ack:
            syn_ack.show()
        if not quiet:
            logger.warning(f"{Fore.RED}No SYN-ACK received from {target_ip}:{target_port}")
        return False

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='TCP connection tester')
    parser.add_argument('target_ip', type=str, help='Target IP address')
    parser.add_argument('target_port', type=int, help='Target port number')
    parser.add_argument('--quiet', action='store_true', help='Enable quiet mode')

    args = parser.parse_args()
    target_ip = args.target_ip
    target_port = args.target_port
    quiet = args.quiet

    if not is_valid_ip(target_ip):
        if not quiet:
            logger.error(f"{Fore.RED}Invalid IP address format")
        sys.exit(1)
    
    if not is_valid_port(target_port):
        if not quiet:
            logger.error(f"{Fore.RED}Invalid port number. Must be between 1 and 65535")
        sys.exit(1)

    result = create_synack_connection(target_ip, target_port, quiet)
    if quiet:
        if result:
            print(Fore.GREEN + "True")
        else:
            print(Fore.RED + "False")
    else:
        if result:
            logger.info(f"{Fore.GREEN}Connection closed gracefully!")
        else:
            logger.warning(f"{Fore.RED}Connection not closed gracefully")
    sys.exit(0 if result else 1)
