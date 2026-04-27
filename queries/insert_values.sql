--! Important to insert in order: artists -> albums -> songs -> ArtistsInSongs
INSERT INTO Artists (id, name)
    VALUES (%s, %s)
    ON CONFLICT (id) DO NOTHING;

INSERT INTO Albums (id, name, type, release_date, release_date_precision, added_at)
    VALUES (%s, %s, %s::ALBUMTYPE, %s, %s::DATEPRECISION, %s)
    ON CONFLICT (id) DO NOTHING;

INSERT INTO Songs (id, name, album_id, track_num, duration_ms, is_playable, added_at)
    VALUES (%s, %s, %s, %s, %s, %s, %s)
    ON CONFLICT (id) DO NOTHING

INSERT INTO ArtistsInSongs (song_id, artist_id, artist_order)
    VALUES (%s, %s, %s)
    ON CONFLICT (song_id, artist_id) DO NOTHING