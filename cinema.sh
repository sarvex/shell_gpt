#!/usr/bin/env bash

# Convert a bash script into an asciinema recording

# set -o errexit -o nounset -o pipefail

INPUT_FILE=${1:-}
if [[ -z "${INPUT_FILE}" ]]; then
  echo "Syntax: $0 <path/to/bash-scipt.sh> <path/to/out.cast>"
  exit 1
fi

OUTPUT_FILE=${2:-}
if [[ -z "${OUTPUT_FILE}" ]]; then
  echo "Syntax: $0 <path/to/bash-scipt.sh> <path/to/out.cast>"
  exit 1
fi

CHAR_STEP=0.05
LINE_STEP=0.5

IFS='' read -r -d '' BG_SCRIPT << EOF || true
set -o errexit -o nounset -o pipefail
sleep 1
while IFS="" read -r line; do
  if [[ "\${line}" == "#!"* ]]; then
    # skip shebang
    continue
  fi
  # loop utf-8 characters and print them individually
  while IFS="" read -r char; do
    echo -n "\${char}"
    sleep ${CHAR_STEP}
  done <<< "\$(echo "\${line}" | sed -e 's/\(.\)/\1\n/g')"
  echo
  sleep ${LINE_STEP}
done < "/dev/stdin"
echo
echo "exit"
EOF

cat "${INPUT_FILE}" | bash -c "${BG_SCRIPT}" | asciinema rec --stdin "${OUTPUT_FILE}"