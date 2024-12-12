#!/bin/bash
cd /server

update_config() {
    local key=$1
    local value=$2
    local json_path=$3

    if [[ $value == \[* ]] || [[ $value == {* ]]; then
        formatted_value=$value
    else
        formatted_value="\"$value\""
    fi

    jq "$json_path = $formatted_value" config.json > temp.json && mv temp.json config.json
}

OMP_CLI_ARGS=()

ENV_OPENMP_VARS=$(env | grep '^OMP_')

while IFS= read -r ENV_VAR; do
    IFS='=' read -r VAR_NAME VAR_VALUE <<< "$ENV_VAR"

    CLI_VAR_NAME=$(echo "$VAR_NAME" | sed 's/^OMP_//g' | sed 's/__/\./g' | tr '[:upper:]' '[:lower:]')
    OMP_CLI_ARGS+=("$CLI_VAR_NAME=$VAR_VALUE")

    JSON_VAR_NAME=$(echo "$VAR_NAME" | sed 's/^OMP_//' | tr '[:upper:]' '[:lower:]' | sed 's/__/./g')
    update_config "$VAR_NAME" "$VAR_VALUE" ".$JSON_VAR_NAME"

done <<< "$ENV_OPENMP_VARS"

if [ $# -gt 0 ]; then
    echo -e "\nAlternative launching method: $@"
    sh -c "$@"
else
    ./omp-server -c "${OMP_CLI_ARGS[@]}"
fi

EXIT_CODE=$?

exit $EXIT_CODE