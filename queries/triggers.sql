--* Trigger to set updated_at automatically
CREATE OR REPLACE FUNCTION fn_set_updated_at()
    RETURNS TRIGGER AS $updated_at$
    BEGIN
        NEW.updated_at = CURRENT_DATE;
        RETURN NEW;
    END;
$updated_at$ LANGUAGE PLPGSQL;

CREATE OR REPLACE TRIGGER trg_artists_updated_at
    BEFORE UPDATE ON Artists
    FOR EACH ROW
    EXECUTE FUNCTION fn_set_updated_at();

CREATE OR REPLACE TRIGGER trg_albums_updated_at
    BEFORE UPDATE ON Albums
    FOR EACH ROW
    EXECUTE FUNCTION fn_set_updated_at();

CREATE OR REPLACE TRIGGER trg_songs_updated_at
    BEFORE UPDATE ON Songs
    FOR EACH ROW
    EXECUTE FUNCTION fn_set_updated_at();

--* Trigger to delete all songs of an artist, when the artist is deleted,
--* whenever the artist is the only one in that song
CREATE OR REPLACE FUNCTION fn_song_deleted_when_artist_deleted()
    RETURNS TRIGGER AS $songs_deleted_when_artist_deleted$
    BEGIN
        DELETE FROM Songs
        WHERE id IN (
            SELECT ais.song_id
            FROM ArtistsInSongs ais
            WHERE ais.artist_id = OLD.id
                AND NOT EXISTS (
                    SELECT 1
                    FROM ArtistsInSongs ais2
                    WHERE ais2.artist_id <> OLD.id
                        AND ais2.song_id = ais.song_id
                )
        );
        RETURN OLD;
    END;
$songs_deleted_when_artist_deleted$ LANGUAGE PLPGSQL