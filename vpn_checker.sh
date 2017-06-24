#!/bin/bash

declare -r QBITTORRENT="qbittorrent"
declare -r DELUGE="deluge-gtk"
declare -r TRUE="true"
declare -r FALSE="false"
declare -r SUCCESS=0
declare -r FAIL=255

declare -ar SUPPORTED_TORRENT_CLIENTS=("qbittorrent" "deluge-gtk") 
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


function is_connectedto_vpn {
    echo `ip link show | grep $VPN_INTERFACE_NAME | grep -v grep | wc -l` 
}

areVPNClientKilled=0

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
    
    if [[ `is_connectedto_vpn` == 0 ]]; then
        if [[ $areVPNClientKilled == 0 ]]; then
            for client in ${currentlyRunningTorrentClients[@]};
            do
                kill_if_alive "$client"
            done
            areVPNClientKilled=1
        fi

    
    else
        if [[ $areVPNClientKilled == 1 ]] && [[ ${#currentlyRunningTorrentClients[@]} != 0 ]]; then
            for client in ${currentlyRunningTorrentClients[@]};
            do
                eval "$client" &
            done
            areVPNClientKilled=0
        fi
    fi
    
    sleep $INTERVAL
done
