import plistlib
import csv
import os
import html

# Path definitions
current_dir = os.path.dirname(os.path.abspath(__file__))
# XML file path relative to the script location
xml_relative_path = "Keyboard Maestro macro groups/Queues.xml"
xml_path = os.path.join(current_dir, xml_relative_path)
csv_filename = "Queue.csv"
csv_path = os.path.join(current_dir, csv_filename)

print(f"Reading XML from: {xml_path}")

try:
    with open(xml_path, 'rb') as f:
        plist_data = plistlib.load(f)

    extracted_data = []
    
    # Iterate through the top-level array items (Macro Groups)
    for item in plist_data:
        if 'Macros' in item:
            for macro in item['Macros']:
                macro_name = macro.get('Name', '')
                
                # Skip separator macros (those with just dashes)
                if '⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯' in macro_name:
                    continue
                
                playlist_text = ""
                # Find the 'InsertText' action
                actions = macro.get('Actions', [])
                for action in actions:
                    if action.get('MacroActionType') == 'InsertText':
                        playlist_text = action.get('Text', '')
                        break # Take the first InsertText action found
                
                # Only add entries that have both a name and playlist text
                if macro_name and playlist_text:
                    # Decode HTML entities in both fields
                    decoded_macro_name = html.unescape(macro_name)
                    decoded_playlist_text = html.unescape(playlist_text)
                    
                    extracted_data.append({
                        "Keyboard Maestro macro name": decoded_macro_name,
                        "Spotify Playlist Name": decoded_playlist_text
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
