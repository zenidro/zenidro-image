#!/bin/bash
cd /server || exit 1

CONFIG_FILE="config.json"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Config file not found!"
    exit 1
fi

TEMP_CONFIG_FILE=$(mktemp)

while IFS='=' read -r VAR_NAME VAR_VALUE; do
    VAR_NAME=${VAR_NAME#OMP_}
    VAR_NAME=${VAR_NAME//__/.}
    VAR_NAME=${VAR_NAME,,}
    jq --arg key "$VAR_NAME" --arg value "$VAR_VALUE" '.[$key] = $value' "$CONFIG_FILE" > "$TEMP_CONFIG_FILE" && mv "$TEMP_CONFIG_FILE" "$CONFIG_FILE"
done < <(env | grep '^OMP_')

if [ "$#" -gt 0 ]; then
    exec "$@"
else
    exec ./omp-server -c "$CONFIG_FILE"
fi
