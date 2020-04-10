#!/bin/bash
# Builds dist files from the current working branch.
#
# You can specify the version as first argument:
#   ./build.sh 1234
#
# Exception: if the argument is "svg", this script 
# will only generate the svg file and omit the rest.


##########
# Configuration

# The basename of the .csv and .conf file
PROJNAME='gldt'

# Which files to include into the archive
DISTFILES='gldt.csv gldt.conf ToDo ChangeLog README LICENSE images build.sh'

# Path to gnuclad and optional path to Inkscape
GC=/usr/local/bin/gnuclad
INK=/usr/bin/inkscape

#
##########
# Code starts here

VERS=$1

type -P $GC &>/dev/null || { echo "gnuclad not found: aborting" >&2; exit 1;}
if [ "$VERS" == "svg" ]; then
	$GC $PROJNAME.csv svg $PROJNAME.conf
	exit 0;
fi
CHECK=`$GC $PROJNAME.csv $PROJNAME$VERS.svg $PROJNAME.conf`
echo -e "$CHECK"
if [[ `echo -e "$CHECK" | grep "^Error:"` ]]; then
	exit 1;
fi

if [ -z "$(type -P $INK)" ]; then
	echo "Inkscape not found: will not generate png"
else
	$INK $PROJNAME$VERS.svg -D --export-png=$PROJNAME$VERS.png
fi

echo "Packaging..."
type -P tar &>/dev/null || { echo "tar not found: aborting" >&2; exit 1;}
type -P bzip2 &>/dev/null || { echo "bzip2 not found: aborting" >&2; exit 1;}

tar -c $DISTFILES > $PROJNAME$VERS.tar
bzip2 $PROJNAME$VERS.tar

BDIR="DIST_$PROJNAME$VERS"
mkdir -p $BDIR
mv $PROJNAME$VERS.svg $BDIR
type -P $INK &>/dev/null && mv $PROJNAME$VERS.png $BDIR
mv $PROJNAME$VERS.tar.bz2 $BDIR

echo "Distribution can be found in $BDIR"

