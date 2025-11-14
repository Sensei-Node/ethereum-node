#!/bin/bash

if [ ! -f "/root/.ethereum/clef/rules.js" ] || [ ! -f "/root/.ethereum/clef/masterseed.json" ] || [ ! -f "/root/.ethereum/passwd.txt" ]; then
    echo "rules.js, masterseed.json or passwd.txt files do not exist"
    echo "might need to initialize clef"
    /usr/bin/tail -f /dev/null
else
    DEFAULT_NETWORK_ID=1
    
    if [ "$E_NETWORK_ID" = "" ]; then
        E_NETWORK_ID=$DEFAULT_NETWORK_ID
    fi
    
    cat /root/.ethereum/passwd.txt | clef --keystore /root/.ethereum/keystore --configdir /root/.ethereum/clef --chainid $E_NETWORK_ID --suppress-bootwarn --rules /root/.ethereum/clef/rules.js --signersecret /root/.ethereum/clef/masterseed.json --nousb
fi
