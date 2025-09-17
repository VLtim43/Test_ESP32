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

# Rename original diagram.json if it exists and original backup doesn't exist
if [[ -f "$PROJECT_ROOT/diagram.json" && ! -f "$PROJECT_ROOT/diagram_original.json" ]]; then
    echo -e "${BLUE}Saving original diagram.json as diagram_original.json...${NC}"
    mv "$PROJECT_ROOT/diagram.json" "$PROJECT_ROOT/diagram_original.json"
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

    # Clean src directory first
    echo -e "${BLUE}Cleaning src directory...${NC}"
    rm -f "$SRC_DIR"/*.cpp "$SRC_DIR"/*.h

    # Find and copy the main cpp file (rename to main.cpp)
    local main_cpp=$(find "$sensor_dir" -name "*.cpp" -type f | head -1)
    if [[ -n "$main_cpp" ]]; then
        echo -e "${BLUE}Copying $(basename "$main_cpp") -> main.cpp${NC}"
        cp "$main_cpp" "$SRC_DIR/main.cpp"
    else
        echo -e "${RED}Error: No .cpp file found in $sensor_name${NC}"
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

    # Copy any additional .cpp files (utilities, keep original names)
    local cpp_count=$(find "$sensor_dir" -name "*.cpp" -type f | wc -l)
    if [[ $cpp_count -gt 1 ]]; then
        echo -e "${BLUE}Copying additional .cpp files...${NC}"
        find "$sensor_dir" -name "*.cpp" -type f | while read -r cpp_file; do
            local basename_cpp=$(basename "$cpp_file")
            if [[ "$basename_cpp" != "$(basename "$main_cpp")" ]]; then
                echo -e "${BLUE}  Copying $basename_cpp${NC}"
                cp "$cpp_file" "$SRC_DIR/"
            fi
        done
    fi

    # Find and copy diagram file
    local diagram_file=""

    # Look for diagram files with different naming patterns
    for pattern in "${sensor_name}_diagram.json" "${sensor_name}_display.json" "${sensor_name}.json"; do
        if [[ -f "$sensor_dir/$pattern" ]]; then
            diagram_file="$sensor_dir/$pattern"
            break
        fi
    done

    if [[ -n "$diagram_file" ]]; then
        echo -e "${BLUE}Copying $(basename "$diagram_file") -> diagram.json${NC}"
        cp "$diagram_file" "$PROJECT_ROOT/diagram.json"
    else
        echo -e "${YELLOW}Warning: No diagram file found for $sensor_name${NC}"
        echo -e "${YELLOW}Looked for: ${sensor_name}_diagram.json, ${sensor_name}_display.json, ${sensor_name}.json${NC}"
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