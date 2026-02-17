import plistlib
import csv
import os
import re

# Path definitions
current_dir = os.path.dirname(os.path.abspath(__file__))
# XML file is in the parent directory of this script's location based on user context
# Wait, based on previous interactions, the USER is running in "Spotify Playlist app". 
# The XML file path provided in prompt was: 
# /Users/adriangrant/Library/CloudStorage/GoogleDrive-adrian.agrant@gmail.com/Other computers/My Mac mini/Synced/Dev Work/Spotify - Palette_Playlists 2025 [Bulk Add].xml
# And the workspace is:
# /Users/adriangrant/Library/CloudStorage/GoogleDrive-adrian.agrant@gmail.com/Other computers/My Mac mini/Synced/Dev Work/Spotify Playlist app
# So it IS in the parent directory ("Dev Work") relative to the workspace ("Spotify Playlist app").

xml_filename = "Spotify - Palette_Playlists 2025 [Bulk Add].xml"
xml_path = os.path.abspath(os.path.join(current_dir, "..", "data", "xml", xml_filename))
csv_filename = "Spotify Playlists.csv"
csv_path = os.path.abspath(os.path.join(current_dir, "..", "data", "csv", csv_filename))

print(f"Reading XML from: {xml_path}")

def clean_macro_name(name):
    """Removes '⌨️ ' from the beginning of the string."""
    return re.sub(r'^⌨️\s*', '', name)

try:
    with open(xml_path, 'rb') as f:
        plist_data = plistlib.load(f)

    extracted_data = []

    # root is a plist, which usually contains an array of groups for KM exports
    # Let's verify structure based on previous inspection:
    # <plist><array><dict>... this dict seems to be a macro group or list of macros
    # The 'Macros' key inside the dict holds the macros.
    
    # Iterate through the top-level array items (usually Macro Groups or just a list of items)
    for item in plist_data:
        if 'Macros' in item:
            for macro in item['Macros']:
                macro_name = macro.get('Name', '')
                clean_name = clean_macro_name(macro_name)
                
                playlist_text = ""
                # Find the 'InsertText' action
                actions = macro.get('Actions', [])
                for action in actions:
                    if action.get('MacroActionType') == 'InsertText':
                        playlist_text = action.get('Text', '')
                        break # Assume we want the first InsertText action
                
                if clean_name and playlist_text:
                    extracted_data.append({
                        "Keyboard Maestro macro name": clean_name,
                        "Spotify Playlist Name": playlist_text
                    })

    # Write to CSV
    print(f"Writing {len(extracted_data)} entries to CSV: {csv_path}")
    
    with open(csv_path, 'w', newline='', encoding='utf-8') as csvfile:
        fieldnames = ["Keyboard Maestro macro name", "Spotify Playlist Name"]
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

        writer.writeheader()
        for row in extracted_data:
            writer.writerow(row)

    print("Done.")

except FileNotFoundError:
    print(f"Error: XML file not found at {xml_path}")
except Exception as e:
    print(f"An error occurred: {e}")
