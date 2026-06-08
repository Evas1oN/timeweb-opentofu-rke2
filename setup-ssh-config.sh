#!/bin/bash
set -euo pipefail
LABEL=$(tput setab 2)
NC=$(tput sgr0)

[ -d ~/.ssh/config.d ] || mkdir -v -m 700 -p ~/.ssh/config.d

tofu output -raw ssh-config | tee ~/.ssh/config.d/tofu

grep -q "Include ~/.ssh/config.d/*" ~/.ssh/config || cat <<-EOL
Please add ${LABEL}Include ~/.ssh/config.d/*${NC} to your ~/.ssh/config file
EOL