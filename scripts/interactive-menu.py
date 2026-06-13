#!/usr/bin/env python3
"""交互式菜单。UI 走 stderr，仅把最终编号写到 stdout。"""
from __future__ import annotations

import re
import sys
import termios
import tty

UI = sys.stderr
SLOT_LABEL_RE = re.compile(r"^\[(\d+)\]\s*(.*)$")


def option_label(index: int, raw: str) -> tuple[int, str]:
    match = SLOT_LABEL_RE.match(raw)
    if match:
        return int(match.group(1)), match.group(2)
    return index + 1, raw


def read_key() -> str:
    fd = sys.stdin.fileno()
    old = termios.tcgetattr(fd)
    try:
        tty.setraw(fd)
        ch = sys.stdin.read(1)
        if ch != "\x1b":
            return ch
        ch2 = sys.stdin.read(1)
        if not ch2:
            return ch
        if ch2 in ("[", "O"):
            ch3 = sys.stdin.read(1)
            return ch + ch2 + (ch3 or "")
        return ch + ch2
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old)


def draw(
    title: str,
    labels: list[tuple[int, str]],
    selected: int,
    digit_buf: str,
    prev_lines: int,
) -> int:
    if prev_lines:
        UI.write(f"\033[{prev_lines}A\033[J")
    lines: list[str] = ["", title]
    for i, (slot, text) in enumerate(labels):
        if i == selected:
            lines.append(f" \033[7m {slot:2d}) {text} \033[0m")
        else:
            lines.append(f"   {slot:2d}) {text}")
    if digit_buf:
        lines.append(f" 输入: {digit_buf} （回车确认）")
    else:
        lines.append(" (↑↓/jk 移动 · 回车确认 · 数字+回车 · 0 退出)")
    UI.write("\n".join(lines) + "\n")
    UI.flush()
    return len(lines)


def emit_choice(value: str) -> None:
    sys.stdout.write(value)
    sys.stdout.flush()


def main() -> int:
    if len(sys.argv) < 2:
        return 1
    if not sys.stdin.isatty():
        return 2

    title = sys.argv[1]
    options = sys.argv[2:]
    if not options:
        return 1

    labels = [option_label(i, raw) for i, raw in enumerate(options)]
    valid_slots = {slot for slot, _ in labels}
    selected = 0
    digit_buf = ""
    prev_lines = 0

    UI.write("\033[?25l")
    UI.flush()
    prev_lines = draw(title, labels, selected, digit_buf, prev_lines)

    try:
        while True:
            key = read_key()
            if key in ("\r", "\n"):
                if digit_buf:
                    if digit_buf == "0":
                        emit_choice("0")
                        return 0
                    if digit_buf.isdigit():
                        num = int(digit_buf)
                        if num in valid_slots:
                            emit_choice(str(num))
                            return 0
                    digit_buf = ""
                    prev_lines = draw(title, labels, selected, digit_buf, prev_lines)
                else:
                    emit_choice(str(labels[selected][0]))
                    return 0
            elif key in ("q", "Q", "\x03"):
                emit_choice("0")
                return 0
            elif key in ("\x1b[A", "\x1bOA", "k", "K"):
                digit_buf = ""
                selected = (selected - 1) % len(labels)
                prev_lines = draw(title, labels, selected, digit_buf, prev_lines)
            elif key in ("\x1b[B", "\x1bOB", "j", "J"):
                digit_buf = ""
                selected = (selected + 1) % len(labels)
                prev_lines = draw(title, labels, selected, digit_buf, prev_lines)
            elif key.isdigit():
                digit_buf += key
                prev_lines = draw(title, labels, selected, digit_buf, prev_lines)
    finally:
        UI.write("\033[?25h\n")
        UI.flush()

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
