#!/bin/bash

cygwin=false;
case "`uname`" in
  CYGWIN*) cygwin=true;
esac

# The script directory:
DIR="$( cd -P "$(dirname $( readlink -f "$0" ))" && pwd )"
CALABASH=$DIR/calabash/calabash.sh

if [ ! -e $FILE ]; then
    echo "please specify HTML file"
    exit 1
fi

BASENAME=$(basename $FILE .html)
OUT_DIR=$(dirname $FILE)

# absolute paths
if $cygwin; then
    FILE_URI=file:/$(Cygpath -ma "$FILE")
    DIR_URI=file:/$(cygpath -ma "$DIR")
    OUT_DIR_URI=file:/$(cygpath -ma "$OUT_DIR")
else
    FILE_URI=file:$(readlink -f $FILE)
    DIR_URI=file:$DIR
    OUT_DIR_URI=file:$OUT_DIR
fi

OUT_FO=$OUT_DIR/$BASENAME.fo
OUT_PDF=$OUT_DIR_URI/$BASENAME.pdf

echo "write outpot to $OUT_DIR_URI"


# invoke calabash

$CALABASH \
    -D -i source=$FILE_URI \
    -o result=$OUT_FO \
    $DIR_URI/xpl/revealjs-fo.xpl \
    href=$OUT_PDF \
