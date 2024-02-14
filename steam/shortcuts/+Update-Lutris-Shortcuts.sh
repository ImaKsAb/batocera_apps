#!/bin/bash
# Specify the directory to scan and the output file
directory_to_scan="/userdata/system/Desktop"
output_file="/userdata/system/pro/steam/lutris_list.txt"

# Check if the directory exists
if [ ! -d "$directory_to_scan" ]; then
    echo "Error: Directory '$directory_to_scan' does not exist."
    exit 1
fi

# Remove existing output file
rm -f "$output_file"

# Iterate through .desktop files in the specified directory
for file_path in "$directory_to_scan"/*.desktop; do
    # Check if the file exists
    if [ -f "$file_path" ]; then
        # Extract the filename without extension
        filename=$(basename "$file_path" .desktop)
        # Extract the relevant information using grep and sed
        exec_line=$(grep -E '^Exec=(env LUTRIS_SKIP_INIT=1 )?lutris lutris:rungame(id)?/' "$file_path" | sed -E "s/^Exec=(env LUTRIS_SKIP_INIT=1 )?lutris (lutris:rungame(id)?\/.+)/$filename \2/p")
        if [ -n "$exec_line" ]; then
            # Append the information to the output file
            echo "$exec_line" >> "$output_file"
        fi
    fi
done

# Full path to lutris_list.txt
lutris_list_file="/userdata/system/pro/steam/lutris_list.txt"

# Read each line from lutris_list.txt
while IFS= read -r line; do
    # Extract game_name and lutris_url_part
    game_name=$(echo "$line" | awk -F ' lutris:' '{print $1}')
    lutris_url_part=$(echo "$line" | awk -F ' lutris:' '{print $2}')

    # Create the script content without an undesired trailing quote
    script_content="#!/bin/bash

unclutter-remote -s
ALLOW_ROOT=1 DISPLAY=:0.0 ~/pro/lutris/conty.sh lutris lutris:$lutris_url_part"
unclutter-remote h

    # Create the script file
    script_path="/userdata/roms/lutris/$game_name.sh"
    echo "$script_content" > "$script_path"
    chmod +x "$script_path"
    echo "Script created: $script_path"
done < "$lutris_list_file"
echo "Script execution completed. Check $output_file for the result."
killall -9 emulationstation
