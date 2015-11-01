Thanks to the aweseome hue_bashlibrary ... https://github.com/markusproske/hue_bashlibrary

Make sure you've used hue_bashlibrary before.. (specifically you need to have linked it where you push the button on the base, etc...)

huemem.sh tries to remember the state the lights were in so that next time you turn them on it will return them to that state...

Only tested under cygwin but it should work on linux fine as well... doesn't work in GoW (because it didn't like my Strawberry version of Perl).

In order to be able to work it needs to always be running (and thus leaving your computer on)... so you can either leave a cygwin terminal window open all the time or install it as a service.

Right click cygwin and run as administrator so you can add a service (adjust the paths for wherever you have put it)...

cygrunsrv.exe -I huemem.sh -c ~ -p ~/huemem.sh
