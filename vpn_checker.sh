#!/bin/bash

# this torrent clients' values are the commands for them to run
declare -r QBITTORRENT="qbittorrent"
declare -r DELUGE="deluge-gtk"
declare -r TRUE=1
declare -r FALSE=0
declare -r SUCCESS=0
declare -r FAIL=255

declare -ar SUPPORTED_TORRENT_CLIENTS=($QBITTORRENT $DELUGE) 
declare -a currentlyRunningTorrentClients=()
declare -r VPN_INTERFACE_NAME="ppp0"
# in seconds
declare -r INTERVAL=1

function kill_if_alive {
    processName=$1
    if [[ `ps -ef | grep $processName | grep -v grep | wc -l` > 0 ]]; then
        echo "killing $processName"
        killall $processName
    fi
}

function is_connectedto_internet {
    # check the connection with google website :)
    curl -D- > /dev/null -s http://www.google.com
    if [[ $? == 0 ]]; then
        echo $TRUE
    else
        echo $FALSE
    fi
}

function is_connectedto_vpn {
    echo `ip link show | grep $VPN_INTERFACE_NAME | grep -v grep | wc -l` 
}

areVPNClientKilled=$FALSE

while true; 
do
    for client in ${SUPPORTED_TORRENT_CLIENTS[@]};
    do
        # TODO: remove stopped torrent client from the list
        # check if it is running or not
        if [[ `ps -ef | grep $client | grep -v grep | wc -l` > 0 ]]; then
            # add value if not exist in the array
            if [[ `echo "${currentlyRunningTorrentClients[@]}" | grep -w "$client" | wc -l` == 0 ]]; then
                currentlyRunningTorrentClients+=($client)
            fi        
        fi
    done
    
    if [[ `is_connectedto_internet` == $TRUE ]]; then
        if [[ `is_connectedto_vpn` == 0 ]]; then
            echo "VPN is not connected!."
            if [[ $areVPNClientKilled == $FALSE ]]; then
                echo "Killing torrent clients..."
                for client in ${currentlyRunningTorrentClients[@]};
                do
                    kill_if_alive "$client"
                done
                areVPNClientKilled=$TRUE
            fi
        
        else
            if [[ $areVPNClientKilled == $TRUE ]] && [[ ${#currentlyRunningTorrentClients[@]} != 0 ]]; then
                echo "VPN is connected!. Starting torrent clients..."
                for client in ${currentlyRunningTorrentClients[@]};
                do
                    eval "$client" &
                done
                areVPNClientKilled=$FALSE
            fi
        fi
    else
        echo "No internet connection!."
    fi
    
    sleep $INTERVAL
done
