# Active Defense: CLI Edition

*Techniques and ideas organized by priority for actively identifying and fighting threats to regain control of a system manually.*

***DISCLAIMER**: Some ideas were suggested by ChatGPT (and were verified to work). Others were gleaned from various trainings, or were written from scratch.*


## Evidence Collection: PEASS / UAC

Run PEASS-ng in the background and write it to a log file. This could be the first thing to do while you start working.

```bash
# https://github.com/peass-ng/PEASS-ng
# https://gitlab.com/kalilinux/packages/peass-ng
URL='https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh'
URL='https://gitlab.com/kalilinux/packages/peass-ng/-/raw/kali/master/linpeas.sh'
wget "$URL"
curl -LfO "$URL"
sh ./linpeas.sh | tee PEAS_$(hostname).log >/dev/null &
```

```powershell
# https://github.com/peass-ng/PEASS-ng
# https://gitlab.com/kalilinux/packages/peass-ng
$url = "https://github.com/peass-ng/PEASS-ng/releases/latest/download/winPEASany.exe"
$url = "https://gitlab.com/kalilinux/packages/peass-ng/-/raw/kali/master/winPEASany.exe"
iwr $url -OutFile $env:TEMP\winPEAS.exe
Start-Process -File $env:TEMP\winPEAS.exe -ArgumentList "log='PEAS_'$env:COMPUTERNAME'.log'"
```

After initial triage, it could be useful to run this as a scheduled / cron task without ANSII color encoding, and diff the results to see if we're missing anything.

This example is a simple copy-and-paste block that runs linpeas, with only user enumeration, and then diffs the results.

```bash
# This creates the following files:
# - PEAS_<hostname>.log
# - PEAS_<hostname>.log.1
if [[ -e PEAS_$(hostname).log ]]; then mv PEAS_$(hostname).log PEAS_$(hostname).log.1; fi
sh ./linpeas.sh -o users_information -N | tee PEAS_$(hostname).log
diff ./*.log ./*.log.1 --color
```

UAC (Unix Artifacts Collector) is similar, though it is much more evidence gathering focused, and less of a human-readable log. Think of it as a very fast and effective text-based snapshot of a system. The idea is to run this on endpoints, to have the evidence for review offline in a trusted VM. Use PEASS to point you to IOC's, use UAC to see if you can find additional information about those IOC's. Yara (and the standard GNU coreutils) can help you parse even more information from the resulting log files.

```bash
cd /dev/shm
git clone https://github.com/tclahr/uac
cd uac
mkdir results
./uac -p ir_triage ./results
# Collect the results files when it's done
```

*There's a bin/ path in the uac folder where you can place trusted / statically compiled binaries like strings or lsof. UAC will use those over any system binaries in case they're compromised.*


## System Packages / Applications

Before hashing everything (which will produce more hashes than we can check with a free VT API key), use the package manager to check for easy wins. Instead of hashing a potentially compromised system, Yara may be a much more efficient way to scan an entire machine with the right set of rules.

```bash
# Debian family OS's, without a package-name, all are checked
sudo dpkg -V [package-name]

# Fedora family OS's, without a package-name, all are checked
sudo rpm -V [package-name]
```

If anything's weird there, review sha256 hashes on VirusTotal. PEASS-ng will also let you know if it finds anything weird once it's done.


## Accounts

Quickly look at user accounts

```bash
# Sort and review /etc/passwd file based on UID
sort -t: -k3n /etc/passwd

# Who has a shell defined or can login?
sort -t: -k3n /etc/passwd | grep -Pv "nologin"

# Get all UID's between 1000 and 65535 (aka the nobody user)
awk -F: '($3 >= 1000 && $3 <= 65535)' /etc/passwd | sort -t: -k3n
```

```powershell
net user [/domain]
Get-LocalUser -Name *
Get-LocalGroupMember -Group "Administrators"
```


## Filesystem Triage

