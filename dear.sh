#!/usr/bin/env bash
# Dear by Solomon Jennings
#
# Compresses a directory into a tar file and removes duplicate files

# Show an error message if an unsupported number of commands is given
if [ "$#" != 3 ] && [ "$#" != 2 ]; then
    echo "Usage:"
    echo "./dear.sh -[compression] outfile indir"
    echo "Compression options:"
    echo "compress:  -c "
    echo "bzip:      -b "
    echo "gzip:      -g "
    exit
fi

if [ "$#" == 2 ]; then
# if no switch is given
    OUTFILE=$1
    INDIR=$2
    BASEDIR="${2##*/}" # get base directory
    COMPRESS_SWITCH=""
    EXTENSION=".tar"
else
# switch is given, determine the correct extension and compression method
    OUTFILE=$2
    INDIR=$3
    BASEDIR="${3##*/}"

    if [ $1 != "-c" ] && [ $1 != "-b" ] && [ $1 != "-g" ]; then
        echo "Invalid compression option"
        echo "Options are -c or -b or -g"
        exit
    else
        if [ $1 == "-g" ]; then
            COMPRESS_SWITCH="-z"
            EXTENSION=".tar.gz"
        elif [ $1 == "-b" ]; then
            COMPRESS_SWITCH="-j"
            EXTENSION=".tar.bz2"
        elif [ $1 == "-c" ]; then
            COMPRESS_SWITCH="-Z"
            EXTENSION=".tar.Z"
        elif [ $1 == "" ]; then
            COMPRESS_SWITCH=""
            EXTENSION=".tar"
        fi
    fi
fi

# Test to make sure tha the input directory exists
if [ ! -d $INDIR ]; then
  echo "Directory ${INDIR} does not exist"
  exit
fi

# Set up temp directory, Is 2 directories deep so there are no collisions when moving compressed file
# into the directory below it
TMPDIR=/tmp/$$/$$
CURRDIR=`pwd`

mkdir -p ${TMPDIR}

# Copy folder into tmp directory for removing duplicates and archiving
cp -rf ${INDIR} ${TMPDIR}

# Copy duplicate find script, this is so that directory paths can remain relative
cp ./dupRemove.pl ${TMPDIR}

# Move into the temp directory, run deduplication script and compress
cd ${TMPDIR}
./dupRemove.pl ./${BASEDIR}
rm ./dupRemove.pl

# Place compressed file one directory up so that it isn't included in the archive
tar ${COMPRESS_SWITCH} -cf ../${OUTFILE}${EXTENSION} .
cd ${CURRDIR}

# Move the compressed file into the current directory and clean up
mv ${TMPDIR}/../${OUTFILE}${EXTENSION} .
rm -rf /tmp/$$