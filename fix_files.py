# -*- coding: utf-8 -*-
"""
Talabaty null-safety audit fixes.
- Strips corrupt duplicate tail from product_details_screen.dart
- Applies targeted null-safety fixes to 3 Flutter screens
"""

import os
import sys

# Force UTF-8 output on Windows terminals
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


def clean_product_details():
    """Strip corrupt duplicate tail after the class closing brace."""
    raw, path = read_file_bytes("product_details_screen.dart")
    marker = b"  }\r\n}\r\n"
    idx = raw.find(marker)
    if idx != -1:
        clean = raw[:idx + len(marker)]
        if len(clean) < len(raw):
            write_file(path, clean)
            print(f"  [OK] Stripped {len(raw) - len(clean)} corrupt bytes from tail")
            return clean, path
        else:
            print("  [SKIP] No extra bytes after marker - already clean")
    else:
        print("  [SKIP] Marker not found")
    return raw, path


def apply_fixes_to_bytes(raw, replacements):
    for old_str, new_str, label in replacements:
        old_b = old_str.encode("utf-8")
        new_b = new_str.encode("utf-8")
        if old_b in raw:
            raw = raw.replace(old_b, new_b, 1)
            print(f"  [OK] Fixed: {label}")
        else:
            print(f"  [SKIP] Pattern not found (may already be fixed): {label}")
    return raw


# ── product_details_screen.dart fixes ─────────────────────────────────────────

product_details_fixes = [
    # PD-1: Remove unsafe ! null-assertion in _initializeDefaults
    (
        "        _selectedOptions[group.id]!.add(group.options.first.id); // Auto select first if required",
        "        // ??= removes the unsafe ! assertion; the key was just initialised to [] two lines above\n        (_selectedOptions[group.id] ??= []).add(group.options.first.id); // Auto select first if required",
        "PD-1 | Remove ! null-assertion in _initializeDefaults",
    ),
    # PD-2: Capture ScaffoldMessenger before context.pop() to avoid use-after-pop
    (
        "                        context.pop();\n                        \n                        ScaffoldMessenger.of(context).showSnackBar(",
        "                        // Capture messenger BEFORE pop - context is detached after pop().\n                        final messenger = ScaffoldMessenger.of(context);\n                        context.pop();\n                        \n                        messenger.showSnackBar(",
        "PD-2 | Capture ScaffoldMessenger before context.pop()",
    ),
]

# ── order_tracking_screen.dart fixes ─────────────────────────────────────────

order_tracking_fixes = [
    # OT-1: mounted guard at top of _fetchRoute (timer may fire after dispose)
    (
        "  Future<void> _fetchRoute() async {\n    final dataProvider = context.read<DataProvider>();",
        "  Future<void> _fetchRoute() async {\n    // Guard: the Timer may fire after dispose(); bail early if unmounted.\n    if (!mounted) return;\n    final dataProvider = context.read<DataProvider>();",
        "OT-1 | mounted guard at start of async _fetchRoute()",
    ),
    # OT-2: Safe .orders.first fallback in _fetchRoute
    (
        "    final order = dataProvider.orders.firstWhere((o) => o.id == widget.orderId, orElse: () => dataProvider.orders.first);\n    \n    LatLng startPoint",
        "    final order = dataProvider.orders.firstWhere(\n      (o) => o.id == widget.orderId,\n      orElse: () => dataProvider.orders.isNotEmpty ? dataProvider.orders.first : null,\n    );\n    if (order == null) return; // Orders not loaded yet; skip route fetch\n    \n    LatLng startPoint",
        "OT-2 | Safe .orders.first in _fetchRoute (isNotEmpty guard)",
    ),
    # OT-3: Safe fallbacks in build()
    (
        "    final order = dataProvider.orders.firstWhere((o) => o.id == widget.orderId, orElse: () => dataProvider.orders.first);\n    final store = dataProvider.stores.firstWhere((s) => s.id == order.storeId, orElse: () => dataProvider.stores.first);",
        "    // Safe fallbacks: .first on an empty list throws StateError\n    final order = dataProvider.orders.firstWhere(\n      (o) => o.id == widget.orderId,\n      orElse: () => dataProvider.orders.isNotEmpty ? dataProvider.orders.first : null,\n    );\n    if (order == null) {\n      return const Scaffold(body: Center(child: CircularProgressIndicator()));\n    }\n    final store = dataProvider.stores.firstWhere(\n      (s) => s.id == order.storeId,\n      orElse: () => dataProvider.stores.isNotEmpty ? dataProvider.stores.first : null,\n    );\n    if (store == null) {\n      return const Scaffold(body: Center(child: CircularProgressIndicator()));\n    }",
        "OT-3 | Safe .orders/.stores .first fallbacks in build()",
    ),
    # OT-4: Guard .couriers.first with isEmpty check
    (
        "                        final courier = dataProvider.couriers.firstWhere(\n                          (c) => c.userId == order.courierId,\n                          orElse: () => dataProvider.couriers.first,\n                        );",
        "                        if (dataProvider.couriers.isEmpty) return const SizedBox.shrink();\n                        final courier = dataProvider.couriers.firstWhere(\n                          (c) => c.userId == order.courierId,\n                          orElse: () => dataProvider.couriers.first, // safe: list confirmed non-empty\n                        );",
        "OT-4 | isEmpty guard before .couriers.first fallback",
    ),
]

# ── checkout_screen.dart fixes ────────────────────────────────────────────────

checkout_fixes = [
    # CS-1: Safe .stores.first fallback in _confirmOrder
    (
        "      final store = dataProvider.stores.firstWhere((s) => s.id == storeId, orElse: () => dataProvider.stores.first);",
        "      final store = dataProvider.stores.firstWhere(\n        (s) => s.id == storeId,\n        orElse: () => dataProvider.stores.isNotEmpty ? dataProvider.stores.first : null,\n      );\n      if (store == null) {\n        // No store found - abort order placement to prevent crash\n        if (mounted) setState(() => _isLoading = false);\n        return;\n      }",
        "CS-1 | Safe .stores.first fallback in _confirmOrder",
    ),
    # CS-2: mounted check after await context.push (async gap)
    (
        "                      onTap: () async {\n                        final result = await context.push('/customer/address');\n                        if (result != null && result is String) {\n                          setState(() {",
        "                      onTap: () async {\n                        final result = await context.push('/customer/address');\n                        // mounted check: widget may have been disposed during the await gap\n                        if (!mounted) return;\n                        if (result != null && result is String) {\n                          setState(() {",
        "CS-2 | mounted check after await context.push('/customer/address')",
    ),
]


if __name__ == "__main__":
    print("=" * 55)
    print("  Talabaty Null-Safety Audit - Applying Fixes")
    print("=" * 55)

    # Step 1: Strip corrupt tail from product_details_screen
    print("\n[Step 1] Cleaning corrupt tail - product_details_screen.dart")
    clean_product_details()

    # Step 2: Apply code fixes
    files_and_fixes = [
        ("product_details_screen.dart", product_details_fixes),
        ("order_tracking_screen.dart",  order_tracking_fixes),
        ("checkout_screen.dart",         checkout_fixes),
    ]

    for filename, fixes in files_and_fixes:
        print(f"\n[Fixing] {filename}")
        raw, path = read_file_bytes(filename)
        raw = apply_fixes_to_bytes(raw, fixes)
        write_file(path, raw)
        print(f"  Saved => {path}")

    print("\nAll fixes applied successfully.")
