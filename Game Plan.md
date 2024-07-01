Game Plan and Initial Objectives
=================================

Admin
------
* Once connected to the vpn and range access confirmed, populate all team IPs into spreadsheet for reconciliation
* Create and share a Password sheet for team to keep track of changed creds

Global
-------
* Change admin passwords
* Remove non-admin team accounts - full user account sanitation
* Perform ALL security updates on OS and Apps

Firewall
--------
* Upgrade
* Turn on certs everywhere / turn off ssh password auth (use keys only)
* Start configuring inbound access rules to necessary hosts and ports, must be allowed from any, and no source blocking is allowed.
* Ensure that all DNS traffic is allowed in and outbound - Scoring is reliant on DNS resolution and must be able to hit and resolve from our DNS server
* Confirm admin access to the outside interface of firewall in case of lockout after rule set is put in place - vpn allows access to the range, does not put us on the range net
* Allow all inbound from team IPs
* NOTE that rules may well be active that are **invisible to the web GUI...** $ pfctl -v -sr  # to see in-memory rules that aren't in the XML file
* HUNT FOR SHELLS / Can switch this effort to threat hunting on the Linux servers if the pfSense upgrade was successful
* Install SNORT or Suricata

Linux
-----
* Nuke Authorized keys content
* Add team's Authorized Keys and if all keys are added, disable password-based authentication on SSH
* Hash auth keys file and kick off script/cron to dif the current to hash
* Look at cron jobs and systemd timers
* Check active connections
* Check running processes
* Hunt Webshells
* LinPEAS
* Check /tmp
* Check .bashrc or equivalent
* Check standard configuration files
* Check service scripts, are the running services actually calling the correct and only the correct binaries
* Dont trust binaries
* Which commands to show what binaries are being used, is the netstat command actually running and showing active connections, or is it manipulated?

Windows
-------
* [GlassWire](https://www.glasswire.com/)
* [PingCastle](https://www.pingcastle.com/)
* [PurpleKnight](https://www.purple-knight.com/)
* Bloodhound
* AD & GPO Audit
  * Check default domain policy and strengthen password requirements
  * Check all Built in accounts and groups
  * User Rights Assignments
  * GPO to restrict the addition of accounts to domain admin group
  * GPO to stop exe's from running out of temp and appdata
  * Remove inactive computers and users
  * Audit Policies
* Disable local admin on non DCs?
* Delete users from local admin group
* Install Sysmon and apply config
* Install SysInternals Suite
* Security Baseline and Benchmark tools?
* Protect Default AD Security Groups
* Ensure you are not vulnerable to kerberoasting
* Check for accounts with KERBEROS PRE AUTHENTICATION DISABLED
* Look for accounts with “Does not require password”
* Look for accounts with “Password never set”
* disable LM hashes
* Disable Spool Services
* Check Temp Directory
* Check Scheduled Tasks
* Persistence clean up, some methods [here](https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/Methodology%20and%20Resources/Windows%20-%20Persistence.md)
  * Registry
  * Scheduled Tasks
  * WMI Events
  * NTFS ADS
  * BITS Jobs
