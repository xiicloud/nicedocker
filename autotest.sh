#!/bin/sh

dockernice run memcached latest mem1 eiwnsdfa
dockernice exec mem1 echo helloworld
dockernice service mem1 restart
dockernice ps
dockernice start mem1
dockernice stop mem1
dockernice stop mem1
dockernice rm mem1

dockernice run redis latest red1221 redsiwea3
dockernice exec red1221 /edaf
dockernice rename red1221 red250
dockernice login red250
dockernice ps
dockernice service red250 restart
dockernice start red250
dockernice rm -y red250
dockernice stop red250
dockernice stop red250
dockernice rm -y red250

