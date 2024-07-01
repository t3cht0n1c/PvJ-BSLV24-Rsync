Wordpress
===========

We don't know for sure if we will have a Wordpress box in the game, but just in case, we may as well try and be prepared.


wpscan
---------

* [https://wpscan.org/](https://wpscan.org/)
* [https://github.com/wpscanteam/wpscan](https://github.com/wpscanteam/wpscan)


Scan for all plugins and output to `wpscan.log`

```
wpscan --url http://192.168.1.10/wp -e ap --log wpscan.log
```


--------