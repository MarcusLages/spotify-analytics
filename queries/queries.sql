SELECT * FROM Albums ORDER BY release_date DESC LIMIT 100;
SELECT * FROM Albums ORDER BY added_at DESC LIMIT 100;

-- 
SELECT
    s.name  AS song,
    ar.name AS artist,
    TO_CHAR((s.duration_ms || ' milliseconds')::interval, 'HH24:MI:SS') AS duration
FROM Songs s
JOIN ArtistsInSongs ais 
    ON s.id = ais.song_id
JOIN Artists ar 
    ON ais.artist_id = ar.id
WHERE ais.artist_order = 0
ORDER BY s.duration_ms DESC;


SELECT 
    COUNT(*) AS total_songs,
    ROUND(SUM(duration_ms) / 3600000.0, 2) AS total_hours,
    TO_CHAR((SUM(duration_ms) / COUNT(*) || ' milliseconds')::interval, 'HH24:MI:SS') AS duration
FROM Songs;

SELECT 
    album,
    track_num,
    song,
    artist,
    TO_CHAR((duration_ms || ' milliseconds')::interval, 'HH24:MI:SS') AS duration
FROM v_songs_albums_artists
ORDER BY album, track_num
LIMIT 100
OFFSET 0;

SELECT 
    album, 
    COUNT(DISTINCT song_id) AS songs,
    TO_CHAR((SUM(DISTINCT duration_ms) || ' milliseconds')::interval, 'HH24:MI:SS') AS total_duration,
    TO_CHAR((SUM(DISTINCT duration_ms) / COUNT(DISTINCT song_id) || ' milliseconds')::interval, 'HH24:MI:SS') AS avg_duration
FROM v_songs_albums
GROUP BY album
LIMIT 100;

SELECT
    artist,
    COUNT(*) AS songs,
    TO_CHAR((SUM(DISTINCT duration_ms) || ' milliseconds')::interval, 'HH24:MI:SS') AS total_duration,
    TO_CHAR((SUM(DISTINCT duration_ms) / COUNT(DISTINCT song_id) || ' milliseconds')::interval, 'HH24:MI:SS') AS avg_duration
FROM v_songs_artists
GROUP BY artist
ORDER BY total_duration DESC;

SELECT artist, COUNT(*) AS features
FROM v_songs_artists
WHERE artist_order > 0
GROUP BY artist
ORDER BY features DESC;

SELECT album, COUNT(DISTINCT artist) AS artists
FROM v_albums_artists
GROUP BY album_id, album
ORDER BY artists DESC;

SELECT
    TO_CHAR(added_at, 'YYYY-MM') AS month,
    COUNT(*)                     AS songs_added
FROM Songs
GROUP BY month
ORDER BY songs_added DESC;

SELECT
    TO_CHAR(added_at, 'YYYY') AS year,
    COUNT(*)                  AS songs_added
FROM Songs
GROUP BY year
ORDER BY songs_added DESC;