import 'dart:io';

import 'package:Packflix/constants/routes.dart';
import 'package:Packflix/enums/menu_action.dart';
import 'package:Packflix/service/auth/auth_service.dart';
import 'package:Packflix/service/crud/notes_service.dart';
import 'package:flutter/material.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  _NotesViewState createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final PhotoService _notesService;
  String get userEmail => AuthService.firebase().currentUser!.email!;
  Size? size;

  @override
  void initState() {
    _notesService = PhotoService();
    super.initState();
  }

  @override
  void dispose() {
    _notesService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Photos'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(newNoteRoute);
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    await AuthService.firebase().logOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute,
                      (_) => false,
                    );
                  }
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Log out'),
                ),
              ];
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: _notesService.getOrCreateUser(email: userEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _notesService.allNotes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        final allNotes = snapshot.data as List<Photo>;

                        return ListView.builder(
                          itemCount: allNotes.length,
                          itemBuilder: (context, index) {
                            final note = allNotes[index];
                            size = MediaQuery.of(context).size;

                            return ListTile(
                              title: SizedBox(
                                width: size!.width - 50,
                                height: size!.height - (size!.height / 3),
                                child: Image.file(
                                  File(note.photoName),
                                  fit: BoxFit.contain,
                                ),
                              ),
                              trailing: IconButton(
                                onPressed: () async {
                                  _notesService.deletePhoto(id: note.id);
                                },
                                icon: const Icon(Icons.delete),
                              ),
                            );
                          },
                        );
                      } else {
                        return const Text('note');
                      }
                    default:
                      return const CircularProgressIndicator();
                  }
                },
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Log out'),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
