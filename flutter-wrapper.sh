#!/bin/bash

# Wrapper script để hỗ trợ "flutter create-template" command
# Cách sử dụng: Thêm vào PATH hoặc tạo alias

# Lấy đường dẫn của wrapper script
WRAPPER_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TEMPLATE_SCRIPT="$WRAPPER_DIR/create_flutter_template.sh"

# Nếu command là "create-template", chuyển sang script của chúng ta
if [ "$1" == "create-template" ]; then
    shift  # Bỏ "create-template"
    if [ -f "$TEMPLATE_SCRIPT" ]; then
        "$TEMPLATE_SCRIPT" "$@"
    else
        echo "Error: Template script not found at $TEMPLATE_SCRIPT" >&2
        exit 1
    fi
else
    # Nếu không phải, gọi flutter thật
    command flutter "$@"
fi

