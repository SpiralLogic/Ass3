#!/usr/bin/env bash

if [ "$#" != 2 ]; then
    echo "Usage:"
    echo "./dear.sh outfile indir"
    exit
else
    OUTFILE=$1
    INDIR=$2
fi

TMPDIR=/tmp/$$
CURRDIR=`pwd`


mkdir ${TMPDIR}
cp -rf ${INDIR} ${TMPDIR}

./dupRemove.pl ${TMPDIR}/${INDIR}

cp metadata.txt ${TMPDIR}/
cd ${TMPDIR}

tar -czf ../${OUTFILE} .
cd ${CURRDIR}

mv ${TMPDIR}/../${OUTFILE} .
rm -rf /tmp/$$