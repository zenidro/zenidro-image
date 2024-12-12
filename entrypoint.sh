#!/bin/bash
cd /server

OMP_CLI_ARGS=()

ENV_OPENMP_VARS=$(env | grep '^OMP_')

while IFS= read -r ENV_VAR; do
    IFS='=' read -r VAR_NAME VAR_VALUE <<< "$ENV_VAR"

    VAR_NAME=$(echo "$VAR_NAME" | sed 's/^OMP_//g' | sed 's/__/\./g' | tr '[:upper:]' '[:lower:]')

    if jq --exit-status ".${VAR_NAME}" config.json > /dev/null; then
        if [[ $VAR_VALUE =~ ^\[.*\]$ ]]; then
            VAR_VALUE=$(echo "$VAR_VALUE" | sed 's/\[/"/g' | sed 's/\]/"/g' | sed 's/,/","/g' | sed 's/"//g')
            VAR_VALUE=$(echo "$VAR_VALUE" | sed 's/"/\\"/g')
            jq ".${VAR_NAME} = [${VAR_VALUE}]" config.json > config.json.tmp
        else
            jq ".${VAR_NAME} = \"${VAR_VALUE}\"" config.json > config.json.tmp
        fi
        mv config.json.tmp config.json
    else
        if [[ $VAR_VALUE =~ ^\[.*\]$ ]]; then
            VAR_VALUE=$(echo "$VAR_VALUE" | sed 's/\[/"/g' | sed 's/\]/"/g' | sed 's/,/","/g' | sed 's/"//g')
            VAR_VALUE=$(echo "$VAR_VALUE" | sed 's/"/\\"/g')
            jq ".${VAR_NAME} = [${VAR_VALUE}]" config.json > config.json.tmp
        else
            jq ".${VAR_NAME} = \"${VAR_VALUE}\"" config.json > config.json.tmp
        fi
        mv config.json.tmp config.json
    fi

    OMP_CLI_ARGS+=("$VAR_NAME=$VAR_VALUE")

done <<< "$ENV_OPENMP_VARS"

echo "Config.json:"
cat config.json

if [ $# -gt 0 ]; then
    echo -e "\nAlternative launching method: $@"
    sh -c "$@"
else
    ./omp-server
fi

EXIT_CODE=$?

exit $EXIT_CODE