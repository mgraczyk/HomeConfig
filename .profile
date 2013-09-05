# @(#).profile	1.3 (Qualcomm) 18 May 1994
#
# Copyright (C) 1993 Qualcomm Incorporated
#
# Comment:  calls profile.global to do the real work
#
# Usage:  sourced by sh or ksh on startup
#
# Known Bugs: 
#
# Author: Lee Damon
#
#############################################################################
#############################################################################
##     DO NOT MAKE ADDITIONS TO THIS FILE. IF YOU WISH TO CHANGE YOUR      ##
##     ENVIRONMENT, CREATE AND EDIT A .profile.local FILE IN YOUR HOME     ##
##     DIRECTORY. CALL HOTLINE AT x1099 IF YOU NEED HELP WITH THIS.        ##
#############################################################################
#############################################################################
#

#
# trap things
#
trap ""  2 3

#
# call profile.global, this is the file that actually does all the work
#
PROFILE=${PROFILE_FILE:-/usr/local/etc/profile.global}
if [ -f $PROFILE ]
then
        . $PROFILE
else
        echo "$0: can't find configuration file $PROFILE; exiting." >&2
        exit 2
fi

trap  2 3
