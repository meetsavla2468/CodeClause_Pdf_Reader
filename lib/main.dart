import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pdf_reader_codeclause/screens/pdfViewerPage.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';

void main() {
  runApp(MyApp());
}

final darkNotifier = ValueNotifier<bool>(false);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: darkNotifier,
        builder: (BuildContext context, bool isDark, Widget? child) {
          return MaterialApp(
            title: 'Pdf reader',
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(primaryColor: Colors.blue),
            darkTheme: ThemeData.dark(),
            home: const homePage(),
            debugShowCheckedModeBanner: false,
          );
        });
  }
}

class homePage extends StatefulWidget {
  const homePage({super.key});

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  late File localfile;
  @override
  void dispose() {
    // TODO: implement dispose
    darkNotifier.dispose();
    super.dispose();
  }

  TextEditingController urlController = TextEditingController();
  Widget build(BuildContext context) {
    bool isDark = darkNotifier.value;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent.shade100,
        elevation: 2,
        automaticallyImplyLeading: false,
        titleSpacing: 50,
        titleTextStyle: const TextStyle(
            fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black),
        title: const Text('Pdf Reader'),
        actions: [
          IconButton(
              onPressed: () {
                isDark = !isDark;
                darkNotifier.value = isDark;
              },
              icon: Icon(isDark ? Icons.nights_stay : Icons.wb_sunny))
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/intro.png', width: 300, height: 300),
              const SizedBox(height: 80),
              const SizedBox(
                  height: 30,
                  child: Text('Welcome!',
                      style: TextStyle(
                          fontSize: 25, fontWeight: FontWeight.bold))),
              const SizedBox(height: 20),
              const Text('Load Pdf from URL', style: TextStyle(fontSize: 18)),
              SizedBox(
                width: 300,
                child: TextField(
                  decoration: const InputDecoration(hintText: 'Enter Url'),
                  controller: urlController,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                  onPressed: () async {
                    localfile = (await FileDownloader.downloadFile(
                        url: urlController.text.trim(),
                        onDownloadCompleted: (path) {
                          localfile = File(path);
                        }))!;
                    openPDF(context, localfile);
                  },
                  child: const Text("Download")),
              const SizedBox(height: 10),
              const Text('or'),
              const SizedBox(height: 10),
              const Text("View PDf's from storage",
                  style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              ElevatedButton(
                  onPressed: () async {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles();
                    if (result != null) {
                      localfile = File(result.files.single.path!);
                      openPDF(context, localfile);
                    } else {
                      // User canceled the picker
                    }
                  },
                  child: const Text("Open Pdf's")),
            ],
          ),
        ),
      ),
    );
  }

  void openPDF(BuildContext context, File file) => Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) =>
                PDFViewerPage(file: localfile, isDark: darkNotifier.value)),
      );
}
