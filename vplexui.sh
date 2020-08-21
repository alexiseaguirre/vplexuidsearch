#!/bin/bash
# VPLEXUI Version 1.1
# Author: ae.aguirre@hotmail.com

#Variables de argumentos
user=$1
pass=$2
vplexui=$3

function fase1 () {
#Lista de equipos
dispo=$(cat ~/equipos.txt |awk {'print $1'})
mkdir -p /tmp/VPlexLOGs

#Bucle para iterar sobre cada equipo
    for line in $dispo ;do
        echo Entering $line...
     {
        /usr/bin/expect << EOF
        set timeout 50
        spawn ssh $user@$line
        expect "Password:"
        send "$pass\r"
        expect {
             "$user" {
              send "vplexcli\r"
              expect "Name:"
              send "$user\r"
              expect "Password:"
              send "$pass\r"
              expect "VPlexcli:"
              send "ll clusters/cluster-*/virtual-volumes\r"
              expect "VPlexcli:"
              send "$exit\r"
              expect "$user"
              send "$exit\r"
                      }
              "Permission denied, please try again." {
               send "exit\r"
                    }
               }
EOF
     } &> /tmp/VPlexLOGs/vplex_$line.log
    done;
                   }


   function fase2() {
           archi=$(ls -lrt /tmp/VPlexLOGs|awk '{print $9}')
           ruta="/tmp/VPlexLOGs/"

            for line in $archi
                    do
                     echo -e "\n" && cat $ruta$line |egrep -i service@|egrep -v spawn && cat $ruta$line |grep -i $vplexui
                      done
                     }


if [ -z "$user" ] || [ -z "$pass" ] || [ -z "$vplexui" ]; then
     echo ""
     echo "Please enter <USER> <PASSWORD> <VirtualVolumeUID>"
     echo ""
     exit
else
   fase1
   echo ""
   fase2
   exit
 fi
