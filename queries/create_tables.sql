CREATE TABLE Artists (
    id   VARCHAR(62), -- PK
    name VARCHAR(255) NOT NULL,
    CONSTRAINT ArtistsPK PRIMARY KEY(id)
);

CREATE TYPE ALBUMTYPE as ENUM('album', 'single', 'compilation');
CREATE TYPE DATEPRECISION as ENUM('year', 'month', 'day');

CREATE TABLE Albums (
    id                     VARCHAR(62), -- PK
    name                   VARCHAR(255) NOT NULL,
    type                   ALBUMTYPE DEFAULT 'album',
    total_songs            SMALLINT,
    release_date           DATE,
    release_date_precision DATEPRECISION DEFAULT 'year',
    added_at               DATE DEFAULT CURRENT_DATE(),
    CONSTRAINT AlbumsPK PRIMARY KEY(id),
    CONSTRAINT PositiveTotalSongs CHECK (total_songs > 0)
);

CREATE TABLE Songs (
    id          VARCHAR(62), -- PK
    name        VARCHAR(255) NOT NULL,
    album_id    VARCHAR(62) NOT NULL,
    track_num   SMALLINT DEFAULT 0,
    duration_ms INTEGER,
    is_playable BOOLEAN,
    added_at    DATE DEFAULT CURRENT_DATE(),
    CONSTRAINT SongsPK PRIMARY KEY(id),
    CONSTRAINT SongsAlbumFK FOREIGN KEY(album_id) REFERENCES Albums(id),
    CONSTRAINT PositiveTrackNum CHECK (track_num > 0),
    CONSTRAINT PositiveDurationMs CHECK (duration_ms > 0)
);

-- Relation Tables
CREATE TABLE ArtistsInAlbums (
    artist_id VARCHAR(62),
    album_id  VARCHAR(62),
    CONSTRAINT ArtistAlbumPK PRIMARY KEY (artist_id, album_id),
    CONSTRAINT ArtistFK FOREIGN KEY(artist_id) REFERENCES Artists(id),
    CONSTRAINT AlbumFK FOREIGN KEY(album_id) REFERENCES Albums(id)
);

CREATE TABLE ArtistsInSongs (
    artist_id VARCHAR(62),
    song_id  VARCHAR(62),
    CONSTRAINT ArtistSongPK PRIMARY KEY (artist_id, song_id),
    CONSTRAINT ArtistFK FOREIGN KEY(artist_id) REFERENCES Artists(id),
    CONSTRAINT SongFK FOREIGN KEY(song_id) REFERENCES Songs(id)
);