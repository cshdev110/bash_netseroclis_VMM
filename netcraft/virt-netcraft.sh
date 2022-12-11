#!/usr/bin/bash

declare name_net=$1
declare name_virbr="virbr"
declare ip=$2
declare netmask=$3
declare start_ip=$4
declare end_ip=$5
declare -r path_net="/etc/libvirt/qemu/networks/"

function check_virbr_name () {
    for i in {0..1000}; do
        found_virbr=0
        name_virbr="virbr$i"
        lookingfor=$(nmcli device status)
        if [[ $lookingfor == *$name_virbr* ]]; then
            found_virbr=1
            continue
        fi
        for lookingfor in $(ls $path_net); do
            if [ -f $path_net$lookingfor ]; then
                lookingfor=$(cat $path_net$lookingfor)
                # If the virbr (virtual bridge) is being used
                if [[ $lookingfor == *$name_net* ]]; then
                    echo "Name $name_net is already used."
                    exit 1
                elif [[ $lookingfor == *$name_virbr* ]]; then
                    found_virbr=1
                    break
                fi
            fi
        done
        if [ $found_virbr == 0 ]; then
            eval "$1='$name_virbr'"
            #echo "found"
            #echo "$name_virbr"
            break
        fi
    done
}
# function check_virbr_name and sending the variable name_virbr
# to modify it using its reference with the line eval eval "$1='<somevalues>'"
# eval execute arguments as a shell command. "eval --help"
check_virbr_name name_virbr

net_isolated="<network>
    <name>$name_net</name>
    <bridge name='$name_virbr' stp='on' delay='0'/>
    <ip address='$ip' netmask='$netmask'>
        <dhcp>
            <range start='$start_ip' end='$end_ip'/>
        </dhcp>
    </ip>
</network>"
echo "$net_isolated" > $name_net.xml
virsh net-define $name_net.xml
sleep 2
virsh net-start $name_net
rm $name_net.xml
echo $?