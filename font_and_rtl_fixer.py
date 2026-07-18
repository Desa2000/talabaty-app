import os
import re

def fix_file(filepath, font_replacements=True, rtl_replacements=None):
    if not os.path.exists(filepath):
        print(f"File not found: {filepath}")
        return
    
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
        
    original = content
    
    # 1. Font replacements
    if font_replacements:
        # replace GoogleFonts.outfit( with GoogleFonts.cairo(
        content = content.replace("GoogleFonts.outfit(", "GoogleFonts.cairo(")
        content = content.replace("GoogleFonts.inter(", "GoogleFonts.cairo(")
        # replace 'Outfit' and 'Inter' with 'Cairo'
        content = content.replace("'Outfit'", "'Cairo'")
        content = content.replace("'Inter'", "'Cairo'")
        content = content.replace('"Outfit"', '"Cairo"')
        content = content.replace('"Inter"', '"Cairo"')
        
        # Remove letterSpacing: ... inside cairo/Cairo texts where appropriate
        # but wait, let's do a simple regex for letterSpacing in GoogleFonts.cairo or TextStyle with Cairo
        content = re.sub(r'letterSpacing:\s*[-+]?\d*\.?\d+,?\s*', '', content)

    # 2. RTL replacements (Back buttons and chevrons)
    if rtl_replacements:
        imports_added = False
        import_path = rtl_replacements.get('import_path')
        
        # Add import if not present
        if import_path and import_path not in content:
            # Insert after the first import or at the top
            lines = content.split('\n')
            for i, line in enumerate(lines):
                if line.startswith('import '):
                    lines.insert(i, f"import '{import_path}';")
                    content = '\n'.join(lines)
                    imports_added = True
                    break
        
        # Replace back buttons/chevrons
        replacements = rtl_replacements.get('replacements', [])
        for old, new in replacements:
            content = content.replace(old, new)
            
    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Fixed: {filepath}")
    else:
        print(f"No changes: {filepath}")

# Define file paths and their fixes
app_dir = r"C:\Users\HP\.gemini\antigravity\scratch\talabaty_app"

# 1. OTP Screen
fix_file(
    os.path.join(app_dir, "lib/features/auth/screens/otp_screen.dart"),
    font_replacements=True,
    rtl_replacements={
        'import_path': '../../../core/utils/directional_extensions.dart',
        'replacements': [
            (
                'const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 20)',
                'Icon(context.backIcon, color: AppColors.textPrimary, size: 20)'
            ),
            (
                'const Icon(Icons.arrow_back, color: Colors.black)',
                'Icon(context.backIcon, color: Colors.black)'
            )
        ]
    }
)

# 2. Customer Home Screen
fix_file(
    os.path.join(app_dir, "lib/features/customer/screens/customer_home_screen.dart"),
    font_replacements=True,
    rtl_replacements={
        'import_path': '../../../core/utils/directional_extensions.dart',
        'replacements': [
            (
                'const Row(\n                  children: [\n                    Text(\n                      \'عرض الكل\',',
                'Row(\n                  children: [\n                    Text(\n                      \'عرض الكل\','
            ),
            (
                'Icon(Icons.chevron_right_rounded, color: AppColors.primaryColor, size: 20)',
                'Icon(context.chevronRight, color: AppColors.primaryColor, size: 20)'
            )
        ]
    }
)

# 3. Store Details Screen
fix_file(
    os.path.join(app_dir, "lib/features/customer/screens/store_details_screen.dart"),
    font_replacements=True,
    rtl_replacements={
        'import_path': '../../../core/utils/directional_extensions.dart',
        'replacements': [
            (
                'const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20)',
                'Icon(context.backIcon, color: Colors.white, size: 20)'
            )
        ]
    }
)

# 4. Courier Profile Tab
fix_file(
    os.path.join(app_dir, "lib/features/courier/screens/tabs/courier_profile_tab.dart"),
    font_replacements=False,
    rtl_replacements={
        'import_path': '../../../../core/utils/directional_extensions.dart',
        'replacements': [
            (
                'const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)',
                'Icon(context.forwardIconIos, size: 16, color: Colors.grey)'
            )
        ]
    }
)

# 5. Checkout Screen
fix_file(
    os.path.join(app_dir, "lib/features/customer/screens/checkout_screen.dart"),
    font_replacements=False,
    rtl_replacements={
        'import_path': '../../../core/utils/directional_extensions.dart',
        'replacements': [
            (
                'const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary)',
                'Icon(context.forwardIconIos, size: 16, color: AppColors.textSecondary)'
            )
        ]
    }
)

# 6. Profile Screen
fix_file(
    os.path.join(app_dir, "lib/features/customer/screens/profile_screen.dart"),
    font_replacements=False,
    rtl_replacements={
        'import_path': '../../../core/utils/directional_extensions.dart',
        'replacements': [
            (
                'Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400)',
                'Icon(context.forwardIconIos, size: 16, color: Colors.grey.shade400)'
            )
        ]
    }
)

# 7. Search Screen
fix_file(
    os.path.join(app_dir, "lib/features/customer/screens/search_screen.dart"),
    font_replacements=False,
    rtl_replacements={
        'import_path': '../../../core/utils/directional_extensions.dart',
        'replacements': [
            (
                'const Padding(\n              padding: EdgeInsets.symmetric(horizontal: 16),\n              child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),\n            )',
                'Padding(\n              padding: const EdgeInsets.symmetric(horizontal: 16),\n              child: Icon(context.forwardIconIos, size: 16, color: Colors.grey),\n            )'
            )
        ]
    }
)

# 8. Settings Screen
fix_file(
    os.path.join(app_dir, "lib/features/customer/screens/settings_screen.dart"),
    font_replacements=False,
    rtl_replacements={
        'import_path': '../../../core/utils/directional_extensions.dart',
        'replacements': [
            (
                'Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400)',
                'Icon(context.forwardIconIos, size: 16, color: Colors.grey.shade400)'
            )
        ]
    }
)

# 9. Merchant Settings Tab
fix_file(
    os.path.join(app_dir, "lib/features/merchant/screens/tabs/merchant_settings_tab.dart"),
    font_replacements=True,
    rtl_replacements={
        'import_path': '../../../../core/utils/directional_extensions.dart',
        'replacements': [
            (
                'const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey)',
                'Icon(context.forwardIconIos, size: 16, color: Colors.grey)'
            )
        ]
    }
)

# 10. Order Tracking Screen
fix_file(
    os.path.join(app_dir, "lib/features/customer/screens/order_tracking_screen.dart"),
    font_replacements=True,
    rtl_replacements=None
)
