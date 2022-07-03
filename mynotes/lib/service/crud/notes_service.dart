import 'dart:async';

import 'package:Packflix/extensions/filter.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

import 'crud_exceptions.dart';

@immutable
class DatabaseUser {
  final int id;
  final String email;
  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $id, email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Photo {
  final int id;
  final int userId;
  String photoName;

  Photo({
    required this.id,
    required this.userId,
    required this.photoName,
  });

  Photo.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        photoName = map['photo_name'] as String,
        userId = map[userIdColumn] as int;

  @override
  String toString() => 'Note, ID = $id, userId = $userId';

  @override
  bool operator ==(covariant Photo other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class PhotoService {
  Database? _db;

  List<Photo> _photos = [];

  DatabaseUser? _user;

  static final PhotoService _shared = PhotoService._sharedInstance();
  PhotoService._sharedInstance() {
    _photosStreamController = StreamController<List<Photo>>.broadcast(
      onListen: () {
        _photosStreamController.sink.add(_photos);
      },
    );
  }
  factory PhotoService() => _shared;

  late final StreamController<List<Photo>> _photosStreamController;
  Future<void> deletePhoto({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      photoTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    } else {
      _photos.removeWhere((note) => note.id == id);
      _photosStreamController.add(_photos);
    }
  }

  Stream<List<Photo>> get allNotes =>
      _photosStreamController.stream.filter((note) {
        final currentUser = _user;
        if (currentUser != null) {
          return note.userId == currentUser.id;
        } else {
          throw UserShouldBeSetBeforeReadingAllNotes();
        }
      });

  Future<DatabaseUser> getOrCreateUser({
    required String email,
    bool setAsCurrentuser = true,
  }) async {
    try {
      final user = await getUser(email: email);
      if (setAsCurrentuser) {
        _user = user;
      }
      return user;
    } on CouldNotFindUser {
      final createdUser = await createUser(email: email);
      if (setAsCurrentuser) {
        _user = createdUser;
      }
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _cacheNotes() async {
    final allPhotos = await getAllNotes();
    _photos = allPhotos.toList();
    _photosStreamController.add(_photos);
  }

  Future<Iterable<Photo>> getAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final photos = await db.query('photo');

    return photos.map((photosRow) => Photo.fromRow(photosRow));
  }

  Future<Photo> createPhoto({
    required DatabaseUser owner,
    required String photoName,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // make sure owner exists in the database with the correct id
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    // create the note
    final noteId = await db.insert('photo', {
      userIdColumn: owner.id,
      photoNameColumn: photoName,
    });

    final note = Photo(
      id: noteId,
      userId: owner.id,
      photoName: photoName,
    );

    _photos.add(note);
    _photosStreamController.add(_photos);

    return note;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (results.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }

    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });

    return DatabaseUser(
      id: userId,
      email: email,
    );
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      // empty
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();

      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      // create the user table
      await db.execute(createUserTable);
      // create note table
      await db.execute(createPhotoTable);
      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }
}

const dbName = 'packflixDB.db';
const noteTable = 'note';
const photoTable = 'photo';

const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const photoNameColumn = 'photo_name';

const isSyncedWithCloudColumn = 'is_synced_with_cloud';
const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
        "id"	INTEGER NOT NULL,
        "email"	TEXT NOT NULL UNIQUE,
        PRIMARY KEY("id" AUTOINCREMENT)
      );''';
const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
        "id"	INTEGER NOT NULL,
        "user_id"	INTEGER NOT NULL,
        "text"	TEXT,
        "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY("user_id") REFERENCES "user"("id"),
        PRIMARY KEY("id" AUTOINCREMENT)
      );''';
const createPhotoTable = '''CREATE TABLE IF NOT EXISTS "photo" (
        "id"	INTEGER NOT NULL,
        "user_id"	INTEGER NOT NULL,
        "photo_name"	STRING NOT NULL,

       
        FOREIGN KEY("user_id") REFERENCES "user"("id"),
        PRIMARY KEY("id" AUTOINCREMENT)
      );''';
