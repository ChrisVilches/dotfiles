#!/usr/bin/env python3
import subprocess

pane_ids_result = subprocess.run(
    ["tmux", "list-panes", "-a", "-F", "#{pane_id}"], capture_output=True, encoding="utf-8")

if pane_ids_result.returncode != 0:
    raise RuntimeError(pane_ids_result.stderr)

pane_ids = pane_ids_result.stdout.split()

print(f"total: {len(pane_ids)}")

masters = []


def merge(from_idx):
    master = pane_ids[from_idx]
    masters.append(master)
    for i in range(from_idx + 1, len(pane_ids)):
        curr = pane_ids[i]

        merge_result = subprocess.run(
            ["tmux", "join-pane", "-s", curr, "-t", master], capture_output=True)

        if merge_result.returncode != 0:
            merge(i)
            break

        print(f"merged: {from_idx} <- {i}")


merge(0)

for i in masters:
    print(f"tiling {i}")
    subprocess.run(
        ["tmux", "select-layout", "-t", i, "main-vertical"])
