BIND 9 Setup
==========


I've put together a `configure_chroot_jail.sh` script that works, but right now, it just uses the IP address information from the playground range. I still need to make it adaptible to a new environment.

It is still a start, though!

---------------------

Adhoc Notes
=======================

Process Isolation
--------------

[https://www.slideshare.net/MenandMice/a-secure-bind-9-best-practices](https://www.slideshare.net/MenandMice/a-secure-bind-9-best-practices)

Slide 17 out of 60

>
> chrooting BIND 9 is easy (compared with other daemon processes of BIND 4/8)
>
> `named -t /var/named` (use the path to the chroot directory)
>
> * all files BIND 9 needs during operation must be located inside the chroot directory
> * all file references in the BIND 9 configuration file are relative to the chroot
>   - this is a source of confusions for some admins


DNSSEC
-------------------

[https://www.slideshare.net/MenandMice/a-secure-bind-9-best-practices](https://www.slideshare.net/MenandMice/a-secure-bind-9-best-practices)

Slide 23 out of 60


> BIND 9 comes with a trust-anchor for the Internet Root-Zone build in
>
> * DNSSEC validation can be enabled with just one line of configuration:

```
options {
    dnssec-validation auto;
};
```

minimal responses
----------------

[https://www.slideshare.net/MenandMice/a-secure-bind-9-best-practices](https://www.slideshare.net/MenandMice/a-secure-bind-9-best-practices)

Slide 31 out of 60

> configure "minimal responses" in BIND 9

```
options {
    minimal-responses yes;
};
```

> BIND 9 will only return the data required for the DNS protocol to work
> this reduces the "ammo" available to attackers

minimal any
----------------

[https://www.slideshare.net/MenandMice/a-secure-bind-9-best-practices](https://www.slideshare.net/MenandMice/a-secure-bind-9-best-practices)

Slide 34 out of 60

__THIS IS ONLY AVAILABLE ON 9.11. IF WE HAVE 9.11, DEFINITELY ADD THIS__

> starting with BIND 9.11, BIND 9 can be configured to only return the first entry of a matching ANY query
> 
> this mitigates the problem without causing (too much) breakage of older software (qmail etc)

```
options {
    minimal-any yes;
};
```

access control
------------

[https://www.slideshare.net/MenandMice/a-secure-bind-9-best-practices](https://www.slideshare.net/MenandMice/a-secure-bind-9-best-practices)

Slide 47 out of 60

> for a DNS resolver without zones, restrict the networks can use the resolver

```
options {
    allow-query { networkblock-acl; };
};
```

> for a BIND 9 server running as a resolver with authoritative zones, restrict the networks that can use recursive queries to the resolver

```
options {
    allow-recursion { networkblock-acl; };
};
```

> on an all authoritative server, disable recursion

```
options {
    recursion no;
};
```

> on an authoritative server, secure zone transfer and updates with TSIG (use the `tsig-keygen` utility)


--------------------------

This looks like a good resource: [http://www.cymru.com/Documents/secure-bind-template.html](http://www.cymru.com/Documents/secure-bind-template.html)


---------------------------

DNS File Structure
==============

* `named.conf`

    This is the configuration file for the entire DNS service. It is where the hardening and protections should take place.

