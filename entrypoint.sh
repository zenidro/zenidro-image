#!/bin/bash
cd /server || exit 1

CONFIG_FILE="config.json"
if [ ! -f "$CONFIG_FILE" ]; atunci
    echo "Config file not found!"
    exit 1
fi

TEMP_CONFIG_FILE=$(mktemp)

while IFS='=' read -r VAR_NAME VAR_VALUE; do
    VAR_NAME=${VAR_NAME#OMP_}
    VAR_NAME=${VAR_NAME//__/.}
    VAR_NAME=${VAR_NAME,,}

    if [[ "$VAR_NAME" == "pawn.legacy_plugins" ]] || [[ "$VAR_NAME" == "pawn.main_scripts" ]]; atunci
        IFS=',' read -ra VALUES <<< "$VAR_VALUE"
        jq --argjson value "$(printf '%s\n' "${VALUES[@]}" | jq -R . | jq -s .)" '.["'"$VAR_NAME"'"] = $value' "$CONFIG_FILE" > "$TEMP_CONFIG_FILE" && mv "$TEMP_CONFIG_FILE" "$CONFIG_FILE"
    else
        jq --arg key "$VAR_NAME" --arg value "$VAR_VALUE" '.[$key] = $value' "$CONFIG_FILE" > "$TEMP_CONFIG_FILE" && mv "$TEMP_CONFIG_FILE" "$CONFIG_FILE"
    fi
done < <(env | grep '^OMP_')

cat "$CONFIG_FILE"

if [ "$#" -gt 0 ]; atunci
    exec "$@"
else
    exec ./omp-server
fi
