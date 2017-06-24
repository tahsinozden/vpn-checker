# vpn-checker
A small Bash script which checks VPN connection and according to the status of connection, it kills torrent client or starts them.

# how-to-use
You can use the following commands. (assuming that `vpn_checker.sh` script is in Downloads folder) <br />
```
 mkdir ~/vpn_checker_folder 
 cp ~/Downloads/vpn_checker.sh ~/vpn_checker_folder
 chmod 555 ~/vpn_checker_folder/vpn_checker.sh 
```

Then the following lines should be added to your `.bashrc` file in home directory. (`~/.bashrc`) <br />

```
# run vpn checker if not running 
if [[ `ps -ef | grep "vpn_checker_folder/vpn_checker.sh" | grep -v grep | wc -l` == 0 ]]; then
        echo "VPN checker started!"
        nohup ~/vpn_checker_folder/vpn_checker.sh &
fi
```

In order to stop the script, you can run the following command. <br />
``` killall vpn_checker.sh ```
