import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project11_notescrud/screen_page/page_utama.dart';
import '../model/model_insert.dart';

class PageInsertNotes extends StatefulWidget {
  const PageInsertNotes({super.key});

  @override
  State<PageInsertNotes> createState() => _PageInsertNotesState();
}

class _PageInsertNotesState extends State<PageInsertNotes> {
  TextEditingController txtJudulNote = TextEditingController();
  TextEditingController txtIsiNote = TextEditingController();
  TextEditingController txtKet = TextEditingController();

  //validasi form
  GlobalKey<FormState> keyForm = GlobalKey<FormState>();

  //Proses untuk hit API
  bool isLoading = false;

  Future<ModelInsert?> addNotes() async {
    //handle error
    try {
      setState(() {
        isLoading = true;
      });

      http.Response response = await http.post(
        Uri.parse('http://192.168.43.124/notesDB/simpanNote.php'),
        body: {
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
        } else if (data.value == 2) {
          setState(() {
            isLoading = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${data.message}')),
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
        title: Text('Note Baru'),
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
                  //validasi kosong
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
                  //validasi kosong
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
                //Proses cek loading
                Center(
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : MaterialButton(
                          minWidth: 150,
                          height: 45,
                          onPressed: () {
                            //Cek validasi form ada kosong atau tidak
                            if (keyForm.currentState?.validate() == true) {
                              setState(() {
                                addNotes();
                              });
                            }
                          },
                          child: Text('Insert'),
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
