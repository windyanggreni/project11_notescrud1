import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project11_notescrud/screen_page/page_utama.dart';
import '../model/model_insert.dart';

class PageEditNotes extends StatefulWidget {
  final String id;
  final String judulNote;
  final String isiNote;
  final String ket;

  const PageEditNotes({
    super.key,
    required this.id,
    required this.judulNote,
    required this.isiNote,
    required this.ket,
  });

  @override
  State<PageEditNotes> createState() => _PageEditNotesState();
}

class _PageEditNotesState extends State<PageEditNotes> {
  late TextEditingController txtJudulNote;
  late TextEditingController txtIsiNote;
  late TextEditingController txtKet;

  // Validasi form
  GlobalKey<FormState> keyForm = GlobalKey<FormState>();

  // Proses untuk hit API
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    txtJudulNote = TextEditingController(text: widget.judulNote);
    txtIsiNote = TextEditingController(text: widget.isiNote);
    txtKet = TextEditingController(text: widget.ket);
  }

  Future<ModelInsert?> updateNotes() async {
    // Handle error
    try {
      setState(() {
        isLoading = true;
      });

      http.Response response = await http.post(
        Uri.parse('http://192.168.43.124/notesDB/updateNote.php'),
        body: {
          "id": widget.id.toString(),
          "judul_note": txtJudulNote.text,
          "isi_note": txtIsiNote.text,
          "ket": txtKet.text
        },
      );

      if (response.statusCode == 200) {
        ModelInsert data = modelInsertFromJson(response.body);
        if (data.value == 1) {
          setState(() {
            isLoading = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${data.message}')),
            );

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PageUtama()),
            );
          });
        } else {
          setState(() {
            isLoading = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${data.message}')),
            );
          });
        }
      } else {
        setState(() {
          isLoading = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Server Error: ${response.statusCode}')),
          );
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: Text('Edit Note'),
      ),
      body: Form(
        key: keyForm,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  validator: (val) {
                    return val!.isEmpty ? "Tidak boleh kosong" : null;
                  },
                  controller: txtJudulNote,
                  decoration: InputDecoration(
                    hintText: 'Judul',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                TextFormField(
                  // Validasi kosong
                  validator: (val) {
                    return val!.isEmpty ? "Tidak boleh kosong" : null;
                  },
                  controller: txtIsiNote,
                  maxLines: null, // Memungkinkan untuk multiline
                  decoration: InputDecoration(
                    hintText: 'Isi',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                TextFormField(
                  // Validasi kosong
                  validator: (val) {
                    return val!.isEmpty ? "Tidak boleh kosong" : null;
                  },
                  controller: txtKet,
                  maxLines: null, // Memungkinkan untuk multiline
                  decoration: InputDecoration(
                    hintText: 'Keterangan',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                // Proses cek loading
                Center(
                  child: isLoading
                      ? Center(
                    child: CircularProgressIndicator(),
                  )
                      : MaterialButton(
                    minWidth: 150,
                    height: 45,
                    onPressed: () {
                      // Cek validasi form ada kosong atau tidak
                      if (keyForm.currentState?.validate() == true) {
                        setState(() {
                          updateNotes();
                        });
                      }
                    },
                    child: Text('Update'),
                    color: Colors.green,
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(
                        width: 1,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
