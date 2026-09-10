#!/usr/bin/env python3
"""Print a process tree containing every process whose full command line
contains a string, plus all of their ancestors (common branches are merged).

Usage: parents.py STRING
"""

import os
import subprocess
import sys

# Empty when the output is not a terminal, so the codes pass through harmlessly.
HIGHLIGHT = "\033[1;31m" if sys.stdout.isatty() else ""
RESET = "\033[0m" if sys.stdout.isatty() else ""


def all_processes():
    """Lists every process on the system
    Returns: dict of pid -> (ppid, args), where args is the full command line"""
    result = subprocess.run(
        ["ps", "-e", "-o", "pid=,ppid=,args="], capture_output=True, encoding="utf-8")

    if result.returncode != 0:
        raise RuntimeError(result.stderr)

    processes = {}

    for line in result.stdout.splitlines():
        fields = line.split(maxsplit=2)
        if len(fields) < 2:
            continue
        pid, ppid = int(fields[0]), int(fields[1])
        processes[pid] = (ppid, fields[2] if len(fields) > 2 else "")

    return processes


def tree_nodes(processes, needle):
    """Collects the processes matching the string together with their ancestors
    Parameters: processes - dict of pid -> (ppid, args), needle - string to look
                for in the command line
    Returns: set of pids belonging to the tree"""
    nodes = set()

    for pid, (_, args) in processes.items():
        if needle not in args:
            continue

        # Walk up to the root, stopping as soon as a known branch is reached.
        while pid in processes and pid not in nodes:
            nodes.add(pid)
            pid = processes[pid][0]

    return nodes


def highlight(args, needle):
    """Colorizes every occurrence of the needle in a command line
    Parameters: args - full command line, needle - string that was searched for
    Returns: the command line with each occurrence colorized"""
    return args.replace(needle, f"{HIGHLIGHT}{needle}{RESET}")


def print_tree(processes, nodes, needle, pid, prefix="", connector=""):
    """Prints a node and its descendants using box drawing connectors
    Parameters: processes - dict of pid -> (ppid, args), nodes - pids in the tree,
                needle - string that was searched for, pid - node to print,
                prefix - indentation for the node's children,
                connector - connector drawn before the node itself"""
    print(f"{prefix}{connector}{pid} -> {highlight(processes[pid][1], needle)}")

    children = sorted(p for p in nodes if processes[p][0] == pid and p != pid)

    if connector:
        prefix += "    " if connector == "└── " else "│   "

    for i, child in enumerate(children):
        last = i == len(children) - 1
        print_tree(processes, nodes, needle, child,
                   prefix, "└── " if last else "├── ")


def main():
    if len(sys.argv) != 2:
        print(f"usage: {os.path.basename(sys.argv[0])} STRING", file=sys.stderr)
        return 2

    needle = sys.argv[1]
    processes = all_processes()
    nodes = tree_nodes(processes, needle)

    if not nodes:
        return 1

    roots = sorted(p for p in nodes
                   if processes[p][0] not in nodes or processes[p][0] == p)

    for root in roots:
        print_tree(processes, nodes, needle, root)

    return 0


if __name__ == "__main__":
    sys.exit(main())
