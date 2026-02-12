# Spotify Playlist Dashboard — App Overview

## What It Does

This app runs as a local web dashboard that connects to your Spotify account. It detects whatever track you're currently playing (or most recently played) and shows you **which of your playlists already contain that track**.

You can then add or remove the track from any playlist with a single click — no need to switch between Spotify tabs or search through playlists manually.

---

## The Two Pages

### 🟢 Playlists Page (`/`)

Your main sorting workspace. All of your configured playlists are displayed in a **3-column grid**, organized into two sections separated by a glowing blue divider line:

#### ⬆️ Above the Line — **Active Playlists**

These are the playlists that **already contain** the currently playing track. They appear:

- At the **top** of the page
- With a **green glowing border**
- With a **pulsing checkmark** (✓) on the right side
- Sorted **alphabetically**

This tells you at a glance: _"This song is already saved in these playlists."_

#### ⬇️ Below the Line — **Inactive Playlists**

These are all your other playlists that **do not contain** the current track. They appear:

- **Below** the blue divider
- With a **subtle, muted appearance**
- Also sorted **alphabetically** across 3 columns

This tells you: _"You could add this song to any of these playlists."_

#### Clicking a Playlist

- **Click an inactive playlist** → adds the track to that playlist **and** likes the song
- **Click an active playlist** → removes the track from that playlist (does **not** unlike it)
- Either action also copies the Spotify playlist name to your clipboard

---

### 🟣 Tracker Page (`/tracker`)

A separate page for **monitoring artists** rather than sorting music. The Tracker uses a **single-column vertical layout** with a fixed order (not sorted alphabetically). Green divider lines separate logical sections.

Where the Playlists page answers _"Which playlists is this song in?"_, the Tracker page answers _"Is this artist already being tracked in my A&R playlists?"_

Same click-to-toggle behavior as the Playlists page.

---

## The Header

Both pages share a compact header bar at the top that shows:

| Element                | Meaning                                                |
| ---------------------- | ------------------------------------------------------ |
| **Track title**        | The song currently playing (or most recently played)   |
| **Artist name**        | Below the track title                                  |
| **Animated bars**      | Five small bars animate when music is actively playing |
| **"Nothing Playing…"** | Shown when Spotify is paused or idle                   |

The dashboard automatically polls Spotify every **10 seconds** for track changes (slows to 60s when the browser tab is in the background).

---

## Configuration

Playlists are configured via two CSV files in the project root:

| File                       | Controls            | Format                                              |
| -------------------------- | ------------------- | --------------------------------------------------- |
| `Playlists to Display.csv` | Playlists page grid | `Dashboard Name, Spotify Playlist Name`             |
| `Tracker to Display.csv`   | Tracker page list   | Same format, with `DIVIDER` rows for section breaks |

The **Dashboard Name** is the short label shown in the UI. The **Spotify Playlist Name** must exactly match the playlist name in your Spotify library.

---

## Running It

```bash
python app.py
```

Then open **http://127.0.0.1:8888** in your browser.

On first run, you'll be redirected to Spotify to log in. After that, the auth token is cached locally.
