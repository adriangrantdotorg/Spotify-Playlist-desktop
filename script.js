// State
let currentTrack = null;
let allPlaylists = [];
let activePlaylistsMap = new Set(); // Set of Playlist IDs that contain the current track


document.addEventListener('DOMContentLoaded', () => {
    init();
});

async function init() {
    // 1. Fetch initial Playlists (Static info)
    await fetchPlaylists();
    
    // 2. Start Polling for Current Track
    pollCurrentTrack();
    setInterval(pollCurrentTrack, 10000); // Poll every 10 seconds
}

async function fetchPlaylists() {
    try {
        const res = await fetch('/api/playlists');
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


async function pollCurrentTrack() {
    try {
        const res = await fetch('/api/current-track');
        if (res.status === 200) {
            const track = await res.json();
            if (track) {
                const idChanged = !currentTrack || currentTrack.id !== track.id;
                const statusChanged = !currentTrack || currentTrack.is_playing !== track.is_playing;

                if (idChanged || statusChanged) {
                    currentTrack = track;
                    updateTrackInfo(track);
                    if (idChanged) {
                        // Optimistically render to ensure headers/visuals are right, 
                        // checks will come later
                        renderPlaylists();
                        await checkPlaylists(track.uri);
                    }
                }
            } else {
                updateTrackInfo(null);
            }
        }
    } catch (e) {
        console.error("Polling error:", e);
    }
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

    // Map state to playlists
    const playlistsWithState = allPlaylists.map(p => ({
        ...p,
        isActive: activePlaylistsMap.has(p.id)
    }));

    // Split into active and inactive
    const activePlaylists = playlistsWithState.filter(p => p.isActive).sort((a, b) => a.name.localeCompare(b.name));
    const inactivePlaylists = playlistsWithState.filter(p => !p.isActive).sort((a, b) => a.name.localeCompare(b.name));

    // Helper to create item
    const createItem = (playlist) => {
        const item = document.createElement('div');
        item.className = `playlist-item ${playlist.isActive ? 'active' : ''}`;
        
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

