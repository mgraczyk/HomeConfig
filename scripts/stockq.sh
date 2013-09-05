#!/bin/sh

if [ -z $1 ] ; then 
	echo "Usage: $(basename $0) <symbol>"
else
	curl -s "http://download.finance.yahoo.com/d/quotes.csv?s=$1&f=l1"
fi

