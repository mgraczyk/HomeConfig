# @(#).login	1.16 (Qualcomm) 16 Sep 1994
#
# Copyright (C) 1994 Qualcomm Incorporated
#
# Comment: Default .login file for GrapeVine users 
#
# Usage: invoked at login time 
#
# Known Bugs: 
#
# Author: Lorayne Witte, Lee Damon
#
#         Read in after the .cshrc file when you log in.
#         Not read in for subsequent shells.  For setting up
#         terminal and global environment characteristics.
#
#############################################################################
#############################################################################
##     DO NOT MAKE ADDITIONS TO THIS FILE. IF YOU WISH TO CHANGE YOUR      ##
##     ENVIRONMENT, CREATE AND EDIT A .login.local FILE IN YOUR HOME       ##
##     DIRECTORY. CALL HOTLINE AT x1099 IF YOU NEED HELP WITH THIS.        ##
#############################################################################
#############################################################################
#

#
# the following two calls make it so we can have a global environment, with
# global initializations of things like prompts, path, manpath and such,
# while allowing you to customize things you like. You don't have to
# worry about us changing your local things, because we just change
# the global files, and stay out of your home directory.
# 

#
# source the global .login file, if it exists
#
# this gives you the Qualcomm standard initializations, calls initializations
# based on which groups you are a member of, then calls your subscribed package
# initializations. To see what is happening, just look at the files. If you
# have questions, call Hotline at x-1099.
#
if ( -f /usr/local/etc/login.global ) then
	source /usr/local/etc/login.global
endif

#
# source the user's local .login file, if it exists
#
# This is where you can set your own initializations. You can chose to change
# what we've done for you above, or add to it. Most people will have a set
# of aliases they want, and .login.local is the place to put them.
#
if ( -f ~/.login.local ) then
	source ~/.login.local
endif

#
# If possible, start the windows system.  Give user a chance to bail out
#
# If you don't want it to start openwindows automatically, add
#	setenv NOOPENWIN true
# to your .login.local.
#
if ( `tty` != "/dev/console" || $?NOOPENWIN || $TERM != "sun" ) then
        exit    # leave user at regular C shell prompt
endif
if ($?OPENWINHOME ) then
	echo ""
	echo -n "Starting OpenWindows (type Control-C to interrupt)"
	sleep 3
	$OPENWINHOME/bin/openwin
	clear_colormap  # get rid of annoying colourmap bug
	clear           # get rid of annoying cursor rectangle
	echo -n "Automatically logging out (type Control-C to interrupt)"
	sleep 3
	logout          # logout after leaving windows system
endif
