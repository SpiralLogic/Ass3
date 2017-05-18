#!/usr/bin/env bash
# Dear by Solomon Jennings
#
# Compresses a directory into a tar file and removes duplicate files

# clean up temp files
function clean_up() {
    rm -rf /tmp/$$
}

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
    # if no switch is given use default extension
    OUTFILE=$(basename "$1")    # output file name
    OUTDIR=$(dirname "$1")/     # output file directory
    INDIR=$2                    # input directory
    BASEDIR=$(basename $2)      # get base directory
    COMPRESS_SWITCH=""          # compression option
    EXTENSION=".tar"            # extension of the compressed file
    COMPRESS_TYPE="tar"         # Compression Type
else
    # switch is given, determine the correct extension and compression method
    OUTFILE=$(basename "$2")
    OUTDIR=$(dirname "$2")/
    INDIR=$3
    BASEDIR=$(basename $3)

    if [ $1 != "-c" ] && [ $1 != "-b" ] && [ $1 != "-g" ]; then
        echo "Invalid compression option"
        echo "Options are -c or -b or -g"
        exit
    else
        if [ $1 == "-g" ]; then
            COMPRESS_SWITCH="-z"
            EXTENSION=".tar.gz"
            COMPRESS_TYPE="gzip"
        elif [ $1 == "-b" ]; then
            COMPRESS_SWITCH="-j"
            EXTENSION=".tar.bz2"
            COMPRESS_TYPE="bz2"
        elif [ $1 == "-c" ]; then
            COMPRESS_SWITCH="-Z"
            EXTENSION=".tar.Z"
            COMPRESS_TYPE="compress"
        elif [ $1 == "" ]; then
            COMPRESS_SWITCH=""
            EXTENSION=".tar"
            COMPRESS_TYPE="none"
        fi
    fi
fi

if [ ${#OUTDIR} -eq 0 ]; then
    OUTDIR=.
    echo "outdir set ."
fi

if [ ! -d ${OUTDIR} ]; then
    echo "cannot create outputfile ${OUTDIR}${OUTFILE}"
    exit
fi

# Test to make sure tha the input directory exists
if [ ! -d ${INDIR} ]; then
    echo "Directory ${INDIR} does not exist"
    exit
fi

# Make sure output file doesn't already exist
if [ -f ${OUTDIR}${OUTFILE}${EXTENSION} ]; then
    echo "File already exists ${OUTDIR}${OUTFILE}${EXTENSION}"
    exit
fi

# Set up temp directory, Is 2 directories deep so there are no collisions when moving compressed file
# into the directory below it
TMPDIR=/tmp/$$/$$
CURRDIR=`pwd`

mkdir -p ${TMPDIR}

# Copy folder into tmp directory for removing duplicates and archiving
cp -rf ${INDIR} ${TMPDIR}

if [ $? -ne 0 ]; then
    echo "Couldn't copy files to temporary directory"
    clean_up
    exit
fi
# Copy duplicate find script, this is so that directory paths can remain relative
cp ./dupRemove.pl ${TMPDIR}

# Move into the temp directory, run deduplication script and compress
cd ${TMPDIR}
./dupRemove.pl ./${BASEDIR}
rm ./dupRemove.pl

# Place compressed file one directory up so that it isn't included in the archive
tar ${COMPRESS_SWITCH} -cf ../${OUTFILE}${EXTENSION} .

# Make sure compression succeeded
if [ $? -ne 0 ]; then
    echo "Creating tar failed"
    clean_up
    exit
else
    cd ${CURRDIR}

    # Move the compressed file into the current directory and clean up
    mv ${TMPDIR}/../${OUTFILE}${EXTENSION} ${OUTDIR}
fi

# Clean up
clean_up

echo "Successfully created deduplicated archive ${OUTDIR}${OUTFILE}${EXTENSION}"
echo "Compressed with: ${COMPRESS_TYPE}"

