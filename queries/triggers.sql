CREATE OR REPLACE FUNCTION fn_set_updated_at()
    RETURNS TRIGGER AS $updated_at$
    BEGIN;
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
