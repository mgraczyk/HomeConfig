xprop -root -f _NET_DESKTOP_LAYOUT 32cccc -set _NET_DESKTOP_LAYOUT 0,2,2,0
xprop -root -f _NET_NUMBER_OF_DESKTOPS 32c -set _NET_NUMBER_OF_DESKTOPS 4

# Fix panel to stay behind fullscreen windows
ID=
for i in 1 .. 10; do
        ID=$(wmctrl -l | grep xfce4-panel$ | awk '{ print $1 }')
        if [ -n "$ID" ]; then
                break;
        fi
        sleep 1
done

if [ -z "$ID" ]; then
        echo "Error finding panel ID"
else
        for n in $ID; do
                wmctrl -i -r $n -b add,below
        done
fi
