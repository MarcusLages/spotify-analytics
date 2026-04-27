import json
import os
import spotipy
import psycopg2
from datetime import date, datetime, timezone
from dotenv import load_dotenv
from spotipy.oauth2 import SpotifyOAuth

FETCH_LIMIT = 5

load_dotenv()

sp = spotipy.Spotify(
    auth_manager=SpotifyOAuth(
        client_id=os.getenv("SPOTIFY_CLIENT_ID"),
        client_secret=os.getenv("SPOTIFY_CLIENT_SECRET"),
        redirect_uri=os.getenv("SPOTIFY_REDIRECT_URI"),
        scope=os.getenv("SPOTIFY_SCOPE")
    )
)

conn = psycopg2.connect(
    host=os.getenv("DB_HOST", "localhost"),
    port=os.getenv("DB_PORT", 5432),
    dbname=os.getenv("DB_NAME"),
    user=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
)
cur = conn.cursor()

def parse_release_date(raw_str):
    """
    Considering a str as YYYY, YYYY-MM or YYYY-MM-DD as in Spotify API.
    """
    if not raw_str:
        return (None, "year")
    
    toks = raw_str.split("-")
    match len(toks):
        case 1:
            return (date(int(toks[0]), 1, 1), "year")
        case 2:
            return (date(int(toks[0]), int(toks[1]), 1), "month")
        case 3:
            return (datetime.strptime(raw_str, "%Y-%m-%d").date(), "day")
        case _:
            print("Bad release date input")
            return (None, "year")
        
def insert_artist(artist):
    cur.execute(
        """
        INSERT INTO Artists (id, name)
        VALUES (%s, %s)
        ON CONFLICT (id) DO NOTHING
        """,
        (artist["id"], artist["name"]),
    )
    
def insert_album(album, added_at):
    release_date, precision = parse_release_date(album.get("release_date"))
    if added_at:
        added_date = datetime.strptime(added_at, "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=timezone.utc)
    else:
        added_at = datetime.now(timezone.utc)

    cur.execute(
        """
        INSERT INTO Albums (id, name, type, release_date, release_date_precision, added_at)
        VALUES (%s, %s, %s::ALBUMTYPE, %s, %s::DATEPRECISION, %s)
        ON CONFLICT (id) DO NOTHING
        """,
        (
            album["id"],
            album["name"],
            album["album_type"],
            release_date,
            precision,
            added_date,
        ),
    )
    
def insert_song(track, album_id, added_at):
    if added_at:
        added_date = datetime.strptime(added_at, "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=timezone.utc)
    else:
        added_at = datetime.now(timezone.utc)

    cur.execute(
        """
        INSERT INTO Songs (id, name, album_id, track_num, duration_ms, is_playable, popularity, added_at)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT (id) DO NOTHING
        """,
        (
            track["id"],
            track["name"],
            album_id,
            track.get("track_number"),
            track.get("duration_ms"),
            track.get("is_playable"),
            track.get("popularity"),
            added_date,
        ),
    )
    
def insert_artists_in_song(song_id, artists):
    for order, artist in enumerate(artists):
        cur.execute(
            """
            INSERT INTO ArtistsInSongs (song_id, artist_id, artist_order)
            VALUES (%s, %s, %s)
            ON CONFLICT (song_id, artist_id) DO NOTHING
            """,
            (song_id, artist["id"], order),
        )
        
def fetch_saved_tracks(limit = FETCH_LIMIT):
    results = sp.current_user_saved_tracks(limit)
    return results["items"]

def build_output(item):
    track = item["track"]
    album = track["album"]
    release_date, precision = parse_release_date(album.get("release_date"))

    return {
        "song": {
            "id": track["id"],
            "name": track["name"],
            "track_number": track.get("track_number"),
            "duration_ms": track.get("duration_ms"),
            "is_playable": track.get("is_playable"),
            "popularity": track.get("popularity"),
            "added_at": item["added_at"],
        },
        "album": {
            "id": album["id"],
            "name": album["name"],
            "type": album["album_type"],
            "release_date": release_date.isoformat() if release_date else None,
            "release_date_precision": precision,
        },
        "artists": [
            {"id": a["id"], "name": a["name"], "order": i}
            for i, a in enumerate(track["artists"])
        ],
    }
    
def process_item(item):
    track = item["track"]
    album = track["album"]
    added_at = item["added_at"]

    #! Insert in order: artists -> albums -> songs -> ArtistsInSongs
    for artist in track["artists"]:
        insert_artist(artist)

    insert_album(album, added_at)
    insert_song(track, album["id"], added_at)
    insert_artists_in_song(track["id"], track["artists"])

    return build_output(item)

def main() -> None:
    items = fetch_saved_tracks()

    print(f"Fetching {len(items)} saved tracks.")

    output = []

    try:
        for item in items:
            record = process_item(item)
            output.append(record)

        conn.commit()
        print("All records committed to database.")
    except Exception as e:
        conn.rollback()
        print(f"Error. Transaction rolled back: {e}")
        raise
    finally:
        cur.close()
        conn.close()

    output_path = "output.json"
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(output, f, indent=2, default=str)

    print(f"Output also saved to {output_path}.")

if __name__ == "__main__":
    main()