Use bash, sh and PowerShell to see the most recent filesystem activity.

```bash
# find works a little differently than PowerShell's gci
# -cmin -X/ -ctime -X returns all files modified more recently than -X
# -cmin works in -X minutes
# -ctime works in -X days
# X must have a minus - prepended to it
# ctime/min means file status changes, like inode, which includes content
# mtime/min means the file content itself changed
find /etc -mmin -360 -ls 2>/dev/null | awk '{print $10, " ", $11}' | sort -k 1 -nr | head
find /etc -mtime -1 -ls 2>/dev/null | awk '{print $10, " ", $11}' | sort -k 1 -nr | head

# Try other paths too, change how many results are returned
```

```powershell
# Get the 10 most recently touched files under C:\Users
(gci -Path C:\Users -Recurse -Force -File | Sort-Object -Property LastWriteTime -Descending | Select -First 10).FullName

# Try other paths too, change how many results are returned
```

Network shares are also worth briefly examining, but we'll find these in the next section.

```powershell
net share
net session
net view /all /domain[:domainname]

Get-SMBShare
Get-SmbSession -IncludeHidden
```


## Network

Essentials for enumerating network processes.

```bash
# Get all files / processes with remote connections and show the remotes
sudo lsof -i -n -P

# The new netstat, sort based on connection state with sort -k 2
sudo ss -anp -A inet [| sort -k 2]

# Netstat, show all, numeric, tcp, udp, with process names
sudo netstat -antup
```

 [Netstat but with PowerShell and better](https://isc.sans.edu/diary/Netstat+but+Better+and+in+PowerShell/30532/)

> TCP connections, show connection time in seconds, sort by state:
> ```powershell
> Get-NetTCPConnection | select LocalAddress,LocalPort,RemoteAddress,RemotePort,State,@{Name="LifetimeSec";Expression={((Get-Date)-$_.CreationTime).seconds}},OwningProcess,@{Name="Process";Expression={ (Get-Process -Id $_.OwningProcess).ProcessName } }| Sort State | ft -auto
> ```
> 
> UDP connections, show connection time in seconds, sort by port:
> ```powershell
> Get-NetUDPEndpoint | select LocalAddress,LocalPort,@{Name="LifetimeSec";Expression={((Get-Date)-$_.CreationTime).seconds}},OwningProcess,@{Name="Process";Expression={ (Get-Process -Id $_.OwningProcess).ProcessName } }| Sort LocalPort | ft -auto
> ```


### Network Monitoring

For bare-bones network monitoring, use tcpdump until ZEEK / Suricata / snort can be up and running *somewhere* in the environment. This just logs the packet headers and doesn't save the payload which would burn disk space incredibly fast on busy systems. This is enough to feed to ZEEK and RITA for C2 / implant beacon detection.

This is the command to copy / paste into any box with `tcpdump` available (works with pfSense and Ubuntu / Fedora).

```bash
# Generic full capture to external storage:
sudo mkdir /mnt/external/pcaps
sudo chown nobody /mnt/external/pcaps
sudo chmod 750 /mnt/external/pcaps
# tcsh does not understand command substitution, just use pfSense.%Y%m%d%H%M%S...
sudo /usr/sbin/tcpdump -i ethX -Z nobody -G 3600 -w /mnt/external/pcaps/pfSense.%Y%m%d%H%M%S.pcap

# pfSense running tcpdump unprivileged:
sudo /usr/sbin/tcpdump -i ethX -Z nobody -G 3600 -w /tmp/pfSense.%Y%m%d%H%M%S.pcap '((tcp[13] & 0x17 != 0x10) or not tcp)'
# pfSense running tcpdump as root:
sudo /usr/sbin/tcpdump -i ethX -G 3600 -w "$(sudo mktemp -d)/pfSense.%Y%m%d%H%M%S.pcap '((tcp[13] & 0x17 != 0x10) or not tcp)'

# Ubuntu:
sudo /usr/sbin/tcpdump -i ethX -Z nobody -G 3600 -w "$(sudo mktemp -d)"/"$(hostname -s)".%Y%m%d%H%M%S.pcap '((tcp[13] & 0x17 != 0x10) or not tcp)'
```

The pcap files could be collected by an rsync cron task on your IR VM for offline review.


## Processes

Identify processes:

```bash
# Get all sessions, includes serial TTY, SSH PTS sessions, and TMUX panes
w

# Identify the processes of a certain user (in tree format with ps f)
ps f -u user2 -o pid,ppid,tty,time,cmd

# Get all processes of a certain user at once (for scripting / automation with xargs)
pgrep -u user2

# Get all files / network connections made by a user's processes
lsof -i -n -p $(pgrep -u user2 | tr '\n' ',')

# Dump shared object dependancies of process binaries
sudo ldd $(pgrep -u user2 | sed 's/^/\/proc\//g' | sed 's/$/\/exe/g' | tr '\n' ' ')

# Run `file` on each process binary
sudo file $(pgrep -u user2 | sed 's/^/\/proc\//g' | sed 's/$/\/exe/g' | tr '\n' ' ')

# Extract the binary from memory if it doesn't point to a filesystem path
for i in $(pgrep -u user2 | sed 's/^/\/proc\//g' | sed 's/$/\/exe/g'); do sudo cp "$i" ./$(echo "$i" | awk -F '/' '{print $3 ".bin"}'); done
```

Kill unauthorized user sessions:

```bash
# End a session based on pts/X
sudo pkill -9 -t pts/1

# Force (with -9) kill a process based on PID
sudo kill -9 $PID

# Force kill *all* processes of user2
pgrep -u user2 | xargs sudo kill -9
```


## Tasks / Jobs

*This includes Windows Scheduled tasks, cron, systemd-timers, and more!*

TO DO



## System Activity Monitoring

At this point, if you already haven't, drop the Sysinternals Suite on the endpoint. I have a PowerShell cmdlet to do this interactively, by selecting some or all packages, then installing the latest Sysmon with the latest (as of the time of writing) SwiftOnSecurity config.

- [Manage-Sysinternals](https://github.com/straysheep-dev/windows-configs/blob/main/Manage-Sysinternals.ps1)

Kunai is like Sysmon (the .exe) for Linux in that it's a standalone binary you can drop on a system and run (it may outpace sysmonforlinux in terms of features). Typically sysmonforlinux (the deb / rpm package) requires installation via a package feed with all of the required dependancies. Kunai does the same thing as sysmonforlinux, by hooking into eBPF. This means it can catch things other monitoring programs may miss, and is highly configurable to run on demand in an IR scenario.

- [Kunai GitHub](https://github.com/kunai-project/kunai)
- [Getting Started with Kunai](https://straysheep.dev/blog/2024/07/12/atomic-red-team-x-unix-artifacts-collector/#kunai)

pspy is also fantastic for *nix based system IO monitoring. You will catch a lot of activity with this. Just download the latest release binary and run it interactively.

- [pspy](https://github.com/DominicBreuker/pspy)


## Active Directory

*Apparrently OU's cannot be timestomp'd like files. Get OU's modified within the last two days with this:*

Check for GPO's created or modified in a certain time period:
```powershell
Get-GPO -All | where {$_.CreationTime -gt (Get-Date).AddDays(-2)}
Get-GPO -All | where {$_.ModificationTime -gt (Get-Date).AddDays(-2)}
```

Get all users with the Domain Admins SID in their SID History:
```powershell
Get-ADUser -Filter * -Properties sidhistory | where sidhistory -contains "S-1-5-<domain>-512" | Get-ADUser -Properties * | Select samaccountname
```

Get all users in the Domain Admins group:
```powershell
Get-ADGroupMember -Identity "Domain Admins" | Select samaccountname
```


## Yara

TO DO
