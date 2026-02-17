-- Toggle Spotify Dashboard visibility (Tracker page)
-- If visible on Tracker page -> hides
-- If hidden or on another page -> shows Tracker page

tell application "Spotify Dashboard"
    toggle page "tracker"
end tell
