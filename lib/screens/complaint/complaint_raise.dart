import 'dart:io';
import 'package:http/http.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:highfive/screens/api.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:highfive/screens/complaint/local_widgets/complaint_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';

class ComplaintRaise extends StatefulWidget {
  const ComplaintRaise({super.key});

  @override
  State<ComplaintRaise> createState() => _ComplaintRaiseState();
}

class _ComplaintRaiseState extends State<ComplaintRaise> {
  String? csrftoken;
  String? cookie;
  String? type;
  File? image;
  TextEditingController descriptionController = TextEditingController();
  TextEditingController titleController = TextEditingController();

  String? errorText;
  bool isSubmitting = false;
  bool submitStatus = false;
  bool submitRequest = false;

  Future<int> submitComplaint(File? imageFile) async {
    var request = MultipartRequest('POST', Uri.parse(apiAddComplaint));
    var headers = {
      'Cookie': cookie ?? '',
      'Content-Type': "application/json",
      'Referer': host,
      'X-CSRFToken': csrftoken ?? ''
    };
    var body = {
      'title': titleController.text,
      'type': type!,
      'details': descriptionController.text,
    };
    if (imageFile != null) {
      var stream = imageFile.readAsBytes().asStream();
      var length = imageFile.lengthSync();
      var multipartFile = MultipartFile('image', stream, length,
          filename: basename(imageFile.path).split('/').last);
      request.files.add(multipartFile);
    }
    request.headers.addAll(headers);
    request.fields.addAll(body);
    var response = await request.send();
    return response.statusCode;
  }

  Future chooseImage(bool fromCamera) async {
    try {
      final image = await ImagePicker().pickImage(
          source: fromCamera ? ImageSource.camera : ImageSource.gallery);
      if (image == null) return;
      if (!mounted) return;
      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);
    } on PlatformException {
      image = null;
    }
  }

  void changeIndex(String domain) {
    setState(() {
      type = domain;
    });
  }

  void imageBottomSheet(BuildContext context) {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Gallery"),
                onTap: () {
                  chooseImage(false);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text("Camera"),
                onTap: () {
                  chooseImage(true);
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  @override
  void initState() {
    SharedPreferences.getInstance().then((data) {
      String? value = data.getString('MyCookie');
      if (mounted) {
        setState(() {
          cookie = value.toString();
          csrftoken = cookie!
              .substring(cookie!.indexOf('csrf') + 10, cookie!.indexOf(';'));
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return cookie != null
        ? Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 15),
                  child: Text("Raise a Complaint",
                      style: GoogleFonts.outfit(
                          textStyle: const TextStyle(
                              fontSize: 30,
                              color: Colors.black54,
                              fontWeight: FontWeight.w600))),
                ),
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          imageBottomSheet(context);
                        },
                        child: Container(
                          decoration: const BoxDecoration(boxShadow: [
                            BoxShadow(color: Colors.grey, blurRadius: 6)
                          ]),
                          height: MediaQuery.of(context).size.width / 4,
                          width: MediaQuery.of(context).size.width / 4,
                          child: FittedBox(
                              fit: BoxFit.cover,
                              clipBehavior: Clip.hardEdge,
                              child: (image != null)
                                  ? Image.file(image!)
                                  : Image.asset(
                                      "assets/images/complaint_image.jpg")),
                        ),
                      ),
                    ),
                    if (image != null) ...[
                      Positioned(
                          right: 0,
                          top: 0,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                image = null;
                              });
                            },
                            child: SizedBox(
                              height: 20,
                              child: Image.asset("assets/icons/remove.png"),
                            ),
                          ))
                    ]
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 45,
                  child: TextFormField(
                      textAlignVertical: TextAlignVertical.center,
                      controller: titleController,
                      style: GoogleFonts.rubik(
                          textStyle: const TextStyle(
                              fontSize: 17, color: Colors.black87)),
                      decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: const BorderSide(
                                  width: 3, color: Colors.black54)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: const BorderSide(
                                  width: 2, color: Colors.black54)),
                          hintText: "Title",
                          hintStyle: GoogleFonts.rubik(
                              textStyle: const TextStyle(fontSize: 15)))),
                ),
                const SizedBox(
                  height: 20,
                ),
                MyDropDown(items: const [
                  'Mess',
                  'Maint',
                  'Sports',
                  'Tech',
                  'Network',
                  'Cult'
                ], hint: 'Complain type', changed: changeIndex),
                Padding(
                  padding: const EdgeInsets.only(top: 30, bottom: 50),
                  child: TextFormField(
                      controller: descriptionController,
                      style: GoogleFonts.rubik(
                          textStyle: const TextStyle(
                              fontSize: 15, color: Colors.black87)),
                      maxLines: 5,
                      decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                  width: 3, color: Colors.black54)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                  width: 2, color: Colors.black54)),
                          hintText: "Describe your complaint.",
                          hintStyle: GoogleFonts.rubik(
                              textStyle: const TextStyle(fontSize: 15)))),
                ),
                SizedBox(
                  height: 40,
                  width: MediaQuery.of(context).size.width,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: isSubmitting
                        ? const CircularProgressIndicator()
                        : submitStatus
                            ? Column(
                                children: [
                                  Text("Submission Successful",
                                      style: GoogleFonts.rubik(
                                          textStyle: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.green))),
                                  Text('Your concern will be addressed soon.',
                                      style: GoogleFonts.rubik(
                                          textStyle: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.green)))
                                ],
                              )
                            : SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        if (type == null) {
                                          errorText = 'Type is required!';
                                        } else if (descriptionController
                                                .text.length <
                                            5) {
                                          errorText =
                                              'Description should be 50 characters long!';
                                        } else {
                                          errorText = '';
                                          isSubmitting = true;
                                          submitComplaint(image).then((value) {
                                            isSubmitting = false;
                                            submitStatus = (value == 200);
                                            errorText = submitStatus
                                                ? ''
                                                : 'Submission failed! try again later.';

                                            setState(() {});
                                          });
                                        }
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: const StadiumBorder(),
                                      backgroundColor: Colors.red,
                                    ),
                                    child: Text('Submit Complaint',
                                        style: GoogleFonts.rubik(
                                          textStyle:
                                              const TextStyle(fontSize: 17),
                                        ))),
                              ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    errorText ??= "",
                    style: GoogleFonts.rubik(
                        textStyle:
                            const TextStyle(fontSize: 15, color: Colors.red)),
                  ),
                )
              ],
            ),
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}
