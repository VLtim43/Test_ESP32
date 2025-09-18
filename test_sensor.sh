#!/bin/bash

PROJECT_ROOT=$(pwd)
EXAMPLES_DIR="$PROJECT_ROOT/examples"
SRC_DIR="$PROJECT_ROOT/src"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Backup original files if they exist and backups don't exist
if [[ -f "$PROJECT_ROOT/diagram.json" && ! -f "$PROJECT_ROOT/diagram_original.json" ]]; then
    echo -e "${BLUE}Saving original diagram.json as diagram_original.json...${NC}"
    mv "$PROJECT_ROOT/diagram.json" "$PROJECT_ROOT/diagram_original.json"
fi

if [[ -f "$SRC_DIR/main.cpp" && ! -f "$PROJECT_ROOT/main_backup.cpp" ]]; then
    echo -e "${BLUE}Saving original main.cpp as main_backup.cpp...${NC}"
    cp "$SRC_DIR/main.cpp" "$PROJECT_ROOT/main_backup.cpp"
fi

# Function to display available examples
display_examples() {
    echo -e "${BLUE}Available sensor examples:${NC}"
    echo ""

    local count=1

    for dir in "$EXAMPLES_DIR"/*; do
        if [[ -d "$dir" ]]; then
            local example_name=$(basename "$dir")
            echo -e "${YELLOW}$count)${NC} $example_name"
            ((count++))
        fi
    done

    echo ""
    echo -e "${BLUE}Select a sensor example (1-$((count-1))) or 'q' to quit:${NC}"
}

# Function to get examples array
get_examples() {
    local examples=()
    for dir in "$EXAMPLES_DIR"/*; do
        if [[ -d "$dir" ]]; then
            local example_name=$(basename "$dir")
            examples+=("$example_name")
        fi
    done
    printf '%s\n' "${examples[@]}"
}

# Function to copy sensor files
copy_sensor_files() {
    local sensor_name="$1"
    local sensor_dir="$EXAMPLES_DIR/$sensor_name"

    echo -e "${GREEN}Setting up sensor: $sensor_name${NC}"

    # Clean src directory (no backups in src to preserve)
    echo -e "${BLUE}Cleaning src directory...${NC}"
    find "$SRC_DIR" -name "*.cpp" -delete
    rm -f "$SRC_DIR"/*.h

    # Copy the sensor-specific .cpp file from example
    local sensor_cpp="$sensor_dir/${sensor_name}.cpp"
    if [[ -f "$sensor_cpp" ]]; then
        echo -e "${BLUE}Copying ${sensor_name}.cpp to main.cpp${NC}"
        cp "$sensor_cpp" "$SRC_DIR/main.cpp"
    else
        echo -e "${RED}Error: No ${sensor_name}.cpp file found in $sensor_name${NC}"
        return 1
    fi

    # Copy all .h files (keep original names)
    local header_files=$(find "$sensor_dir" -name "*.h" -type f)
    if [[ -n "$header_files" ]]; then
        echo -e "${BLUE}Copying header files...${NC}"
        while IFS= read -r header; do
            echo -e "${BLUE}  Copying $(basename "$header")${NC}"
            cp "$header" "$SRC_DIR/"
        done <<< "$header_files"
    fi

    # Copy any additional .cpp files (utilities, excluding the main sensor .cpp file)
    local additional_cpp=$(find "$sensor_dir" -name "*.cpp" -not -name "${sensor_name}.cpp" -type f)
    if [[ -n "$additional_cpp" ]]; then
        echo -e "${BLUE}Copying additional .cpp files...${NC}"
        while IFS= read -r cpp_file; do
            local basename_cpp=$(basename "$cpp_file")
            echo -e "${BLUE}  Copying $basename_cpp${NC}"
            cp "$cpp_file" "$SRC_DIR/"
        done <<< "$additional_cpp"
    fi

    # Find and copy diagram file (foldername.diagram.json format)
    local diagram_file="$sensor_dir/${sensor_name}.diagram.json"

    if [[ -f "$diagram_file" ]]; then
        echo -e "${BLUE}Copying ${sensor_name}.diagram.json -> diagram.json${NC}"
        cp "$diagram_file" "$PROJECT_ROOT/diagram.json"
    else
        echo -e "${YELLOW}Warning: No diagram file found for $sensor_name${NC}"
        echo -e "${YELLOW}Expected: ${sensor_name}.diagram.json${NC}"
    fi

    echo -e "${GREEN}Setup complete! Ready for Wokwi testing.${NC}"
    echo -e "${BLUE}Files in src/:${NC}"
    ls -la "$SRC_DIR"
    echo ""

    # Build the project with PlatformIO
    echo -e "${YELLOW}Building project with PlatformIO...${NC}"
    if command -v pio &> /dev/null; then
        pio run
    elif command -v platformio &> /dev/null; then
        platformio run
    else
        echo -e "${RED}Error: PlatformIO not found. Please install PlatformIO CLI.${NC}"
        echo -e "${YELLOW}You can install it with: pip install platformio${NC}"
        return 1
    fi

    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}Build successful!${NC}"
    else
        echo -e "${RED}Build failed. Check the output above for errors.${NC}"
        return 1
    fi

    echo ""
    echo -e "${BLUE}To clean up later, run: ./clean.sh${NC}"
}

# Main script
main() {
    echo -e "${GREEN}ESP32 Sensor Testing Setup${NC}"
    echo "================================"
    echo ""

    # Check if examples directory exists
    if [[ ! -d "$EXAMPLES_DIR" ]]; then
        echo -e "${RED}Error: Examples directory not found at $EXAMPLES_DIR${NC}"
        exit 1
    fi

    # Display examples menu
    display_examples

    # Get list of examples
    mapfile -t examples < <(get_examples)

    # Read user selection
    read -r selection

    # Handle quit
    if [[ "$selection" == "q" || "$selection" == "Q" ]]; then
        echo -e "${YELLOW}Exiting...${NC}"
        exit 0
    fi

    # Validate selection
    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [[ $selection -lt 1 ]] || [[ $selection -gt ${#examples[@]} ]]; then
        echo -e "${RED}Invalid selection. Please run the script again.${NC}"
        exit 1
    fi

    # Get selected example
    local selected_example="${examples[$((selection-1))]}"

    # Copy files for selected sensor
    copy_sensor_files "$selected_example"
}

# Run main function
main "$@"