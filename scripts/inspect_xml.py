import os

# Path to the XML file (sibling to current directory)
xml_file_path = os.path.abspath(os.path.join(os.getcwd(), "../Spotify - Palette_Playlists 2025 [Bulk Add].xml"))

print(f"Reading file: {xml_file_path}")

if not os.path.exists(xml_file_path):
    print("File not found!")
    exit(1)

with open(xml_file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()
    print(f"Total lines: {len(lines)}")
    print("-" * 20)
    print("First 50 lines:")
    print("".join(lines[:50]))
