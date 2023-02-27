#!/bin/bash

PATHFILE=/etc/bash.bashrc

if [ -f $PATHFILE ]; then
        chmod a+x dirhunter && echo "export PATH=$PATH:$PWD" >> $PATHFILE
        echo -e "\x1B[1;36mSuccessful installation.\x1B[0m"
        sleep 2 && clear
else
        echo -e "\x1B[1;31mConfiguration file $DIRPATH not found.\x1B[0m"
fi


