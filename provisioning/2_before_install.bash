#!/usr/bin/env bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

OUTPUT_DIR=/tmp/provision
OUTPUT_FILE="${OUTPUT_DIR}/before_install.bash"

mkdir -p "${OUTPUT_DIR}"

# Make the generated script will exit on any error
echo "
#!/usr/bin/env bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

set -x
" | tee "${OUTPUT_FILE}"

# Make a script out of the before_install commands
sed  -n `#Control output`\
     -e '0,/^before_install/d' `#Ignore lines until before_command`\
     -e 's/^\s*#/#/' `# Remove comment lines indents`\
     -e 's/^\s*-\s*//' `# Remove the YAML list tokens`\
     -e p `# Print out the modified line`\
     /vagrant/.travis.yml | tee -a "${OUTPUT_FILE}"

chmod u+x "${OUTPUT_FILE}"
exec "${OUTPUT_FILE}"
