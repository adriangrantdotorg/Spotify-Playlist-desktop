// Mock Data
const currentTrack = {
  title: "STAR WALKIN' (League of Legends Worlds Anthem)",
  artist: "Lil Nas X",
};

// Playlists extracted from "Playlists to Display.csv"
// Added "isActive" property to mock the state
const playlistsData = [
  { name: "Adults NSFW", isActive: false },
  { name: "Album Cuts", isActive: false },
  { name: "Beats 🥁", isActive: false },
  { name: "Best Hip Hop 🏆 Best", isActive: true }, // Mocked active
  { name: "Best Hip Hop 🏆 Faves", isActive: false },
  { name: "Best Hip Hop 🏆 Faves & Best", isActive: false },
  { name: "Best Pack Hour 🏆", isActive: false },
  { name: "Best Pop 🏆 Faves", isActive: true }, // Mocked active
  { name: "Best R&B 🏆 Best", isActive: false },
  { name: "Best R&B 🏆 Faves", isActive: false },
  { name: "Best R&B 🏆 Faves & Best", isActive: false },
  { name: "Big Tune", isActive: false },
  { name: "BZZZ___R&B", isActive: false },
  { name: "Chickens 🐔", isActive: false },
  { name: "CLUB #OBFH/ Metaverse", isActive: false },
  { name: "CLUB #OBFH/_", isActive: false },
  { name: "CLUB #OBFH/Slow", isActive: false },
  { name: "CLUB #OBFH/Trappin", isActive: false },
  { name: "Club #OBFH/Trappin/Slow", isActive: false },
  { name: "Disappointing", isActive: false },
  { name: "DX/Pack Hour", isActive: false },
  { name: "DX/Pack Hour/Slow", isActive: false },
  { name: "DX/TikTok in da Metaverse/_", isActive: true }, // Mocked active
  { name: "DX/TikTok in da Metaverse/Slow", isActive: false },
  { name: "DX/Trappin", isActive: false },
  { name: "Features", isActive: false },
  { name: "Female", isActive: false },
  { name: "Granola Backpack", isActive: false },
  { name: "Interludes", isActive: false },
  { name: "Jersey", isActive: false },
  { name: "Late Night Ride/UK Drill", isActive: false },
  { name: "Late Night/_", isActive: false },
  { name: "Late Night/420 Ridazzz", isActive: false },
  { name: "Late Night/ALL", isActive: false },
  { name: "Late Night/Granola Backpack", isActive: false },
  { name: "Late Night/Los Angeles (LA)", isActive: false },
  { name: "Late Night/Metaverse/_", isActive: false },
  { name: "Late Night/Pack Hour", isActive: false },
  { name: "Late Night/R&B", isActive: false },
  { name: "Late Night/Sexy Drill", isActive: false },
  { name: "Late Night/South", isActive: false },
  { name: "Late Night/Texas 🌵", isActive: false },
  { name: "Late Night/Trappin", isActive: false },
  { name: "Midwest", isActive: false },
  { name: "NAGA NEXT SHOW", isActive: false },
  { name: "NAGA NEXT SHOW - PACK", isActive: false },
  { name: "New Finds", isActive: false },
  { name: "NYC", isActive: false },
  { name: "Processed", isActive: false },
  { name: "Punchlines 🥊", isActive: false },
  { name: "Rains in da Metaverse", isActive: false },
  { name: "Reggae 🇯🇲", isActive: false },
  { name: "Remix - TO REMIX", isActive: false },
  { name: "Sample Flips", isActive: false },
  { name: "Sexy Drill", isActive: false },
  { name: "Snap ViRaL", isActive: false },
  { name: "SPILL", isActive: false },
  { name: "Thug Luv", isActive: false },
  { name: "Trappin/Metaverse/Slow", isActive: false },
  { name: "UK Drill", isActive: false },
  { name: "Ultra Combo", isActive: false },
  { name: "ViRaL 🦠", isActive: false },
  { name: "ViRaL 🦠 Trappin", isActive: false },
];

document.addEventListener("DOMContentLoaded", () => {
  // Set Current Track Info
  document.getElementById("track-title").textContent = currentTrack.title;
  document.getElementById("artist-name").textContent = currentTrack.artist;

  renderPlaylists();
});

function renderPlaylists() {
    const grid = document.getElementById('playlist-grid');
    grid.innerHTML = '';

    // Split into active and inactive
    const activePlaylists = playlistsData.filter(p => p.isActive).sort((a, b) => a.name.localeCompare(b.name));
    const inactivePlaylists = playlistsData.filter(p => !p.isActive).sort((a, b) => a.name.localeCompare(b.name));

    // Helper to create item
    const createItem = (playlist) => {
        const item = document.createElement('div');
        item.className = `playlist-item ${playlist.isActive ? 'active' : ''}`;
        
        // Simple click to toggle for demo purposes
        item.onclick = () => togglePlaylist(playlist.name);

        const nameSpan = document.createElement('span');
        nameSpan.className = 'playlist-name';
        nameSpan.textContent = playlist.name;

        const indicator = document.createElement('div');
        indicator.className = 'status-indicator';
        // Tick icon SVG
        indicator.innerHTML = `<svg viewBox="0 0 24 24"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>`;

        item.appendChild(nameSpan);
        item.appendChild(indicator);
        return item;
    };

    // Render Active Group
    if (activePlaylists.length > 0) {
        const activeGroup = document.createElement('div');
        activeGroup.className = 'active-group';
        activePlaylists.forEach(p => activeGroup.appendChild(createItem(p)));
        grid.appendChild(activeGroup);
    }

    // Render Divider if needed
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

function togglePlaylist(name) {
  const playlist = playlistsData.find((p) => p.name === name);
  if (playlist) {
    playlist.isActive = !playlist.isActive;
    renderPlaylists();
  }
}
