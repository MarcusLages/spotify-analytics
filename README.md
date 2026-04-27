# Spotify Saved Tracks DB
Fetches your Spotify saved tracks and stores them in a local PostgreSQL database.

## Setup
### 1. Install dependencies
```bash
pip install spotipy psycopg2-binary python-dotenv
```

### 2. Create `.env`
```env
SPOTIFY_CLIENT_ID=
SPOTIFY_CLIENT_SECRET=
SPOTIFY_REDIRECT_URI=http://localhost:8888/callback
SPOTIFY_SCOPE=user-library-read

DB_HOST=localhost
DB_PORT=5432
DB_NAME=
DB_USER=
DB_PASSWORD=
```

> Get Spotify credentials at [developer.spotify.com](https://developer.spotify.com/dashboard).

### 3. Set up the database
```bash
psql -U your_user -d your_db -f queries/create_tables.sql
psql -U your_user -d your_db -f queries/triggers.sql
psql -U your_user -d your_db -f queries/views.sql
```

### 4. Run
```bash
python get_data.py
```

## Notes
- First run opens a browser for Spotify auth — token is cached in `.cache`
- Re-running is safe, all inserts use `ON CONFLICT DO NOTHING`
- If a batch fails, the script prints the offset so you can resume