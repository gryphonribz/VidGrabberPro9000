#!/bin/bash

# Constants
LOG_FILE="download.log"

# Function to display usage information
usage() {
    cat << "EOF"
__      ___     _  _____           _     _               _____          ___   ___   ___   ___  
 \ \    / (_)   | |/ ____|         | |   | |             |  __ \        / _ \ / _ \ / _ \ / _ \ 
  \ \  / / _  __| | |  __ _ __ __ _| |__ | |__   ___ _ __| |__) | __ __| (_) | | | | | | | | | |
   \ \/ / | |/ _` | | |_ | '__/ _` | '_ \| '_ \ / _ \ '__|  ___/ '__/ _ \__, | | | | | | | | | |
    \  /  | | (_| | |__| | | | (_| | |_) | |_) |  __/ |  | |   | | | (_) |/ /| |_| | |_| | |_| |
     \/   |_|\__,_|\_____|_|  \__,_|_.__/|_.__/ \___|_|  |_|   |_|  \___//_/  \___/ \___/ \___/ 

Usage: $0 [OPTIONS]

Options:
  -u, --url URL1 URL2 ...  Specify one or more URLs of the videos
  -o, --output DIR         Specify the output directory
  -p, --parallel NUM       Specify the number of parallel downloads (default: 5)
  -h, --help               Display this help message

EOF
    exit 1
}

# Function to handle errors
handle_error() {
    local error_message="$1"
    echo "Error: $error_message"
    exit 1
}

# Function to download video
download_video() {
    local url="$1"
    local output_dir="$2"
    
    echo "Downloading video from: $url to $output_dir"
    # Add download logic here
    # For demonstration purposes, just echo the URL and output directory
    echo "Downloaded video: $(basename "$url")"
}

# Function to create log entry
log() {
    local message="$1"
    echo "$(date +"%Y-%m-%d %T"): $message" >> "$LOG_FILE"
}

# Function for parallel downloads
parallel_downloads() {
    local urls=("$@")
    local output_dir="$OUTPUT_DIR"
    local num_jobs="$PARALLEL_JOBS"
    local i=0
    local pid_list=()

    for url in "${urls[@]}"; do
        # Start download in background
        download_video "$url" "$output_dir" &
        pid_list+=("$!")
        let i++
        # Limit the number of parallel jobs
        if [[ $i -ge $num_jobs ]]; then
            # Wait for all background jobs to finish
            wait "${pid_list[@]}"
            # Reset counter and PID list
            i=0
            pid_list=()
        fi
    done

    # Wait for remaining background jobs to finish
    wait "${pid_list[@]}"
}

# Main function
main() {
    # Create log file if it doesn't exist
    touch "$LOG_FILE"

    # Default values
    PARALLEL_JOBS=5

    if [[ "$#" -eq 0 ]]; then
        usage
    fi

    # Parse command-line options
    while [[ $# -gt 0 ]]; do
        key="$1"
        case $key in
            -u|--url)
                shift
                URLS=("$@")
                break
                ;;
            -o|--output)
                OUTPUT_DIR="$2"
                shift
                ;;
            -p|--parallel)
                PARALLEL_JOBS="$2"
                shift
                ;;
            -h|--help)
                usage
                ;;
            *)
                echo "Error: Invalid option: $1"
                usage
                ;;
        esac
        shift
    done

    # Validate URL and output directory
    if [[ -z ${URLS[@]} ]]; then
        usage
    fi

    if [[ -z $OUTPUT_DIR ]]; then
        OUTPUT_DIR="."
    fi

    # Create output directory if it doesn't exist
    mkdir -p "$OUTPUT_DIR"

    # Download videos in parallel
    parallel_downloads "${URLS[@]}"

    echo "Download complete"
}

main "$@"
