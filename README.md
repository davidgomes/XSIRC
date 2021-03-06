XSIRC
=====

About
-----
XSIRC is a very simple to use and lightweight GTK3 IRC client.

Installation
----------
XSIRC depends on GTK+ 3, libnotify 0.7 and libgee. It also requires Python
and Vala 0.16 for the compilation. Installation is simple:

```
~/xsirc $ ./waf configure --prefix=/usr
~/xsirc $ ./waf build  
~/xsirc $ ./waf install
```

XSIRC can be uninstalled by calling `./waf uninstall`.

Credits
-------
XSIRC was originally written by [Eduardo Niehues](https://github.com/NieXS). This version is a fork by
David Gomes with the objective of improving it wherever possible.

Contributing
------------
XSIRC is open to any kind of contributions, be it in the form of ideas or code, 
please contribute if you can.
