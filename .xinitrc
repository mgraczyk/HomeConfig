[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources
[[ -f ~/.profile ]] && source ~/.profile

xset fp+ ~/.fonts/

exec i3
