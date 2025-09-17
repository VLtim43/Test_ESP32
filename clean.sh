#!/bin/bash

PROJECT_ROOT=$(pwd)
SRC_DIR="$PROJECT_ROOT/src"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}ESP32 Project Cleanup${NC}"
echo "===================="
echo ""

# Clean src directory
echo -e "${BLUE}Cleaning src directory...${NC}"
if [[ -d "$SRC_DIR" ]]; then
    # Remove all files in src except .gitkeep if it exists
    find "$SRC_DIR" -type f ! -name ".gitkeep" -delete

    # Create a minimal main.cpp for testing
    cat > "$SRC_DIR/main.cpp" << 'EOF'
// copy the .cpp files you want to test here

#include <Arduino.h>
int myFunction(int, int);

void setup() {}

void loop() {}
EOF

    echo -e "${GREEN}  ✓ Cleaned src directory${NC}"
    echo -e "${BLUE}  ✓ Created minimal main.cpp${NC}"
else
    echo -e "${RED}  Error: src directory not found${NC}"
    exit 1
fi

# Restore original diagram.json
echo -e "${BLUE}Restoring original diagram.json...${NC}"
if [[ -f "$PROJECT_ROOT/diagram_original.json" ]]; then
    mv "$PROJECT_ROOT/diagram_original.json" "$PROJECT_ROOT/diagram.json"
    echo -e "${GREEN}  ✓ Restored original diagram.json${NC}"
elif [[ -f "$PROJECT_ROOT/diagram.json" ]]; then
    # If no original exists but diagram.json exists, create a minimal one
    echo -e "${YELLOW}  No original found, creating minimal diagram.json${NC}"
    cat > "$PROJECT_ROOT/diagram.json" << 'EOF'
{
  "version": 1,
  "author": "user",
  "editor": "wokwi",
  "parts": [
    {
      "type": "wokwi-esp32-devkit-v1",
      "id": "esp",
      "top": 0,
      "left": 0,
      "attrs": {}
    }
  ],
  "connections": [
    ["esp:TX0", "$serialMonitor:RX", "", []],
    ["esp:RX0", "$serialMonitor:TX", "", []]
  ],
  "dependencies": {}
}
EOF
    echo -e "${GREEN}  ✓ Created minimal diagram.json${NC}"
else
    echo -e "${YELLOW}  No diagram.json to restore${NC}"
fi

echo ""
echo -e "${GREEN}Cleanup complete!${NC}"
echo -e "${BLUE}Project restored to clean state.${NC}"
echo ""
echo -e "${BLUE}Current src/ contents:${NC}"
ls -la "$SRC_DIR"
echo ""
echo -e "${BLUE}To test a sensor, run: ./test_sensor.sh${NC}"