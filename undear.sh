#!/usr/bin/env bash
# Undear by Solomon Jennings
#
# Uncompresses a deared archive into it's original directories and restores duplicates based on the switch provided

if [ "$#" != 2 ]; then
    echo "Usage:"
    echo "./undear.sh -[duplication option] file"
    echo "duplicate options:"
    echo "delete:    -d"
    echo "symlink:   -l"
    echo "restore:   -c"
    exit
fi

if [ $1 != "-d" ] && [ $1 != "-l" ] && [ $1 != "-c" ]; then
    echo "Invalid restore option"
    echo "Options are -d or -l or -c"
    exit
fi

# Initial variables
FILE=$2
FILENAME=$(basename "$FILE")
TYPE="${2##*.}" # Get file extension
METADATA="metadata.txt"
TMPDIR=/tmp/$$

if [ ! -f ${FILE} ]; then
    echo "File to undear is missing or not a file"
    exit
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
    exit
fi

# Temporary directory to copy metadata file if it already exists
if [ -f ${METADATA} ]; then
    mkdir -p ${TMPDIR}
    mv ${METADATA} $TMPDIR/
fi

function restore_metadata() {
    # Replaces existing metadata file if needed
    if [ -d $TMPDIR ]; then
        cp ${TMPDIR}/${METADATA} ./
        rm -rf $TMPDIR
    fi
}

# Decompress the file
echo "Decompressing ${FILENAME}"
tar ${DECOMPRESS_SWITCH} -xvf ${FILE}

if [ $? -ne 0 ]; then
    echo "Decompress failed"
    restore_metadata
fi


if [ -f ${METADATA} ]; then
    # Restore duplicates based on option provided
    if [ $1 == "-c" ]; then
        echo "Coping duplicates"
        while read line; do
            cp ${line}
        done < ${METADATA}
    elif [ $1 == "-l" ]; then
        echo "Creating symlinks for duplicates"
        while read line; do
            ln -s ${line}
        done < ${METADATA}
    fi

    # Remove metadata file
    rm ${METADATA}
else
    echo "No metadata for duplicates in archive"
fi

restore_metadata
