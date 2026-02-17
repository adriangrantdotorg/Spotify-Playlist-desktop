-- Toggle Spotify Dashboard visibility (Playlists page)
-- If visible on Playlists page -> hides
-- If hidden or on another page -> shows Playlists page

tell application "Spotify Dashboard"
    toggle page "playlist"
end tell
