#!/bin/sh
# Only works with Terminals supporting sixel graphics

dim="${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}"
if [ "$dim" = x ]; then
	dim=$(stty size </dev/tty | awk '{print $2 "x" $1}')
elif [ -z "$KITTY_WINDOW_ID" ] && [ "$(expr "$FZF_PREVIEW_TOP" + "$FZF_PREVIEW_LINES")" -eq "$(stty size </dev/tty | awk '{print $1}')" ]; then
	# Avoid scrolling issue when the Sixel image touches the bottom of the screen
	# * https://github.com/junegunn/fzf/issues/2544
	dim="${FZF_PREVIEW_COLUMNS}x$(expr "$FZF_PREVIEW_LINES" - 1)"
fi

case "$(file -L --mime-type "$1")" in
*text*)
	bat --color always --plain --theme gruvbox "$1"
	;;
*image* | *pdf)
	if command -v chafa >/dev/null; then
		chafa -s "$dim" -f sixels --dither ordered --dither-intensity 1.0 --animate off --polite on "$1"
	else
		echo "Install chafa and use a terminal with sixel graphics"
	fi
	;;
*directory* | *symbolic*)
	ls -1 --color=always "$1"
	;;
*)
	echo "unknown file format"
	;;
esac
