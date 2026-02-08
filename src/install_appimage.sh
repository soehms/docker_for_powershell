#!/bin/bash

###############################################################################
# this scripts downloads am AppImage file provided at the url $1 and saves it
# under ~/bin under the given name $2. If $2 is not given the original name
# is used.
###############################################################################

mkdir -p ~/bin
cd ~/bin
if [ -n "$2" ]; then
    echo "Download of $2"; echo "from $1 starts:"
    curl --progress-bar -fSL $1 -o $2 2>/dev/tty;
else
    echo "Download of"; "$1 starts:"
    curl --progress-bar -fSL $1 -O 2>/dev/tty;
fi
chmod a+x *.AppImage
