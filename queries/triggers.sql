--* Trigger to set updated_at automatically
CREATE OR REPLACE FUNCTION fn_set_updated_at()
    RETURNS TRIGGER AS $updated_at$
    BEGIN
        NEW.updated_at = NOW();
        RETURN NEW;
    END;
$updated_at$ LANGUAGE PLPGSQL;

CREATE OR REPLACE TRIGGER trg_artists_updated_at_update
    BEFORE UPDATE ON Artists
    FOR EACH ROW
    EXECUTE FUNCTION fn_set_updated_at();

CREATE OR REPLACE TRIGGER trg_albums_updated_at_update
    BEFORE UPDATE ON Albums
    FOR EACH ROW
    EXECUTE FUNCTION fn_set_updated_at();

CREATE OR REPLACE TRIGGER trg_songs_updated_at_update
    BEFORE UPDATE ON Songs
    FOR EACH ROW
    EXECUTE FUNCTION fn_set_updated_at();

--* Trigger to delete all songs of an artist, when the artist is deleted,
--* whenever the artist is the only one in that song
-- CREATE OR REPLACE FUNCTION fn_song_deleted_when_artist_deleted()
--     RETURNS TRIGGER AS $songs_deleted_when_artist_deleted$
--     BEGIN
--         DELETE FROM Songs
--         WHERE id IN (
--             SELECT ais.song_id
--             FROM ArtistsInSongs ais
--             WHERE ais.artist_id = OLD.id
--                 AND NOT EXISTS (
--                     SELECT 1
--                     FROM ArtistsInSongs ais2
--                     WHERE ais2.artist_id <> OLD.id
--                         AND ais2.song_id = ais.song_id
--                 )
--         );
--         RETURN OLD;
--     END;
-- $songs_deleted_when_artist_deleted$ LANGUAGE PLPGSQL;

-- CREATE OR REPLACE TRIGGER trg_artists_song_delete
--     BEFORE DELETE ON Artists
--     FOR EACH ROW
--     EXECUTE FUNCTION fn_song_deleted_when_artist_deleted();

--* Trigger to delete an artist if the artist has no remaining songs
-- CREATE OR REPLACE FUNCTION fn_artist_delete_if_no_songs()
--     RETURNS TRIGGER AS $artist_delete_if_no_songs$
--     BEGIN
--         DELETE FROM Artists
--         WHERE id IN (
--             SELECT ais.artist_id
--             FROM ArtistsInSongs ais
--             WHERE ais.song_id = OLD.id
--                 AND NOT EXISTS (
--                     SELECT 1
--                     FROM ArtistsInSongs ais2
--                     WHERE ais.artist_id = ais2.artist_id
--                         AND ais2.song_id <> OLD.id
--                 )
--         );
--         RETURN OLD;
--     END;
-- $artist_delete_if_no_songs$ LANGUAGE PLPGSQL;

-- CREATE OR REPLACE TRIGGER trg_songs_artists_delete
--     AFTER DELETE ON Songs
--     FOR EACH ROW
--     EXECUTE FUNCTION fn_artist_delete_if_no_songs();

-- --* Trigger to delete an artist if the artist has no remaining songs
-- --* (now checking for DELETEs and UPDATEs in the ArtistsInSongs)
-- CREATE OR REPLACE FUNCTION fn_artistsinsongs_delete_artist_if_no_songs()
--     RETURNS TRIGGER AS $artistsinsongs_delete_artist_if_no_songs$
--     BEGIN
--         DELETE FROM Artists
--         WHERE id = OLD.artist_id
--             AND NOT EXISTS (
--                 SELECT 1
--                 FROM ArtistsInSongs ais
--                 WHERE ais.artist_id = OLD.artist_id
--                     AND ais.song_id <> OLD.song_id
--             );
--         RETURN OLD;
--     END;
-- $artistsinsongs_delete_artist_if_no_songs$ LANGUAGE PLPGSQL;

-- CREATE OR REPLACE TRIGGER trg_artistsinsongs_delete_artists_no_songs_delete
--     AFTER DELETE ON ArtistsInSongs
--     FOR EACH ROW
--     EXECUTE FUNCTION fn_artistsinsongs_delete_artist_if_no_songs();

-- CREATE OR REPLACE TRIGGER trg_artistsinsongs_delete_artists_no_songs_update
--     AFTER UPDATE ON ArtistsInSongs
--     FOR EACH ROW
--     WHEN (OLD.artist_id IS DISTINCT FROM NEW.artist_id)
--     EXECUTE FUNCTION fn_artistsinsongs_delete_artist_if_no_songs();

--* Trigger to delete all songs of an album when the album is deleted
-- CREATE OR REPLACE FUNCTION fn_songs_deleted_when_album_deleted()
--     RETURNS TRIGGER AS $songs_deleted_when_album_deleted$
--     BEGIN
--         DELETE FROM Songs
--         WHERE album_id = OLD.id;
--         RETURN OLD;
--     END;
-- $songs_deleted_when_album_deleted$ LANGUAGE PLPGSQL;

-- CREATE OR REPLACE TRIGGER trg_albums_song_delete
--     BEFORE DELETE ON Albums
--     FOR EACH ROW
--     EXECUTE FUNCTION fn_songs_deleted_when_album_deleted();


--* Trigger to delete an album if it has no remaining songs
-- CREATE OR REPLACE FUNCTION fn_album_delete_if_no_songs()
--     RETURNS TRIGGER AS $album_delete_if_no_songs$
--     BEGIN
--         DELETE FROM Albums
--         WHERE id = OLD.album_id
--             AND NOT EXISTS (
--                 SELECT 1
--                 FROM Songs s
--                 WHERE s.album_id = OLD.album_id
--                     AND s.id <> OLD.id
--             );
--         RETURN OLD;
--     END;
-- $album_delete_if_no_songs$ LANGUAGE PLPGSQL;

-- CREATE OR REPLACE TRIGGER trg_songs_album_delete
--     AFTER DELETE ON Songs
--     FOR EACH ROW
--     EXECUTE FUNCTION fn_album_delete_if_no_songs();