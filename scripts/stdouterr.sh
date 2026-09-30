#!/usr/bin/env bash
# TODO: Limitation: it sets the program to be non-TTY, which means some output
# is hidden in programs that conditionally show/hide some output when it's a
# TTY vs non-TTY.

# Exit immediately if no command is provided
if [ "$#" -eq 0 ]; then
  echo "Usage: stdouterr <command> [args...]" >&2
  exit 1
fi

# Create a temporary directory for named pipes (FIFOs)
TMP_DIR=$(mktemp -d)

# Cleanup named pipes and temporary directory on exit/interrupt
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT INT TERM

# Define FIFO paths
STDOUT_FIFO="$TMP_DIR/stdout"
STDERR_FIFO="$TMP_DIR/stderr"

mkfifo "$STDOUT_FIFO" "$STDERR_FIFO"

# Run GNU Parallel reading from FIFOs in the background.
# --linebuffer: Output immediately line by line without buffering entire streams.
# --tagstring: Label each line with [stdout] or [stderr].
# --colsep: Parse the input as TAB-separated (tag<TAB>FIFO_path).
# cat (rather than tail -f) sees EOF as soon as the command closes the FIFO,
# so the jobs end on their own when the command finishes.
parallel --linebuffer --colsep '\t' --tagstring '{1}' 'cat {2}' ::: \
  "[stdout]"$'\t'"$STDOUT_FIFO" \
  "[stderr]"$'\t'"$STDERR_FIFO" &
PARALLEL_PID=$!

# Run the command, sending stdout and stderr into the respective FIFOs
"$@" >"$STDOUT_FIFO" 2>"$STDERR_FIFO"
EXIT_CODE=$?

# Wait for GNU Parallel to finish flushing remaining lines
wait $PARALLEL_PID

exit $EXIT_CODE
