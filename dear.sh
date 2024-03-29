#!/usr/bin/env bash
# Dear by Solomon Jennings
#
# Compresses a directory into a tar file and removes duplicate files

# clean up temp files
function clean_up() {
    rm -rf /tmp/$$
}

# Display correct usage
function usage() {
    echo "Usage:"
    echo "./dear.sh [compression] outfile indir"
    echo "Compression options:"
    echo "compress:  -c "
    echo "bzip:      -b "
    echo "gzip:      -g "
    exit 1
}

# Show an error message if an unsupported number of commands is given
if [ "$#" != 3 ] && [ "$#" != 2 ]; then
    usage
fi

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# This mess is to set up the variables we need from the input
# while also check for errors
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
if [ "$#" == 2 ]; then
    # if no switch is given use default extension
    OUTFILE=$(basename "$1")        # output file name
    if [ $? -ne 0 ]; then usage; fi # Check to make sure success

    OUTDIR=$(dirname "$1")/         # output file directory
    INDIR=${2%/}                     # input directory

    BASEDIR=$(basename $2)          # get base directory
    if [ $? -ne 0 ]; then usage; fi # Check to make sure success

    COMPRESS_SWITCH=""              # compression option
    EXTENSION=".tar"                # extension of the compressed file
    COMPRESS_TYPE="tar"             # Compression Type
else
    # switch is given, determine the correct extension and compression method
    OUTFILE=$(basename "$2")
    if [ $? -ne 0 ]; then usage; fi # Check to make sure success

    OUTDIR=$(dirname "$2")/
    INDIR=${3%/}                    # input directory

    BASEDIR=$(basename $3)
    if [ $? -ne 0 ]; then usage; fi # Check to make sure success

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
            COMPRESS_SWITCH=""
            EXTENSION=".tar.Z"
            COMPRESS_TYPE="compress"
        elif [ $1 == "" ]; then
            COMPRESS_SWITCH=""
            EXTENSION=".tar"
            COMPRESS_TYPE="none"
        fi
    fi
fi

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Check for errors based on that input
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
if [ ${#OUTDIR} -eq 0 ]; then
    OUTDIR=.
    echo "outdir set ."
fi

if [ ! -d ${OUTDIR} ]; then
    echo "cannot create outputfile ${OUTDIR}${OUTFILE}"
    exit 1
fi

# Test to make sure tha the input directory exists
if [ ! -d ${INDIR} ]; then
    echo "Directory ${INDIR} does not exist"
    exit 1
fi

# Make sure output file doesn't already exist
if [ -f ${OUTDIR}${OUTFILE}${EXTENSION} ]; then
    echo "File already exists ${OUTDIR}${OUTFILE}${EXTENSION}"
    exit 1
fi

# After file check set extension for compress to just tar
if [ ${COMPRESS_TYPE} == "compress" ]; then
    EXTENSION=".tar"
fi

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Set up temp directory, Is 2 directories deep so there are no collisions when moving compressed file
# into the directory below it
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

echo "De-duplicating ${INDIR}"

TMPDIR=/tmp/$$/$$
CURRDIR=`pwd`

if [ -d /tmp/$$ ]; then
    echo "Could not create temporary directory"
    exit 1
fi

mkdir -p ${TMPDIR}


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Real work starts here.
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Copy folder into tmp directory for removing duplicates and archiving
cp -af ${INDIR} ${TMPDIR}

if [ $? -ne 0 ]; then
    echo "Couldn't copy files to temporary directory"
    clean_up
    exit 1
fi

# Copy duplicate find script, this is so that directory paths can remain relative
cp ./dupRemove.pl ${TMPDIR}

# Move into the temp directory, run deduplication script and compress
cd ${TMPDIR}
./dupRemove.pl ./${BASEDIR}

# Check to make deduplication succeeded
if [ $? -ne 0 ]; then
    echo "Deduplication failed"
    clean_up
    exit 1
fi

rm ./dupRemove.pl

echo "Archiving ${INDIR}"

# Place compressed file one directory up so that it isn't included in the archive
tar ${COMPRESS_SWITCH} -cf ../${OUTFILE}${EXTENSION} .

# Make sure compression succeeded
if [ $? -ne 0 ]; then
    echo "Creating tar failed"
    clean_up
    exit 1
fi

# Handle special case of compress so that compression can occur even it won't make the file any smaller
if [ ${COMPRESS_TYPE} == "compress" ]; then
    compress -f ../${OUTFILE}${EXTENSION}
    EXTENSION=".tar.Z"

    # Make sure compression succeeded
    if [ $? -ne 0 ]; then
        echo "Compressing with compress failed"
        clean_up
        exit 1
    fi
fi

cd ${CURRDIR}

# Move the compressed file into the current directory and clean up
mv ${TMPDIR}/../${OUTFILE}${EXTENSION} ${OUTDIR}

# Clean up
clean_up

echo "Successfully created de-duplicated archive ${OUTDIR}${OUTFILE}${EXTENSION}"
echo "Compressed with: ${COMPRESS_TYPE}"

exit 0;