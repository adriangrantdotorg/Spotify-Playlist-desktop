# CLAUDE.md

## Commands

- Run Server: `python app.py` (Runs on port 8888)
- Install Deps: `pip install -r requirements.txt`

## Architecture

- **Backend**: Flask (`app.py`). Handles Spotify OAuth (via `spotipy`) and API proxying.
- **Frontend**: Vanilla JS (`script.js`) + HTML/CSS. No build step.
- **Config**:
  - `Playlists to Display.csv`: Config for dashboard playlists.
  - `Tracker to Display.csv`: Config for tracker playlists.

## Style

- **Python**: PEP 8 standards. No type hints enforced.
- **JS**: Vanilla JavaScript (ES6+), no frameworks.
