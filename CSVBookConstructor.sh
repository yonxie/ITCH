#!/bin/bash

# wrapper to the c++ executable BookConstructor for CSV input files.

display_usage() {
    echo
    echo "usage:    $0 [-fh] [-n #] input_file_path output_folder stock venue date"
    echo "          $0 [-h]"
    echo
    echo " -h, --help     Display usage instructions"
    echo " -f, --force    To force program execution if output files already exists"
    echo " -n,            Number of levels to store for the book, default is 5"
    echo
}

POSITIONAL=()
LEVELS_FLAG=0
FORCE_FLAG=0
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -n)
    LEVELS_FLAG=1
    LEVELS="$2"
    shift
    shift
    ;;
    -f|--force)
    FORCE_FLAG=1
    shift
    ;;
    -h|--help)
    display_usage
    shift
    exit
    ;;
    -*)
    echo
    echo Unrecognized option: $key
    echo
    display_usage
    exit
    ;;
    *)
    POSITIONAL+=("$1")
    shift
    ;;
esac
done

set -- "${POSITIONAL[@]}"

# required arguments
if [ ${#POSITIONAL[@]} -lt 5 ]; then
    display_usage
    exit
fi

INPUT_FILE_PATH=${POSITIONAL[0]}
OUTPUT_FOLDER=${POSITIONAL[1]}
STOCK=${POSITIONAL[2]}
VENUE=${POSITIONAL[3]}
DATE=${POSITIONAL[4]}

# add trailing backslash if needed
[[ "${OUTPUT_FOLDER}" != */ ]] && OUTPUT_FOLDER=${OUTPUT_FOLDER}"/"

# Check if input file exists
if [ ! -e "$INPUT_FILE_PATH" ]; then
    echo
    echo "Input file $INPUT_FILE_PATH does not exist."
    echo
    exit
fi

# Check if output folder exists
if [ ! -d "$OUTPUT_FOLDER" ]; then
    echo
    echo "Output folder $OUTPUT_FOLDER does not exist. Creating it..."
    mkdir -p "$OUTPUT_FOLDER"
fi

# if -n is not invoked
if [ $LEVELS_FLAG == 0 ]; then
    LEVELS=5
fi

# Construct output file names
BOOK_FILE_NAME="${DATE}_${STOCK}_${VENUE}_book_${LEVELS}.csv"
MESS_FILE_NAME="${DATE}_${STOCK}_${VENUE}_message.csv"

# Check if output files already exist
if [ -e "${OUTPUT_FOLDER}${BOOK_FILE_NAME}" -a $FORCE_FLAG -eq 0 ]; then
    echo
    echo "${OUTPUT_FOLDER}${BOOK_FILE_NAME} already exists. To force execution run with -f option."
    echo
    exit
fi

# Run the BookConstructor executable
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo
echo "Running BookConstructor with CSV input: $INPUT_FILE_PATH"
echo

"$DIR"/bin/BookConstructor "$INPUT_FILE_PATH" "$OUTPUT_FOLDER" "$OUTPUT_FOLDER" "$LEVELS" "$STOCK" "$VENUE" "$DATE"

echo
echo "Processing complete."
echo "Output files:"
echo "  - Book: ${OUTPUT_FOLDER}${DATE}_${STOCK}_${VENUE}_book_${LEVELS}.csv"
echo "  - Message: ${OUTPUT_FOLDER}${DATE}_${STOCK}_${VENUE}_message.csv"
echo
