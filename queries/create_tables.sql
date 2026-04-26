CREATE TABLE Artists (
    id   VARCHAR(22), -- PK
    name VARCHAR(255) NOT NULL,
    CONSTRAINT ArtistsPK PRIMARY KEY(id)
);

CREATE TYPE ALBUMTYPE as ENUM('album', 'single', 'compilation');
CREATE TYPE DATEPRECISION as ENUM('year', 'month', 'day');

CREATE TABLE Albums (
    id                     VARCHAR(22), -- PK
    name                   VARCHAR(255) NOT NULL,
    type                   ALBUMTYPE DEFAULT 'album',
    release_date           DATE,
    release_date_precision DATEPRECISION DEFAULT 'year',
    added_at               DATE DEFAULT CURRENT_DATE,
    CONSTRAINT pk_albums_id PRIMARY KEY(id)
);

CREATE TABLE Songs (
    id          VARCHAR(22), -- PK
    name        VARCHAR(255) NOT NULL,
    album_id    VARCHAR(22) NOT NULL,
    track_num   SMALLINT DEFAULT 1,
    duration_ms INTEGER,
    is_playable BOOLEAN DEFAULT NULL,
    popularity  SMALLINT,
    added_at    DATE DEFAULT CURRENT_DATE,
    CONSTRAINT pk_songs_id          PRIMARY KEY(id),
    CONSTRAINT fk_songs_album_id    FOREIGN KEY(album_id) REFERENCES Albums(id),
    CONSTRAINT ck_songs_track_num   CHECK (track_num > 0),
    CONSTRAINT ck_songs_duration_ms CHECK (duration_ms > 0),
    CONSTRAINT ck_songs_popularity  CHECK (popularity >= 0 AND popularity <= 100)
);

CREATE INDEX idx_songs_album_id ON Songs(album_id); -- B-tree vs Hash

CREATE TABLE ArtistsInSongs (
    song_id      VARCHAR(22),
    artist_id    VARCHAR(22),
    artist_order SMALLINT DEFAULT 0,
    CONSTRAINT pk_artistsinsongs_artist_id_song_id PRIMARY KEY (artist_id, song_id),
    CONSTRAINT fk_artistsinsongs_song_id           FOREIGN KEY(song_id) REFERENCES Songs(id) ON DELETE CASCADE,
    CONSTRAINT fk_artistsinsongs_artist_id         FOREIGN KEY(artist_id) REFERENCES Artists(id) ON DELETE CASCADE,
    CONSTRAINT ck_artistsinsongs_artist_order      CHECK(artist_order >= 0)
);

-- No need to index song_id
CREATE INDEX idx_artistsinsongs_artist_id ON ArtistsInSongs(artist_id);