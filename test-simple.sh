#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/colors.sh"

# Super simple test
options=(
    "Option 1"
    "Option 2"
    "Option 3"
)

echo "Number of options: ${#options[@]}"
echo "Options are:"
for i in "${!options[@]}"; do
    echo "  $i: ${options[$i]}"
done

echo ""
echo "Now testing display in loop:"
sleep 1

clear
echo "TESTING DISPLAY"
echo ""

for i in "${!options[@]}"; do
    if [[ $i -eq 0 ]]; then
        echo -e "${GREEN}> ${options[$i]}${NC}"
    else
        echo -e "  ${options[$i]}"
    fi
done

echo ""
echo "Can you see all 3 options above? (press any key)"
read -rsn1
echo "Done"
