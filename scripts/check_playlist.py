import spotipy
from spotipy.oauth2 import SpotifyOAuth
from dotenv import load_dotenv

load_dotenv()

sp = spotipy.Spotify(auth_manager=SpotifyOAuth(scope='playlist-read-private playlist-read-collaborative'))

# Get all user playlists
print("Fetching all playlists...")
results = sp.current_user_playlists(limit=50)
playlists = results['items']
while results['next']:
    results = sp.next(results)
    playlists.extend(results['items'])

# Find the specific playlist
target_name = "A&R - Unsigned Male Rappers to Track [2026]"
print(f"\nLooking for: '{target_name}'")
print(f"Total playlists: {len(playlists)}")

found = False
for p in playlists:
    if target_name.lower() in p['name'].lower() or 'unsigned male rapper' in p['name'].lower():
        print(f"\nFound similar: '{p['name']}'")
        print(f"  ID: {p['id']}")
        if p['name'] == target_name:
            print("  ✓ EXACT MATCH!")
            found = True
        
if not found:
    print(f"\n❌ Exact match NOT found for '{target_name}'")
    print("\nAll A&R playlists:")
    ar_playlists = [p for p in playlists if 'A&R' in p['name']]
    for p in ar_playlists:
        print(f"  - {p['name']}")
