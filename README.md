ipsets-systemd
================

Scripts & systemd unit for multiple ipset management.


## Why did I make this?

Yep, there are already `/etc/ipset.conf` and `ipset.service` in the
Arch Linux, however, they are not in a good design.

Just take a look at `ipset.service` and you will find

```
ExecStart=/usr/bin/ipset -f /etc/ipset.conf restore
ExecReload=/usr/bin/ipset -f /etc/ipset.conf restore
ExecStop=/usr/bin/ipset destroy
```

So the `systemctl reload ipset` really works? 

Firstly, to add an ipset to the system, we would add a `create` command
into the `/etc/ipset.conf`, such as

```
create myipset hash:net family inet
```

There is no problem when the system boot, however, it will failed in
case of `systemctl reload ipset.service`. It will complain about 
"Oh, the myipset is already exists, you cannot create it again!!!".

You cannot even destroy the ipset first as it referenced by iptables.
And there is even not a command like "CREATE IF NOT EXISTS".

To solve this problem, you can stop `iptables.service` before restart
the `ipset.service` and start it again after that, however it is not OK
in all case. Or you can manage the `/etc/ipset.conf` and the real ipset
in the kernel separately, and this is really annoying.

So I made this repo, and you can just modify your set file, and reload
it with `systemctl reload ipsets@myipset` gracefully.

