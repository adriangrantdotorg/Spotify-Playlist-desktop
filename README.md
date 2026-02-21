# Spotify Playlist Dashboard

A local web dashboard that connects to your Spotify account and helps you manage playlists by showing which playlists contain your currently playing track.

## Quick Start

```bash
# Install dependencies
pip install -r requirements.txt

# Run the server
python app.py
```

Then open **http://127.0.0.1:8888** in your browser.

## Project Structure

```
├── app.py                    # Main Flask application
├── requirements.txt          # Python dependencies
│
├── data/                     # Data files
│   ├── csv/                  # Active CSV configuration files
│   │   ├── Playlists to Display.csv
│   │   ├── Tracker to Display.csv
│   │   ├── Queue to Display.csv
│   │   ├── Queue.csv
│   │   └── Tracker.csv
│   ├── xml/                  # Keyboard Maestro XML exports
│   │   ├── Queues.xml
│   │   ├── Tracker.xml
│   │   └── Spotify - Palette_Playlists 2025 [Bulk Add].xml
│   └── archived/             # Old/unused CSV files
│
├── static/                   # Frontend assets
│   ├── playlists.html        # Main playlists page
│   ├── tracker.html          # Artist tracker page
│   ├── queue.html            # Queue management page
│   ├── script.js             # Frontend JavaScript
│   ├── styles.css            # Styles
│   └── images/               # UI images (backgrounds, icons)
│       ├── Playlists/
│       ├── Tracker/
│       └── Queue/
│
├── scripts/                  # Utility scripts
│   ├── extract_playlists.py  # Extract playlists from XML
│   ├── extract_tracker.py    # Extract tracker from XML
│   ├── extract_queues.py     # Extract queues from XML
│   ├── check_all_duplicates.py
│   ├── check_playlist.py
│   ├── create_playlists.py
│   └── generate_duplicate_reports.py
│
└── docs/                     # Documentation
    ├── App Overview.md       # Detailed app documentation
    ├── CLAUDE.md             # Development guide
    └── mockups/              # Design mockups
```

## Features

### 🟢 Playlists Page (`/`)

- 3-column grid layout
- Shows which playlists contain the current track
- Active playlists (containing track) appear at top with green glow
- Click to add/remove tracks from playlists
- Automatically likes songs when adding to playlists

### 🟣 Tracker Page (`/tracker`)

- Single-column vertical layout
- Monitor artists in A&R playlists
- Fixed order with divider sections

### 🟠 Queue Page (`/queue`)

- Album-based playlist management
- Add/remove entire albums at once

### 🖥️ Mac Desktop App (`/desktop`)

- Native macOS application wrapper
- Includes Zoom Controls (Cmd `+`, Cmd `-`, Cmd `0`)
- Built-in loading screen during server startup

## Configuration

Edit the CSV files in `data/csv/` to configure which playlists appear:

- `Playlists to Display.csv` - Main playlists page
- `Tracker to Display.csv` - Tracker page
- `Queue to Display.csv` - Queue page

Format: `Dashboard Name, Spotify Playlist Name`

## Scripts

Run scripts from the project root:

```bash
# Extract playlists from Keyboard Maestro XML
python scripts/extract_playlists.py

# Check for duplicate playlists
python scripts/check_all_duplicates.py

# Generate duplicate reports
python scripts/generate_duplicate_reports.py
```

## Environment Variables

Create a `.env` file with your Spotify credentials:

```
SPOTIPY_CLIENT_ID=your_client_id
SPOTIPY_CLIENT_SECRET=your_client_secret
SPOTIPY_REDIRECT_URI=http://127.0.0.1:8888/callback
```

## Tech Stack

- **Backend**: Flask + Spotipy
- **Frontend**: Vanilla JavaScript (ES6+)
- **Auth**: Spotify OAuth 2.0
- **No build step required**

## Documentation

See `docs/App Overview.md` for detailed feature documentation.
