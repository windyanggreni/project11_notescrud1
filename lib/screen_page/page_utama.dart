import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project11_notescrud/model/model_notes.dart';
import 'package:project11_notescrud/screen_page/page_detail.dart';
import 'package:project11_notescrud/screen_page/page_edit.dart';
import 'package:project11_notescrud/screen_page/page_insert.dart';

class PageUtama extends StatefulWidget {
  const PageUtama({Key? key}) : super(key: key);

  @override
  State<PageUtama> createState() => _PageUtamaState();
}

class _PageUtamaState extends State<PageUtama> {
  TextEditingController searchController = TextEditingController();
  List<Datum>? noteList;
  List<Datum>? filteredNoteList;

  @override
  void initState() {
    super.initState();
    getNotes();
  }

  Future<void> getNotes() async {
    try {
      var response = await http.get(Uri.parse('http://192.168.43.124/notesDB/getNotes.php'));
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['isSuccess'] == true) {
          List<Datum> notes = (jsonData['data'] as List).map((item) => Datum.fromJson(item)).toList();
          setState(() {
            noteList = notes;
            filteredNoteList = noteList;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load notes: ${jsonData['message']}')));
        }
      } else {
        throw Exception('Failed to load notes');
      }
    } catch (e) {
      print('Error getNotes: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      var response = await http.post(
        Uri.parse('http://192.168.43.124/notesDB/deleteNote.php'),
        body: {'id': id},
      );
      var jsonData = json.decode(response.body);
      if (response.statusCode == 200 && jsonData['is_success'] == true) {
        setState(() {
          noteList!.removeWhere((note) => note.id == id);
          filteredNoteList = List.from(noteList!);
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Note deleted successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete note: ${jsonData['message']}')));
      }
    } catch (e) {
      print('Error deleteNote: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Notes')),
        backgroundColor: Colors.cyan,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  filteredNoteList = noteList
                      ?.where((note) =>
                  note.judulNote.toLowerCase().contains(value.toLowerCase()) ||
                      note.isiNote.toLowerCase().contains(value.toLowerCase()))
                      .toList();
                });
              },
              decoration: InputDecoration(
                labelText: "Search",
                hintText: "Search",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredNoteList != null
                ? ListView.builder(
              itemCount: filteredNoteList!.length,
              itemBuilder: (context, index) {
                Datum note = filteredNoteList![index];
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PageDetailNote(note: note),
                          ),
                        );
                      },
                      child: ListTile(
                        title: Text(
                          '${note.judulNote}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          "${note.isiNote}",
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PageEditNotes(
                                      id: note.id,
                                      judulNote: note.judulNote,
                                      isiNote: note.isiNote,
                                      ket: note.ket,
                                    ),
                                  ),
                                ).then((updatedNote) {
                                  if (updatedNote != null) {
                                    setState(() {
                                      int index = noteList!.indexWhere((n) => n.id == updatedNote.id);
                                      if (index != -1) {
                                        noteList![index] = updatedNote;
                                        filteredNoteList = List.from(noteList!);
                                      }
                                    });
                                  }
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Delete Note'),
                                    content: Text('Are you sure you want to delete this note?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          deleteNote(note.id);
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Yes'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
                : Center(
              child: CircularProgressIndicator(color: Colors.orange),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var newNote = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PageInsertNotes()),
          );

          if (newNote != null) {
            setState(() {
              noteList!.add(newNote);
              if (searchController.text.isNotEmpty) {
                filteredNoteList = noteList
                    ?.where((note) =>
                note.judulNote
                    .toLowerCase()
                    .contains(searchController.text.toLowerCase()) ||
                    note.isiNote
                        .toLowerCase()
                        .contains(searchController.text.toLowerCase()))
                    .toList();
              } else {
                filteredNoteList = List.from(noteList!);
              }
            });
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.cyan,
      ),
    );
  }
}
