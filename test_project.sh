#!/bin/bash

# ESP32 Project Selector Script
# Allows selection of example projects and copies them to src/main.cpp and root diagram.json

set -e

EXAMPLES_DIR="examples"
SRC_DIR="src"
BACKUP_DIR="backup"
ROOT_DIR="."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}ESP32 Project Selector${NC}"
echo "========================"

# Check if examples directory exists
if [ ! -d "$EXAMPLES_DIR" ]; then
    echo -e "${RED}Error: examples directory not found!${NC}"
    exit 1
fi

# Get list of example projects
projects=($(ls -1 "$EXAMPLES_DIR" | sort))

if [ ${#projects[@]} -eq 0 ]; then
    echo -e "${RED}No example projects found in $EXAMPLES_DIR${NC}"
    exit 1
fi

echo -e "${YELLOW}Available projects:${NC}"
echo

# Display numbered list of projects
for i in "${!projects[@]}"; do
    echo "  $((i+1)). ${projects[i]}"
done

echo
read -p "Select project number (1-${#projects[@]}): " selection

# Validate selection
if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt ${#projects[@]} ]; then
    echo -e "${RED}Invalid selection!${NC}"
    exit 1
fi

# Get selected project
selected_project="${projects[$((selection-1))]}"
project_dir="$EXAMPLES_DIR/$selected_project"

echo
echo -e "${GREEN}Selected: $selected_project${NC}"

# Check if project has main.cpp
if [ ! -f "$project_dir/main.cpp" ]; then
    echo -e "${RED}Error: $project_dir/main.cpp not found!${NC}"
    exit 1
fi

# Create backup if it doesn't exist
if [ ! -f "$BACKUP_DIR/main_original.cpp" ]; then
    echo -e "${YELLOW}Creating backup of original main.cpp...${NC}"
    cp "$SRC_DIR/main.cpp" "$BACKUP_DIR/main_original.cpp"
fi

if [ ! -f "$BACKUP_DIR/diagram_original.json" ]; then
    echo -e "${YELLOW}Creating backup of original diagram.json...${NC}"
    cp "$ROOT_DIR/diagram.json" "$BACKUP_DIR/diagram_original.json"
fi

# Copy main.cpp
echo -e "${BLUE}Copying main.cpp...${NC}"
cp "$project_dir/main.cpp" "$SRC_DIR/main.cpp"

# Copy additional source files if they exist (like display_utils.cpp, display_utils.h)
for file in "$project_dir"/*.cpp "$project_dir"/*.h; do
    if [ -f "$file" ] && [ "$(basename "$file")" != "main.cpp" ]; then
        echo -e "${BLUE}Copying $(basename "$file")...${NC}"
        cp "$file" "$SRC_DIR/"
    fi
done

# Find and copy diagram file
diagram_file=$(find "$project_dir" -name "*.diagram.json" | head -1)
if [ -n "$diagram_file" ]; then
    echo -e "${BLUE}Copying diagram file...${NC}"
    cp "$diagram_file" "$ROOT_DIR/diagram.json"
else
    echo -e "${YELLOW}Warning: No diagram.json file found for this project${NC}"
fi

echo
echo -e "${GREEN}✓ Project '$selected_project' has been loaded successfully!${NC}"
echo -e "${BLUE}Files updated:${NC}"
echo "  - src/main.cpp"
echo "  - diagram.json"

# List any additional files copied
additional_files=$(find "$SRC_DIR" -name "*.cpp" -o -name "*.h" | grep -v main.cpp | sort)
if [ -n "$additional_files" ]; then
    echo "  - Additional files:"
    echo "$additional_files" | sed 's/^/    /'
fi

echo
echo -e "${YELLOW}Use './clean.sh' to restore original files${NC}"