#!/bin/bash

# ESP32 Project Cleaner Script
# Restores original main.cpp and diagram.json from backup

set -e

SRC_DIR="src"
BACKUP_DIR="backup"
ROOT_DIR="."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}ESP32 Project Cleaner${NC}"
echo "====================="

# Check if backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    echo -e "${RED}Error: backup directory not found!${NC}"
    exit 1
fi

# Check if backup files exist
if [ ! -f "$BACKUP_DIR/main_original.cpp" ]; then
    echo -e "${RED}Error: backup file main_original.cpp not found!${NC}"
    exit 1
fi

if [ ! -f "$BACKUP_DIR/diagram_original.json" ]; then
    echo -e "${RED}Error: backup file diagram_original.json not found!${NC}"
    exit 1
fi

echo -e "${YELLOW}Restoring original files...${NC}"

# Restore main.cpp
echo -e "${BLUE}Restoring src/main.cpp...${NC}"
cp "$BACKUP_DIR/main_original.cpp" "$SRC_DIR/main.cpp"

# Restore diagram.json
echo -e "${BLUE}Restoring diagram.json...${NC}"
cp "$BACKUP_DIR/diagram_original.json" "$ROOT_DIR/diagram.json"

# Remove any additional files that might have been copied (except main.cpp)
additional_files=$(find "$SRC_DIR" -name "*.cpp" -o -name "*.h" | grep -v main.cpp)
if [ -n "$additional_files" ]; then
    echo -e "${YELLOW}Removing additional project files...${NC}"
    for file in $additional_files; do
        if [ -f "$file" ]; then
            echo -e "${BLUE}Removing $(basename "$file")...${NC}"
            rm -f "$file"
        fi
    done
fi

echo
echo -e "${GREEN}✓ Original files have been restored successfully!${NC}"
echo -e "${BLUE}Files restored:${NC}"
echo "  - src/main.cpp"
echo "  - diagram.json"

if [ -n "$additional_files" ]; then
    echo "  - Removed additional project files"
fi

echo
echo -e "${YELLOW}Ready for a new project selection with './test_project.sh'${NC}"