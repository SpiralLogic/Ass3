#!/usr/bin/env bash
# Undear by Solomon Jennings
#
# Uncompresses a deared archive into it's original directories and restores duplicates based on the switch provided

# Replaces existing metadata file if needed
function restore_metadata() {
    if [ -d $TMPDIR ]; then
        cp ${TMPDIR}/${METADATA} ./
        rm -rf $TMPDIR
    fi
}

function usage() {
    echo "Usage:"
    echo "./undear.sh -[duplication option] file"
    echo "duplicate options:"
    echo "delete:    -d"
    echo "symlink:   -l"
    echo "restore:   -c"
}
# Exist if not enough paramters are given
if [ "$#" != 2 ]; then
    usage
    exit 1
fi

# Check correct switch is given
if [ $1 != "-d" ] && [ $1 != "-l" ] && [ $1 != "-c" ]; then
    echo "Invalid restore option"
    echo "Options are -d or -l or -c"
    exit 1
fi

# Initial variables
FILE=$2
FILENAME=$(basename "$FILE")    # Filename of archive without directory
TYPE="${2##*.}"                 # Get extension
METADATA="metadata.txt"         # metadata filename
TMPDIR=/tmp/$$                  # temporary directory

if [ ! -f ${FILE} ]; then
    echo "File to undear is missing or not a file"
    exit 1
fi

# Determine compression type based on extension
if [ ${TYPE} == "tar" ]; then
    DECOMPRESS_SWITCH=""
elif [ ${TYPE} == "gz" ]; then
    DECOMPRESS_SWITCH="-z"
elif [ ${TYPE} == "Z" ]; then
    DECOMPRESS_SWITCH="-j"
elif [ ${TYPE} == "bz2" ]; then
    DECOMPRESS_SWITCH="-j"
else
    echo "Unknown compression extension"
    exit 1
fi

# Temporary directory to copy metadata file if it already exists
if [ -f ${METADATA} ]; then
    if [ -d ${TMPDIR} ]; then
        echo "Could not create temporary directory"
        exit 1;
    fi
    mkdir -p ${TMPDIR}
    mv ${METADATA} $TMPDIR/
fi


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Decompress the file
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
echo "Decompressing ${FILENAME}"

tar ${DECOMPRESS_SWITCH} -xvf ${FILE}

if [ $? -ne 0 ]; then
    echo "Decompress failed"
    restore_metadata
fi


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Restore duplicates based on the switch provided
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

echo "Processing duplicates"

# if the metadata existed in the archive
if [ -f ${METADATA} ]; then
    # Restore duplicates based on option provided
    if [ $1 == "-c" ]; then
        echo "Coping duplicates"
        while read line; do
            EXEC="cp ${line}"
            eval ${EXEC} # use eval so that spaces work out
        done < ${METADATA}
    elif [ $1 == "-l" ]; then
        echo "Creating symlinks for duplicates"
        while read line; do
            # symlink with relative paths
            EXEC="ln -rs ${line}"
            eval ${EXEC} # use eval so that spaces work out
        done < ${METADATA}
    fi

    # Remove metadata file
    rm ${METADATA}
else
    echo "No metadata for duplicates in archive"
fi

restore_metadata
