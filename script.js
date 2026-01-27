// State
let currentTrack = null;
let allPlaylists = [];
let activePlaylistsMap = new Set(); // Set of Playlist IDs that contain the current track


document.addEventListener('DOMContentLoaded', () => {
    document.addEventListener('visibilitychange', handleVisibilityChange);
    init();
});

function handleVisibilityChange() {
    if (document.hidden) {
        console.log("Tab hidden, slowing down polling to 60s");
        pollInterval = 60000;
    } else {
        console.log("Tab visible, restoring polling to 10s");
        pollInterval = 10000;
        // Optional: Trigger immediate update if needed, but let's just let the next poll cycle handle it or rely on the shorter interval
        // pollCurrentTrack(); // Careful not to create double loops
    }
}

async function init() {
    // 1. Fetch initial Playlists (Static info)
    await fetchPlaylists();
    
    // 2. Start Polling for Current Track
    pollCurrentTrack();
}

async function fetchPlaylists() {
    try {
        const isTracker = document.body.classList.contains('tracker-page');
        const endpoint = isTracker ? '/api/tracker-playlists' : '/api/playlists';
        
        const res = await fetch(endpoint);
        
        if (res.status === 429) {
            console.warn("Playlists fetch rate limited, retrying in 5s...");
            document.getElementById('playlist-grid').innerHTML = '<div style="color:white; padding:20px;">Spotify is rate limiting us... waiting 5s to retry.</div>';
            setTimeout(fetchPlaylists, 5000);
            return;
        }

        if (!res.ok) throw new Error(`Failed to fetch playlists: ${res.status}`);
        
        allPlaylists = await res.json();
        
        if (allPlaylists.length === 0) {
            console.warn("Warning: Received 0 playlists");
            document.getElementById('playlist-grid').innerHTML = '<div style="color:white; padding:20px;">No playlists found. Check backend logs.</div>';
        } else {
            // Render immediately (all inactive initially) for speed
            renderPlaylists();
        }
    } catch (e) {
        console.error("Error in fetchPlaylists:", e);
        document.getElementById('artist-name').textContent = "Error loading playlists: " + e.message;
    }
}



let pollInterval = 10000;
let consecutiveErrors = 0;

async function pollCurrentTrack() {
    try {
        const res = await fetch('/api/current-track');
        
        if (res.status === 429) {
            const data = await res.json();
            const retryAfter = data.retry_after || 5;
            
            
            console.warn(`Rate limited, Retry-After: ${retryAfter}s`);
            const trackTitleEl = document.getElementById('track-title') || document.getElementById('track-name');
            if (trackTitleEl) trackTitleEl.textContent = "Spotify Rate Limited";
            
            // Start Countdown
            let timeLeft = retryAfter;
            document.getElementById('artist-name').textContent = `Retrying in ${timeLeft}s...`;
            
            const countdownInterval = setInterval(() => {
                timeLeft--;
                if (timeLeft > 0) {
                    document.getElementById('artist-name').textContent = `Retrying in ${timeLeft}s...`;
                } else {
                    clearInterval(countdownInterval);
                }
            }, 1000);

            // Set next poll
            pollInterval = (retryAfter * 1000) + 500; // Add buffer
            
        } else if (res.status === 200) {
            consecutiveErrors = 0;
            pollInterval = 10000; // Reset to 10s
            
            const track = await res.json();
            if (track) {
                const idChanged = !currentTrack || currentTrack.id !== track.id;
                const statusChanged = !currentTrack || currentTrack.is_playing !== track.is_playing;

                if (idChanged || statusChanged) {
                    currentTrack = track;
                    updateTrackInfo(track);
                    if (idChanged) {
                         try {
                            // Optimistically render to ensure headers/visuals are right, 
                            // checks will come later
                            renderPlaylists();
                            await checkPlaylists(track.uri);
                        } catch (err) {
                            console.error("Error checking playlists:", err);
                        }
                    }
                }
            } else {
                updateTrackInfo(null);
            }
        } else {
             // Other errors (500, etc)
             consecutiveErrors++;
             pollInterval = Math.min(pollInterval * 1.5, 30000); 
        }
    } catch (e) {
        console.error("Polling error:", e);
        consecutiveErrors++;
        pollInterval = Math.min(pollInterval * 1.5, 30000);
    }
    
    setTimeout(pollCurrentTrack, pollInterval);
}


async function checkPlaylists(trackUri) {
    try {
        const res = await fetch(`/api/check-playlists?track_uri=${encodeURIComponent(trackUri)}`);
        if (res.ok) {
            const activeIds = await res.json();
            activePlaylistsMap = new Set(activeIds);
            renderPlaylists();
        }
    } catch (e) {
        console.error("Error checking playlists:", e);
    }
}

