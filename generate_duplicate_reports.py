import spotipy
from spotipy.oauth2 import SpotifyOAuth
from dotenv import load_dotenv
import csv

load_dotenv()

sp = spotipy.Spotify(auth_manager=SpotifyOAuth(scope='playlist-read-private playlist-read-collaborative'))

# Get all user playlists
print("Fetching all playlists...")
results = sp.current_user_playlists(limit=50)
playlists = results['items']
while results['next']:
    results = sp.next(results)
    playlists.extend(results['items'])

print(f"Total playlists: {len(playlists)}\n")

# Create a map of playlist names to their IDs
playlist_name_map = {}
for p in playlists:
    name = p['name']
    if name not in playlist_name_map:
        playlist_name_map[name] = []
    playlist_name_map[name].append(p['id'])

# Find duplicates
duplicates = {name: ids for name, ids in playlist_name_map.items() if len(ids) > 1}

# Process each CSV file
csv_configs = [
    {
        "input_file": "Playlists to Display.csv",
        "output_file": "Playlists Duplicates.csv",
        "dashboard_col": "Dashboard Name",
        "spotify_col": "Spotify Playlist Name"
    },
    {
        "input_file": "Tracker to Display.csv",
        "output_file": "Tracker Duplicates.csv",
        "dashboard_col": "Dashboard Name",
        "spotify_col": "Spotify Playlist Name"
    }
]

for config in csv_configs:
    print(f"\nProcessing {config['input_file']}...")
    
    try:
        with open(config['input_file'], 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            issues_found = []
            
            for row in reader:
                spotify_name = row.get(config['spotify_col'], "").strip()
                
                # Skip dividers
                if spotify_name in ["DIVIDER", "LINE BREAK"]:
                    continue
                
                # Check if this playlist has duplicates
                if spotify_name in duplicates:
                    dashboard_name = row.get(config['dashboard_col'], "").strip()
                    duplicate_ids = duplicates[spotify_name]
                    
                    # Create a row with all duplicate IDs
                    issue_row = {
                        "Dashboard Name": dashboard_name,
                        "Spotify Playlist Name": spotify_name,
                        "Number of Duplicates": len(duplicate_ids)
                    }
                    
                    # Add each duplicate as a separate column
                    for i, pid in enumerate(duplicate_ids, 1):
                        issue_row[f"Playlist ID {i}"] = pid
                        issue_row[f"Playlist URL {i}"] = f"https://open.spotify.com/playlist/{pid}"
                    
                    issues_found.append(issue_row)
        
        if issues_found:
            # Write to output CSV
            with open(config['output_file'], 'w', newline='', encoding='utf-8') as f:
                # Determine fieldnames based on max number of duplicates
                max_duplicates = max(row['Number of Duplicates'] for row in issues_found)
                fieldnames = ["Dashboard Name", "Spotify Playlist Name", "Number of Duplicates"]
                for i in range(1, max_duplicates + 1):
                    fieldnames.append(f"Playlist ID {i}")
                    fieldnames.append(f"Playlist URL {i}")
                
                writer = csv.DictWriter(f, fieldnames=fieldnames)
                writer.writeheader()
                writer.writerows(issues_found)
            
            print(f"  ✅ Created {config['output_file']} with {len(issues_found)} duplicate issues")
        else:
            print(f"  ℹ️  No duplicates found, skipping {config['output_file']}")
            
    except Exception as e:
        print(f"  ❌ Error processing {config['input_file']}: {e}")

print("\n✅ Done!")
