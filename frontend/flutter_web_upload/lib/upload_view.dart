import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

class UploadView extends StatefulWidget {
  const UploadView({super.key});

  @override
  State<UploadView> createState() => _UploadViewState();
}

class _UploadViewState extends State<UploadView> {
  final String uploadWorkerPath = 'javascripts/upload_worker.js';
  final String uri = 'http://localhost:3000/api/files/upload';
  final _formKey = GlobalKey<FormState>();

  html.Worker? uploadWorker;
  String uploadProgress = '';
  bool isEnabled = false;
  bool isUploading = false;
  double progressValue = 0;

  String fileName = '';
  String fileSize = '';
  String fileType = '';

  html.FileReader? fileReader;
  html.File? file;

  String setFileSize(double size) {
    late String type;
    if (size < 1024) {
      type = 'B';
      size = size;
    } else if (size < 1024 * 1024) {
      type = 'KB';
      size = size / 1024;
    } else if (size < 1024 * 1024 * 1024) {
      type = 'MB';
      size = size / (1024 * 1024);
    } else if (size < 1024 * 1024 * 1024 * 1024) {
      type = 'GB';
      size = size / (1024 * 1024 * 1024);
      //} else if (size < 1024 * 1024 * 1024 * 1024 * 1024) {
    } else {
      type = 'TB';
      size = size / (1024 * 1024 * 1024 * 1024);
    }
    if (size == size.truncateToDouble()) {
      return '$size $type';
    } else {
      return '${size.toStringAsFixed(2)} $type';
    }
  }

  setFileTable() {
    setState(() {
      fileName = file!.name;
      fileType = file!.type;
      fileSize = setFileSize(file!.size.toDouble());
    });
  }

  resetTable() {
    setState(() {
      fileName = '';
      fileType = '';
      fileSize = '';
      progressValue = 0;
      isUploading = false;
    });
  }

  selectFile() {
    resetTable();
    html.InputElement uploadInput =
        html.FileUploadInputElement() as html.InputElement;
    uploadInput.multiple = false;
    uploadInput.draggable = true;
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      file = uploadInput.files!.first;
      setFileTable();
      isEnabled = true;
    });
  }

  /*showMyDialog() {
    showDialog(
      barrierColor: Colors.grey[400]!.withOpacity(0.4),
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (context) {
        return StatefulBuilder(builder: (context, StateSetter setState) {
          return const AlertDialog(
              title: Text('Uploading..'), content: LinearProgressIndicator());
        });
      },
    );
  }*/

  uploadFile() async {
    //showMyDialog();
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      isUploading = true;
    });

    uploadWorker!.postMessage({'file': file, 'uri': uri});
  }

  setView(html.MessageEvent messageEvent) {
    if ((messageEvent.data)[0]) {
      progressValue = (messageEvent.data)[1];
      uploadProgress = 'Uploading... $progressValue%';
    } else {
      uploadProgress = '${(messageEvent.data)[1]['message']}';
      //Navigator.of(context, rootNavigator: true).pop('dialog');
    }
  }

  @override
  void initState() {
    uploadProgress = '';
    uploadWorker = html.Worker(uploadWorkerPath);
    uploadWorker!.onMessage.listen((messageEvent) {
      setState(() {
        setView(messageEvent);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Large File'),
      ),
      body: ListView(
        children: [
          Form(
            key: _formKey,
            child: Wrap(children: <Widget>[
              ElevatedButton.icon(
                label: const Text('Browse..'),
                icon: const Icon(
                  Icons.folder_open,
                  color: Colors.blue,
                ),
                onPressed: () {
                  selectFile();
                },
              ),
              ElevatedButton.icon(
                //enabled: _enabled,
                label: const Text('Upload file'),
                icon: const Icon(
                  Icons.file_upload,
                  color: Colors.blue,
                ),

                onPressed: () => isEnabled ? uploadFile() : null,
              ),
            ]),
          ),
          DataTable(
            headingRowHeight: 42,
            dataRowHeight: 42,
            showCheckboxColumn: false,
            columns: const <DataColumn>[
              DataColumn(
                label: Icon(Icons.attachment, color: Colors.blue),
              ),
              DataColumn(
                label: Text(
                  'Name',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              DataColumn(
                label: Text(
                  'Size',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              DataColumn(
                label: Text(
                  'Type',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ],
            rows: [
              DataRow(
                cells: <DataCell>[
                  DataCell(
                      isUploading ? Text('$progressValue%') : const Text('')),
                  DataCell(Text(fileName)),
                  DataCell(Text(fileSize)),
                  DataCell(Text(fileType))
                ],
              )
            ],
          ),
          isUploading
              ? Stack(
                  children: [
                    Container(
                        margin: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8)),
                          child: LinearProgressIndicator(
                            value: progressValue / 100,
                            //backgroundColor: Colors.grey[400],
                            color: Colors.grey[400],
                            minHeight: 20,
                          ),
                        )),
                    Container(
                        height: 34,
                        alignment: Alignment.center,
                        child: Text(
                          uploadProgress,
                          textAlign: TextAlign.center,
                        )),
                  ],
                )
              : Container(),
        ],
      ),
    );
  }
}