function updateTrackInfo(track) {
    const title = document.getElementById('track-title');
    const artist = document.getElementById('artist-name');
    const visualizerBars = document.querySelectorAll('.bar');
    const nothingPlayingMsg = document.getElementById('nothing-playing');
    
    if (track) {
        title.textContent = track.name;
        artist.textContent = track.artist;
        
        if (track.is_playing) {
            visualizerBars.forEach(b => b.style.display = 'block');
            nothingPlayingMsg.style.display = 'none';
        } else {
            visualizerBars.forEach(b => b.style.display = 'none');
            nothingPlayingMsg.style.display = 'block';
        }
    } else {
        title.textContent = "Not Playing";
        artist.textContent = "Play a song on Spotify";
        visualizerBars.forEach(b => b.style.display = 'none');
        nothingPlayingMsg.style.display = 'block';
        activePlaylistsMap.clear();
        renderPlaylists();
    }
}

function renderPlaylists() {
    const grid = document.getElementById('playlist-grid');
    grid.innerHTML = '';
    
    const isTracker = document.body.classList.contains('tracker-page');

    // Helper to create item
    const createItem = (playlist) => {
        // Handle DIVIDER for Tracker
        if (isTracker && playlist.is_divider) {
            const div = document.createElement('div');
            div.className = 'section-divider-green';
            return div;
        }

        const isActive = activePlaylistsMap.has(playlist.id);
        
        const item = document.createElement('div');
        item.className = `playlist-item ${isActive ? 'active' : ''}`;
        
        // Use ID for toggling
        item.onclick = () => togglePlaylist(playlist);

        const nameSpan = document.createElement('span');
        nameSpan.className = 'playlist-name';
        nameSpan.textContent = playlist.name;

        item.appendChild(nameSpan);

        // Status Indicator (Checkmark)
        const indicator = document.createElement('div');
        indicator.className = 'status-indicator';
        indicator.innerHTML = '<svg viewBox="0 0 24 24"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>';
        item.appendChild(indicator);

        return item;
    };

    if (isTracker) {
        // Tracker Logic: Linear Rendering, Strict Order
        const trackerGroup = document.createElement('div');
        trackerGroup.className = 'tracker-list'; // We might need css for this, but column is default
        trackerGroup.style.display = 'flex';
        trackerGroup.style.flexDirection = 'column';
        trackerGroup.style.gap = '8px';
        
        allPlaylists.forEach(p => {
             trackerGroup.appendChild(createItem(p));
        });
        grid.appendChild(trackerGroup);

    } else {
        // Standard Dashboard Logic: Split Active/Inactive
        
        // Map state to playlists locally for sorting
        const playlistsWithState = allPlaylists.map(p => ({
            ...p,
            isActive: activePlaylistsMap.has(p.id)
        }));

        const activePlaylists = playlistsWithState.filter(p => p.isActive).sort((a, b) => a.name.localeCompare(b.name));
        const inactivePlaylists = playlistsWithState.filter(p => !p.isActive).sort((a, b) => a.name.localeCompare(b.name));

        // Render Active Group (Column Layout)
        if (activePlaylists.length > 0) {
            const activeGroup = document.createElement('div');
            activeGroup.className = 'active-group';
            activePlaylists.forEach(p => activeGroup.appendChild(createItem(p)));
            grid.appendChild(activeGroup);
        }

        // Divider
        if (activePlaylists.length > 0 && inactivePlaylists.length > 0) {
            const divider = document.createElement('div');
            divider.className = 'playlist-divider';
            grid.appendChild(divider);
        }

        // Render Inactive Group (Column Layout)
        if (inactivePlaylists.length > 0) {
            const inactiveGroup = document.createElement('div');
            inactiveGroup.className = 'inactive-group';
            inactivePlaylists.forEach(p => inactiveGroup.appendChild(createItem(p)));
            grid.appendChild(inactiveGroup);
        }
    }
}

async function togglePlaylist(playlist) {
    if (!currentTrack) return;

    const isCurrentlyActive = activePlaylistsMap.has(playlist.id);
    const action = isCurrentlyActive ? 'remove' : 'add';

    // Optimistic Update
    if (action === 'add') {
        activePlaylistsMap.add(playlist.id);
    } else {
        activePlaylistsMap.delete(playlist.id);
    }

    // Copy Spotify Playlist Name to Clipboard (on Add OR Remove)
    if (playlist.spotify_name) {
        navigator.clipboard.writeText(playlist.spotify_name).catch(err => {
            console.error('Failed to copy text: ', err);
        });
    }
    renderPlaylists();

    try {
        const res = await fetch('/api/playlist/toggle', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                playlist_id: playlist.id,
                track_uri: currentTrack.uri,
                action: action
            })
        });
        
        const data = await res.json();
        if (!data.success) {
            console.error("Failed to toggle:", data.error);
            // Revert on failure
            if (action === 'add') activePlaylistsMap.delete(playlist.id);
            else activePlaylistsMap.add(playlist.id);
            renderPlaylists();
            alert("Failed to update playlist: " + data.error);
        }
    } catch (e) {
        console.error("Error toggling:", e);
        // Revert on failure
        if (action === 'add') activePlaylistsMap.delete(playlist.id);
        else activePlaylistsMap.add(playlist.id);
        renderPlaylists();
        alert("Network error.");
    }
}

