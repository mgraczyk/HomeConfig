[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources
[[ -f ~/.profile ]] && source ~/.profile

exec i3
