# -*- coding: utf-8 -*-
"""
Talabaty null-safety audit fixes - Part 2
Applies the two remaining fixes that use CRLF line endings.
"""

import os
import sys

sys.stdout.reconfigure(encoding="utf-8")

BASE = os.path.join("lib", "features", "customer", "screens")


def read_file_bytes(filename):
    path = os.path.join(BASE, filename)
    with open(path, "rb") as f:
        raw = f.read()
    return raw, path


def write_file(path, raw_bytes):
    with open(path, "wb") as f:
        f.write(raw_bytes)


def apply_fix(raw, old_str, new_str, label):
    old_b = old_str.encode("utf-8")
    new_b = new_str.encode("utf-8")
    if old_b in raw:
        raw = raw.replace(old_b, new_b, 1)
        print(f"  [OK] Fixed: {label}")
    else:
        print(f"  [SKIP] Pattern not matched: {label}")
    return raw


CRLF = "\r\n"
C = CRLF  # shorthand


# ── PD-2: product_details_screen.dart ────────────────────────────────────────
# Fix: capture ScaffoldMessenger BEFORE context.pop() to avoid using
# a detached BuildContext after navigation.

PD2_OLD = (
    f"                        context.pop();{C}"
    f"                        {C}"
    f"                        ScaffoldMessenger.of(context).showSnackBar("
)
PD2_NEW = (
    f"                        // Capture messenger BEFORE pop - context is detached after pop().{C}"
    f"                        final messenger = ScaffoldMessenger.of(context);{C}"
    f"                        context.pop();{C}"
    f"                        {C}"
    f"                        messenger.showSnackBar("
)

# ── CS-2: checkout_screen.dart ────────────────────────────────────────────────
# Fix: mounted check after await context.push (async gap before setState)

CS2_OLD = (
    f"                      onTap: () async {{{C}"
    f"                        final result = await context.push('/customer/address');{C}"
    f"                        if (result != null && result is String) {{{C}"
    f"                          setState(() {{"
)
CS2_NEW = (
    f"                      onTap: () async {{{C}"
    f"                        final result = await context.push('/customer/address');{C}"
    f"                        // mounted check: widget may have been disposed during await gap{C}"
    f"                        if (!mounted) return;{C}"
    f"                        if (result != null && result is String) {{{C}"
    f"                          setState(() {{"
)


if __name__ == "__main__":
    print("=" * 55)
    print("  Talabaty Fixes - Part 2 (CRLF-aware patterns)")
    print("=" * 55)

    # ── product_details_screen.dart: PD-2 ──
    print("\n[Fixing] product_details_screen.dart")
    raw, path = read_file_bytes("product_details_screen.dart")
    raw = apply_fix(raw, PD2_OLD, PD2_NEW, "PD-2 | Capture ScaffoldMessenger before context.pop()")
    write_file(path, raw)
    print(f"  Saved => {path}")

    # ── checkout_screen.dart: CS-2 ──
    print("\n[Fixing] checkout_screen.dart")
    raw, path = read_file_bytes("checkout_screen.dart")
    raw = apply_fix(raw, CS2_OLD, CS2_NEW, "CS-2 | mounted check after await context.push")
    write_file(path, raw)
    print(f"  Saved => {path}")

    print("\nPart 2 fixes applied.")
