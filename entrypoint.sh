#!/bin/bash
cd /server || exit 1

OMP_CLI_ARGS=()
while IFS='=' read -r VAR_NAME VAR_VALUE; do
    VAR_NAME=${VAR_NAME#OMP_}
    VAR_NAME=${VAR_NAME//__/.}
    VAR_NAME=${VAR_NAME,,}
    OMP_CLI_ARGS+=("$VAR_NAME=$VAR_VALUE")
done < <(env | grep '^OMP_')

if [ "$#" -gt 0 ]; then
    echo -e "\nAlternative launching method: $*"
    exec "$@"
else
    exec ./omp-server -c "${OMP_CLI_ARGS[@]}"
fi
