CREATE TABLE Artists (
    id   VARCHAR(22), -- PK
    name VARCHAR(255) UNIQUE NOT NULL,
    created_at      DATE DEFAULT CURRENT_DATE,
    updated_at      DATE DEFAULT CURRENT_DATE,
    CONSTRAINT pk_artists_id PRIMARY KEY(id)
);

COMMENT ON TABLE Artists IS 'Spotify artists with saved songs.';
COMMENT ON COLUMN Artists.id IS 'Base-62 22 characters ID from Spotify API.';
COMMENT ON COLUMN Artists.name IS 'Artist display name from Spotify.';
COMMENT ON COLUMN Artists.created_at IS 'Date record was created locally.';
COMMENT ON COLUMN Artists.updated_at IS 'Last date artist data was fetched from Spotify API.';

CREATE TYPE ALBUMTYPE as ENUM('album', 'single', 'compilation');
CREATE TYPE DATEPRECISION as ENUM('year', 'month', 'day');

-- TODO: ADD COMMENTS

CREATE TABLE Albums (
    id                     VARCHAR(22), -- PK
    name                   VARCHAR(255) NOT NULL,
    type                   ALBUMTYPE DEFAULT 'album',
    release_date           DATE,
    release_date_precision DATEPRECISION DEFAULT 'year',
    added_at               DATE DEFAULT CURRENT_DATE,
    created_at             DATE DEFAULT CURRENT_DATE,
    updated_at             DATE DEFAULT CURRENT_DATE,
    CONSTRAINT pk_albums_id PRIMARY KEY(id)
);

CREATE INDEX idx_albums_name ON Albums(name);
CREATE INDEX idx_albums_type ON Albums(type);

COMMENT ON TABLE Albums IS 'Spotify albums containing saved songs.';
COMMENT ON COLUMN Albums.id IS 'Base-62 22 character ID from Spotify API.';
COMMENT ON COLUMN Albums.name IS 'Album title.';
COMMENT ON COLUMN Albums.type IS 'Album type: album, single, or compilation.';
COMMENT ON COLUMN Albums.release_date IS 'Date when album was first released.';
COMMENT ON COLUMN Albums.release_date_precision IS 'Precision of release_date (year, month, or day).';
COMMENT ON COLUMN Albums.added_at IS 'Date album was added to user library.';
COMMENT ON COLUMN Albums.created_at IS 'Date record was created locally.';
COMMENT ON COLUMN Albums.updated_at IS 'Last date album data was fetched from Spotify API.';

CREATE TABLE Songs (
    id           VARCHAR(22), -- PK
    name         VARCHAR(255) NOT NULL,
    album_id     VARCHAR(22) NOT NULL,
    track_num    SMALLINT DEFAULT 1,
    duration_ms  INTEGER,
    is_playable  BOOLEAN DEFAULT NULL,
    popularity   SMALLINT,
    added_at     DATE DEFAULT CURRENT_DATE,
    created_at   DATE DEFAULT CURRENT_DATE,
    updated_at   DATE DEFAULT CURRENT_DATE,
    CONSTRAINT pk_songs_id          PRIMARY KEY(id),
    CONSTRAINT fk_songs_album_id    FOREIGN KEY(album_id) REFERENCES Albums(id),
    CONSTRAINT ck_songs_track_num   CHECK (track_num > 0),
    CONSTRAINT ck_songs_duration_ms CHECK (duration_ms > 0),
    CONSTRAINT ck_songs_popularity  CHECK (popularity >= 0 AND popularity <= 100)
);

CREATE INDEX idx_songs_album_id ON Songs(album_id); -- B-tree vs Hash
CREATE INDEX idx_songs_name ON Songs(name);

COMMENT ON TABLE Songs IS 'Spotify songs saved in user library.';
COMMENT ON COLUMN Songs.id IS 'Base-62 22 character ID from Spotify API.';
COMMENT ON COLUMN Songs.name IS 'Song title.';
COMMENT ON COLUMN Songs.album_id IS 'ID of album which the song is part of.';
COMMENT ON COLUMN Songs.track_num IS 'Track number on the album (1-indexed).';
COMMENT ON COLUMN Songs.duration_ms IS 'Song duration in milliseconds.';
COMMENT ON COLUMN Songs.is_playable IS 'Whether the song is playable in the user region.';
COMMENT ON COLUMN Songs.popularity IS 'Spotify popularity score (0-100).';
COMMENT ON COLUMN Songs.added_at IS 'Date song was added to user library.';
COMMENT ON COLUMN Songs.created_at IS 'Date record was created locally.';
COMMENT ON COLUMN Songs.updated_at IS 'Last date song data was fetched from Spotify API.';

CREATE TABLE ArtistsInSongs (
    song_id      VARCHAR(22),
    artist_id    VARCHAR(22),
    artist_order SMALLINT DEFAULT 0,
    created_at   DATE DEFAULT CURRENT_DATE,
    updated_at   DATE DEFAULT CURRENT_DATE,
    CONSTRAINT pk_artistsinsongs_artist_id_song_id PRIMARY KEY (song_id, artist_id),
    CONSTRAINT fk_artistsinsongs_song_id           FOREIGN KEY(song_id) REFERENCES Songs(id) ON DELETE CASCADE,
    CONSTRAINT fk_artistsinsongs_artist_id         FOREIGN KEY(artist_id) REFERENCES Artists(id) ON DELETE CASCADE,
    CONSTRAINT ck_artistsinsongs_artist_order      CHECK(artist_order >= 0)
);

-- No need to index song_id
CREATE INDEX idx_artistsinsongs_artist_id ON ArtistsInSongs(artist_id);

COMMENT ON TABLE ArtistsInSongs IS 'Relates which artists created/interpreted which songs (M:N).';
COMMENT ON COLUMN ArtistsInSongs.song_id IS 'Reference to the ID of a song interpreted/created by the artist.';
COMMENT ON COLUMN ArtistsInSongs.artist_id IS 'Reference to the ID of an artist that interpreted/created the song.';
COMMENT ON COLUMN ArtistsInSongs.artist_order IS 'Order of artist appearance on song (0 = main artist, 1+ = featured).';
COMMENT ON COLUMN ArtistsInSongs.created_at IS 'Date record was created locally.';
COMMENT ON COLUMN ArtistsInSongs.updated_at IS 'Last date relationship was synced from Spotify API.';