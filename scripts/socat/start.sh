#!/bin/bash

socat -v TCP-LISTEN:${PORT},fork TCP-CONNECT:${DEST_HOST}:${DEST_PORT} 2>&1 | tee -a ${LOGS_DIR}