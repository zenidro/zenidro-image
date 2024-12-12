#!/bin/bash
cd /server || exit 1

echo "Current directory: $(pwd)"

OMP_CLI_ARGS=()

while IFS='=' read -r VAR_NAME VAR_VALUE; do
    VAR_NAME=${VAR_NAME#OMP_}
    VAR_NAME=${VAR_NAME//__/.}
    VAR_NAME=${VAR_NAME,,}

    if [[ $VAR_NAME == *"."* ]]; then
        if [[ $VAR_VALUE ==

\[*\]

 ]]; then
            VAR_VALUE=$(echo "$VAR_VALUE" | sed -e 's/^

\[//' -e 's/\]

$//')
            VAR_VALUE="[${VAR_VALUE//\'/\"}]"
        fi
        IFS='.' read -ra KEYS <<< "$VAR_NAME"
        TMP_JSON=""
        for (( idx=${#KEYS[@]}-1 ; idx>=0 ; idx-- )); do
            if [ -z "$TMP_JSON" ]; then
                TMP_JSON="\"${KEYS[idx]}\": $VAR_VALUE"
            else
                TMP_JSON="{\"${KEYS[idx]}\": $TMP_JSON}"
            fi
        done
        VAR_NAME=$TMP_JSON
        OMP_CLI_ARGS+=("$VAR_NAME")
    else
        OMP_CLI_ARGS+=("$VAR_NAME=$VAR_VALUE")
    fi
    echo "Setting CLI arg: $VAR_NAME=$VAR_VALUE"
done < <(env | grep '^OMP_')

if [ "$#" -gt 0 ]; then
    echo -e "\nAlternative launching method: $*"
    exec "$@"
else
    exec ./omp-server
fi
