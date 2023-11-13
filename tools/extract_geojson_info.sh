#!/bin/bash
# Copyright 2023 Woven by Toyota

# Extracts the content within the outer curly brackets of a json file and saves it to a new file named <input_file_name>.geojson

# Check if a file name is provided as an argument
if [ $# -ne 1 ]; then
  echo "Usage: $0 <input_file>"
  exit 1
fi

# Args
INPUT_FILE=$1

# Check if the input file exists
if [ ! -f "$INPUT_FILE" ]; then
  echo "Input file does not exist: $INPUT_FILE"
  exit 1
fi

# Output file
output_file="${INPUT_FILE}.geojson"

# Extract the content within the outer curly brackets and save it to the output file.
sed -n '/{/,/}\n/p' "$INPUT_FILE" | sed 's/-->//g' | sed '/^$/d' > "$output_file"

exit_code=$?
