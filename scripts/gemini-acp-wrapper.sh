#!/bin/bash
# Wrapper script for gemini --experimental-acp
# The debug output from gemini goes to stdout which breaks ACP JSON-RPC.
# This wrapper uses stdbuf and awk to filter in real-time while preserving stdin.

# Use awk to filter: only print lines starting with '{'
# stdbuf ensures line-buffered output for real-time processing
exec stdbuf -oL gemini "$@" 2>/dev/null | stdbuf -oL awk '/^\{/ { print; fflush() }'
