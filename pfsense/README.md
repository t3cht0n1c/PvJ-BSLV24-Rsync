pfSense Hardening
=========

__The default credentials:__


```
admin:pfsense
```

--------------

0. UPDATE THE BOX.
1. Change default password.
2. Check the rules already set up.
3. Add logging to existing rules
4. Hunt for web shells and other methods of persistence in underlying BSD OS

----------------

> Set the WebGUI to https.
> 
> Set the WebGUI to a different port than 443 (i usually use 444 :D ).
> 
> Disable the anti-lockout rule (under system–>advanced) and allow access only from a source you control.
> 
> Or even better: dont allow access to the webGUI at all besides via a VPN (OpenVPN comes to mind).
> 
> Run as few packages/services as possible.

## Quick Commands:
Show filter information:
```
pfctl -s rules
or
pfctl -sr
```
Show filter information for which FILTER rules hit:
```
pfctl -v -s rules
```
