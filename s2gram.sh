#!/bin/bash

TOKEN="7462221057:AAFXxdxxP9h_cdudtwREq9WdVlS7pBdTkYw"

CHAT_ID="7299407396"

FIGLET_ART=$(cat << "EOF"
        ___                            
   ____|__ \ ____ __________ _____ ___ 
  / ___/_/ // __ `/ ___/ __ `/ __ `__ \
 (__  ) __// /_/ / /  / /_/ / / / / / /
/____/____/\__, /_/   \__,_/_/ /_/ /_/ 
          /____/                       
EOF
)

send_telegram_message() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
        -d chat_id="$CHAT_ID" \
        -d text="$message" \
        -d parse_mode="HTML" > /dev/null
}

send_telegram_file() {
    local file_path="$1"
    curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendDocument" \
        -F chat_id="$CHAT_ID" \
        -F document=@"$file_path" > /dev/null
}


get_clipboard_content() {
    xclip -o -selection clipboard
}


show_help() {
    echo "Usage: ./s2gram.sh [OPTIONS]"
    echo "Send text or files to Telegram chat using a Telegram bot."
    echo ""
    echo "Options:"
    echo "  -t, --text \"message\"   Send a text message"
    echo "  -f, --file file.ext     Send a file"
    echo "  -c, --clipboard         Send current clipboard contents"
    echo "      --path              Send current working directory path"
    echo "  -h, --help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  cat 'file.txt' | s2gram.sh"
    echo "  s2gram.sh -t \"this is my text\""
    echo "  s2gram.sh -f file.ext"
    echo "  s2gram.sh -c"
    echo "  s2gram.sh --path"
}

echo "$FIGLET_ART"
echo " "
if [[ -p /dev/stdin ]]; then
    input=$(cat)
    send_telegram_message "$input"
else
    if [[ $# -eq 0 ]]; then
        show_help
        exit 1
    fi

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -t|--text)
                if [[ -n "$2" ]]; then
                    send_telegram_message "$2"
                    shift
                else
                    echo "Error: Missing argument for -t|--text option."
                    exit 1
                fi
                ;;
            -f|--file)
                if [[ -n "$2" ]]; then
                    send_telegram_file "$2"
                    shift
                else
                    echo "Error: Missing argument for -f|--file option."
                    exit 1
                fi
                ;;
            -c|--clipboard)
                clipboard_content=$(get_clipboard_content)
                if [[ -n "$clipboard_content" ]]; then
                    send_telegram_message "$clipboard_content"
                else
                    echo "Error: Clipboard is empty."
                    exit 1
                fi
                ;;
            --path)
                current_path=$(pwd)
                send_telegram_message "Current Path: $current_path"
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                echo "Error: Invalid option '$1'."
                show_help
                exit 1
                ;;
        esac
        shift
    done
fi

exit 0
