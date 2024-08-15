import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController urlController = TextEditingController();

  @override
  void dispose() {
    urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Download & Open File',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 25,
            shadows: [
              Shadow(
                color: Colors.green.shade200,
                blurRadius: 6,
                offset: const Offset(-1, 1),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.green.shade600,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'Enter URL',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(14),
                  ),
                  borderSide: BorderSide(
                    color: Colors.green,
                  ),
                ),
              ),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.normal,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade500,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
                disabledBackgroundColor: Colors.green,
                disabledForegroundColor: Colors.green,
              ),
              onPressed: () {
                String url = urlController.text;
                if (url.isNotEmpty) {
                  openFile(url: url);
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Error'),
                      content: const Text('Please enter a valid URL.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  "Download & Open",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    shadows: [
                      Shadow(
                        color: Colors.green.shade200,
                        blurRadius: 6,
                        offset: const Offset(-1, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future openFile({required String url}) async {
  final file = await downloadFile(url);
  if (file == null) return;
  print("path: ${file.path}");

  // For Open File
  OpenFile.open(file.path);
}

Future<File?> downloadFile(String url) async {
  final appStorage = await getApplicationDocumentsDirectory();
  final fileName = url.split('/').last;

  // Extracting file name from URL
  final file = File("${appStorage.path}/$fileName");
  try {
    final response = await Dio().get(
      url,
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: false,
        receiveTimeout: const Duration(seconds: 0),
      ),
    );

    final raf = file.openSync(mode: FileMode.write);
    raf.writeFromSync(response.data);
    await raf.close();
    return file;
  } catch (e) {
    return null;
  }
}
