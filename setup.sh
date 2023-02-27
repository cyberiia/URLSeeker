#!/bin/bash

PATHFILE=/etc/bash.bashrc

if [ -f $PATHFILE ]; then
        chmod a+x dirhunter && echo "export PATH=$PATH:$PWD" >> $PATHFILE
        echo -e "\x1B[32m[+]\x1B[0m Successful installation."        
        sleep 2 && clear
else
        echo -e "\x1B[31m[-]\x1B[0mConfiguration file $PATHFILE not found.\x1B[0m\n\x1B[31m[-]\x1B[0m Exiting..."
fi


