CREATE VIEW v_songs_albums AS
SELECT
    s.id            AS song_id,
    s.name          AS song,
    s.track_num,
    s.duration_ms,
    s.is_playable,
    s.added_at      AS song_added_at,
    al.id           AS album_id,
    al.name         AS album,
    al.type         AS album_type,
    al.release_date
FROM Songs s
JOIN Albums al ON s.album_id = al.id;

CREATE VIEW v_songs_artists AS
SELECT
    s.id             AS song_id,
    s.name           AS song,
    s.track_num,
    s.duration_ms,
    s.is_playable,
    s.added_at       AS song_added_at,
    ar.id            AS artist_id,
    ar.name          AS artist,
    ais.artist_order
FROM Songs s
JOIN ArtistsInSongs ais ON s.id = ais.song_id
JOIN Artists ar ON ais.artist_id = ar.id;


CREATE VIEW v_songs_albums_artists AS
SELECT
    s.id             AS song_id,
    s.name           AS song,
    s.track_num,
    s.duration_ms,
    s.is_playable,
    s.added_at       AS song_added_at,
    al.id            AS album_id,
    al.name          AS album,
    al.type          AS album_type,
    al.release_date,
    ar.id            AS artist_id,
    ar.name          AS artist,
    ais.artist_order
FROM Songs s
JOIN Albums al ON s.album_id = al.id
JOIN ArtistsInSongs ais ON s.id = ais.song_id
JOIN Artists ar ON ais.artist_id = ar.id;

CREATE VIEW v_albums_artists AS
SELECT
    album_id,
    album,
    album_type,
    release_date,
    artist_id,
    artist
FROM v_songs_albums_artists;