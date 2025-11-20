#!/bin/bash

socat -v TCP-LISTEN:${PORT},fork TCP-CONNECT:${ORIGIN_HOST}:${ORIGIN_PORT} 2>&1 | tee -a ${LOGS_DIR}