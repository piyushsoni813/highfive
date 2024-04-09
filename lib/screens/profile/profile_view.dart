import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:highfive/screens/api.dart';
import 'package:highfive/screens/authentication/login_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:highfive/user.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:pinput/pinput.dart';
import 'package:http/http.dart';
import 'package:path/path.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:highfive/screens/authentication/change_pswd.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final pinController = TextEditingController();
  final nicknameController = TextEditingController();
  final roomNumberController = TextEditingController();
  final mobileNumberController = TextEditingController();

  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

  int machineCount = 0;

  String? nameError;
  String? roomError;
  String? mobileError;
  String? imageError;

  File? image;
  int indexCoverImage = 1;
  bool isEdit = false;

  String? machineID;

  late String csrftoken;
  late String cookie;

  void getID(String? id) {
    setState(() {
      machineID = id;
    });
  }

  void nextCoverImage() {
    setState(() {
      if (indexCoverImage >= 7) {
        indexCoverImage = 1;
      } else {
        indexCoverImage++;
      }
    });
  }

  Future<Response> _signOut() async {
    var response = await get(Uri.parse(apiLogout), headers: {
      'Content-Type': "application/json",
      'Cookie': cookie,
      'X-CSRFToken': csrftoken
    });

    return response;
  }

  Future<Response> regMachines() {
    return get(Uri.parse(apiReg), headers: <String, String>{
      HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
      HttpHeaders.cookieHeader: cookie,
      'X-CSRFToken': csrftoken
    });
  }

  Future<Response> pinSubmit({required String id, required String pin}) {
    return post(
      Uri.parse(apiCheckPin),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.cookieHeader: cookie,
        'Referer': host,
        'X-CSRFToken': csrftoken
      },
      body: jsonEncode(<String, String>{'id': id, 'pin': pin}),
    );
  }

  Future<Response> saveProfile(File? imageFile, String nickName,
      String roomNumber, String mobileNumber) async {
    var request = MultipartRequest('POST', Uri.parse(apiSaveProfile));
    var headers = {
      'Content-Type': "application/json",
      'Cookie': cookie,
      'Referer': host,
      'X-CSRFToken': csrftoken
    };
    var body = {
      'nickName': nickName,
      'roomNumber': roomNumber,
      'mobileNumber': mobileNumber
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
    return Response.fromStream(response);
  }

  Future chooseImage(bool fromCamera) async {
    try {
      final image = await ImagePicker().pickImage(
          source: fromCamera ? ImageSource.camera : ImageSource.gallery);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() {
        this.image = imageTemp;
        imageError = null;
      });
    } on PlatformException {
      image = null;
    }
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
      cookie = value.toString();
      csrftoken =
          cookie.substring(cookie.indexOf('csrf') + 10, cookie.indexOf(';'));
      regMachines().then((value) {
        if (value.statusCode == 200) {
          var state = jsonDecode(value.body);
          if (mounted) {
            setState(() {
              machineCount = state['count'];
            });
          }
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    pinController.dispose();
    nicknameController.dispose();
    roomNumberController.dispose();
    mobileNumberController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    const focusedBorderColor = Color.fromRGBO(23, 171, 144, 1);
    const fillColor = Color.fromRGBO(243, 246, 249, 0);
    const borderColor = Color.fromRGBO(23, 171, 144, 0.4);

    final defaultPinTheme = PinTheme(
      width: 40,
      height: 40,
      textStyle: const TextStyle(
        fontSize: 20,
        color: Color.fromRGBO(30, 60, 87, 1),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        title: Text(
          user.isCompleted ? 'Profile' : 'Complete your Profile',
          style: GoogleFonts.rubik(textStyle: const TextStyle(fontSize: 20)),
        ),
        centerTitle: true,
        leading: IconButton(
            splashRadius: 20,
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_rounded)),
      ),
      body: Consumer<User>(builder: (context, data, _) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            InkWell(
              onTap: nextCoverImage,
              child: Image.asset(
                "assets/images/cover$indexCoverImage.jpg",
                height: MediaQuery.of(context).size.height / 2.8,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
            ),
            Column(
              children: [
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      Expanded(
                        child: FittedBox(
                          alignment: Alignment.bottomCenter,
                          fit: BoxFit.none,
                          child: Stack(
                            children: [
                              SizedBox(
                                height: 120,
                                width: 120,
                                child: ClipOval(
                                  child: Container(
                                    color: Colors.white,
                                    padding: const EdgeInsets.all(4),
                                    child: ClipOval(
                                      child: FullScreenWidget(
                                        disposeLevel: DisposeLevel.High,
                                        child: (image != null)
                                            ? Image.file(
                                                image!,
                                                fit: BoxFit.cover,
                                              )
                                            : (user.image != null)
                                                ? Image.network(
                                                    host + user.image!,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.asset(
                                                    'assets/icons/man.png'),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (isEdit || !user.isCompleted)
                                Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: InkWell(
                                      onTap: () {
                                        imageBottomSheet(context);
                                      },
                                      child: SizedBox(
                                        height: 45,
                                        width: 45,
                                        child: ClipOval(
                                          child: Container(
                                            padding: const EdgeInsets.all(3),
                                            color: Colors.white,
                                            child: ClipOval(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                color: Colors.blue.shade800,
                                                child: const Icon(
                                                  Icons.add_a_photo,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ))
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 15, 5, 5),
                        child: Text(
                          imageError ?? '',
                          style: GoogleFonts.roboto(
                              color: Colors.red,
                              fontSize: 15,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 8,
                  child: Container(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(40))),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 15,
                        ),
                        Expanded(
                          flex: 1,
                          child: FittedBox(
                            fit: BoxFit.none,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      user.name,
                                      style: GoogleFonts.nunito(
                                          textStyle: TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue.shade900)),
                                    ),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    Tooltip(
                                      message: !user.isCompleted
                                          ? 'incomplete'
                                          : user.isVerfied
                                              ? 'verified'
                                              : 'unverified',
                                      triggerMode: TooltipTriggerMode.tap,
                                      child: Image(
                                        image: AssetImage(!user.isCompleted
                                            ? 'assets/icons/incomplete.png'
                                            : user.isVerfied
                                                ? 'assets/icons/verified.png'
                                                : 'assets/icons/unverified.png'),
                                        height: 25,
                                        width: 25,
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.center,
                                      ),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Text(
                                    user.roll,
                                    style: GoogleFonts.nunito(
                                        textStyle: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade600)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        (isEdit || !user.isCompleted)
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 50,
                                    width: MediaQuery.of(context).size.width,
                                    child: TextFormField(
                                      controller: nicknameController,
                                      style: TextStyle(
                                          color: Colors.blue[700],
                                          fontWeight: FontWeight.bold),
                                      onChanged: (value) {
                                        setState(() {
                                          nameError = null;
                                        });
                                      },
                                      decoration: InputDecoration(
                                          fillColor: Colors.blue[50],
                                          filled: true,
                                          hintText: "Nick Name",
                                          hintStyle: GoogleFonts.nunito(
                                              textStyle: TextStyle(
                                                  color: Colors.blue.shade500,
                                                  fontWeight: FontWeight.w600)),
                                          prefixIcon: Icon(
                                            Icons.person_4_rounded,
                                            color: Colors.blue.shade600,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              borderSide: BorderSide(
                                                  color: nameError == null
                                                      ? Colors.transparent
                                                      : Colors.red,
                                                  width: 1)),
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              borderSide: BorderSide(
                                                  color: nameError == null
                                                      ? Colors.transparent
                                                      : Colors.red,
                                                  width: 1))),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(15, 5, 5, 5),
                                    child: Text(
                                      nameError ?? '',
                                      style: GoogleFonts.roboto(
                                          color: Colors.red, fontSize: 12),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 50,
                                    width: MediaQuery.of(context).size.width,
                                    child: TextFormField(
                                      controller: roomNumberController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      style: TextStyle(
                                          color: Colors.blue[700],
                                          fontWeight: FontWeight.bold),
                                      onChanged: (value) {
                                        setState(() {
                                          roomError = null;
                                        });
                                      },
                                      decoration: InputDecoration(
                                          fillColor: Colors.blue[50],
                                          filled: true,
                                          errorStyle: const TextStyle(
                                              color: Colors.redAccent,
                                              fontWeight: FontWeight.w600),
                                          hintText: "Room Number",
                                          hintStyle: GoogleFonts.nunito(
                                              textStyle: TextStyle(
                                                  color: Colors.blue.shade500,
                                                  fontWeight: FontWeight.w600)),
                                          prefixIcon: Icon(
                                            Icons.meeting_room_rounded,
                                            color: Colors.blue.shade600,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              borderSide: BorderSide(
                                                  color: roomError == null
                                                      ? Colors.transparent
                                                      : Colors.red,
                                                  width: 1)),
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              borderSide: BorderSide(
                                                  color: roomError == null
                                                      ? Colors.transparent
                                                      : Colors.red,
                                                  width: 1))),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(15, 5, 5, 5),
                                    child: Text(
                                      roomError ?? '',
                                      style: GoogleFonts.roboto(
                                          color: Colors.red, fontSize: 12),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 50,
                                    width: MediaQuery.of(context).size.width,
                                    child: TextFormField(
                                      controller: mobileNumberController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      style: TextStyle(
                                          color: Colors.blue[700],
                                          fontWeight: FontWeight.bold),
                                      onChanged: (value) {
                                        setState(() {
                                          mobileError = null;
                                        });
                                      },
                                      decoration: InputDecoration(
                                          fillColor: Colors.blue[50],
                                          filled: true,
                                          errorStyle: const TextStyle(
                                              color: Colors.redAccent,
                                              fontWeight: FontWeight.w600),
                                          hintText: "Mobile Number",
                                          hintStyle: GoogleFonts.nunito(
                                              textStyle: TextStyle(
                                                  color: Colors.blue.shade500,
                                                  fontWeight: FontWeight.w600)),
                                          prefixIcon: Icon(
                                            Icons.phonelink_ring_rounded,
                                            color: Colors.blue.shade600,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              borderSide: BorderSide(
                                                  color: mobileError == null
                                                      ? Colors.transparent
                                                      : Colors.red,
                                                  width: 1)),
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              borderSide: BorderSide(
                                                  color: mobileError == null
                                                      ? Colors.transparent
                                                      : Colors.red,
                                                  width: 1))),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(15, 5, 5, 5),
                                    child: Text(
                                      mobileError ?? '',
                                      style: GoogleFonts.roboto(
                                          color: Colors.red, fontSize: 12),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: const EdgeInsets.all(8),
                                    margin: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(20)),
                                        color: Colors.transparent,
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.blue.shade100),
                                        ]),
                                    child: Row(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                              left: 20, right: 40),
                                          child: Icon(
                                            Icons.person_2,
                                            color: Colors.blue.shade900,
                                            size: 20,
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                              'Nick Name',
                                              style: GoogleFonts.nunito(
                                                  textStyle: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors
                                                          .blue.shade600)),
                                            ),
                                            Text(
                                              user.nickname ??
                                                  'Set Your Nick Name',
                                              style: GoogleFonts.nunito(
                                                  textStyle: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors
                                                          .blue.shade900)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: const EdgeInsets.all(8),
                                    margin: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(20)),
                                        color: Colors.transparent,
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.blue.shade100),
                                        ]),
                                    child: Row(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                              left: 20, right: 40),
                                          child: Icon(
                                            Icons.meeting_room_rounded,
                                            color: Colors.blue.shade900,
                                            size: 20,
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                              'Room Number',
                                              style: GoogleFonts.nunito(
                                                  textStyle: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors
                                                          .blue.shade600)),
                                            ),
                                            Text(
                                              user.room ?? 'Update this',
                                              style: GoogleFonts.nunito(
                                                  textStyle: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors
                                                          .blue.shade900)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: 60,
                                    width: MediaQuery.of(context).size.width,
                                    padding: const EdgeInsets.all(8),
                                    margin: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(20)),
                                        color: Colors.transparent,
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.blue.shade100),
                                        ]),
                                    child: Row(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                              left: 20, right: 40),
                                          child: Icon(
                                            Icons.phone_iphone_rounded,
                                            color: Colors.blue.shade900,
                                            size: 20,
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                              'Mobile Number',
                                              style: GoogleFonts.nunito(
                                                  textStyle: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors
                                                          .blue.shade600)),
                                            ),
                                            Text(
                                              user.mobile ?? 'Update this',
                                              style: GoogleFonts.nunito(
                                                  textStyle: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors
                                                          .blue.shade900)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                        if (!isEdit)
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const PasswordChange(),
                                  ));
                            },
                            child: const Text("Change Password"),
                          ),
                        (!isEdit && user.isCompleted)
                            ? Expanded(
                                flex: 1,
                                child: FittedBox(
                                  fit: BoxFit.none,
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Text(
                                            'Update Your Profile',
                                            style: GoogleFonts.nunito(
                                                textStyle: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        Colors.blue.shade900)),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) =>
                                                        AlertDialog(
                                                            content: Text(
                                                              "Enter the PIN on register machine to update link your ID Card or to update your profile",
                                                              style: GoogleFonts
                                                                  .ubuntu(
                                                                      fontSize:
                                                                          18),
                                                            ),
                                                            actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text(
                                                          "Close",
                                                          style: GoogleFonts
                                                              .ubuntu(
                                                                  fontSize: 18,
                                                                  color: Colors
                                                                      .blue),
                                                        ),
                                                      )
                                                    ]),
                                              );
                                            },
                                            icon: Icon(
                                              Icons.help_outline_rounded,
                                              color: Colors.blue.shade600,
                                              size: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          MyDropDown(
                                              items: List<String>.generate(
                                                  machineCount,
                                                  (index) =>
                                                      'R${(index + 1).toString()}'),
                                              hint: 'ID',
                                              changed: getID),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          Pinput(
                                            enabled: (machineID != null),
                                            controller: pinController,
                                            focusNode: focusNode,
                                            defaultPinTheme: defaultPinTheme,
                                            onCompleted: (pin) {
                                              debugPrint('onCompleted: $pin');
                                              pinSubmit(
                                                      id: machineID!,
                                                      pin: pinController.text)
                                                  .then((value) {
                                                setState(() {
                                                  if (value.statusCode == 202) {
                                                    isEdit = true;
                                                  } else {
                                                    imageError =
                                                        'Incorrect Pin';
                                                  }
                                                });
                                              });
                                            },
                                            onChanged: (value) {
                                              debugPrint('onChanged: $value');
                                              setState(() {
                                                imageError = null;
                                              });
                                            },
                                            cursor: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      bottom: 8),
                                                  width: 22,
                                                  height: 1,
                                                  color: const Color.fromRGBO(
                                                      23, 171, 144, 1),
                                                ),
                                              ],
                                            ),
                                            focusedPinTheme:
                                                defaultPinTheme.copyWith(
                                              decoration: defaultPinTheme
                                                  .decoration!
                                                  .copyWith(
                                                borderRadius:
                                                    BorderRadius.circular(7),
                                                border: Border.all(
                                                    color: focusedBorderColor,
                                                    width: 2),
                                              ),
                                            ),
                                            submittedPinTheme:
                                                defaultPinTheme.copyWith(
                                              decoration: defaultPinTheme
                                                  .decoration!
                                                  .copyWith(
                                                color: fillColor,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                    color: focusedBorderColor),
                                              ),
                                            ),
                                            disabledPinTheme:
                                                defaultPinTheme.copyWith(
                                              decoration: defaultPinTheme
                                                  .decoration!
                                                  .copyWith(
                                                borderRadius:
                                                    BorderRadius.circular(7),
                                                border: Border.all(
                                                    color: Colors.grey,
                                                    width: 1),
                                              ),
                                            ),
                                            errorPinTheme:
                                                defaultPinTheme.copyBorderWith(
                                              border: Border.all(
                                                  color: Colors.redAccent),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Expanded(
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: SizedBox(
                                    child: SizedBox(
                                      height: 50,
                                      width: MediaQuery.of(context).size.width,
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              elevation: 10,
                                              shape: const StadiumBorder(),
                                              backgroundColor: Colors.blue,
                                              shadowColor: Colors.black26),
                                          onPressed: () {
                                            if (nicknameController
                                                .text.isEmpty) {
                                              setState(() {
                                                nameError =
                                                    'Nick name is required';
                                              });
                                            } else if (roomNumberController
                                                    .text.length >
                                                12) {
                                              setState(() {
                                                nameError =
                                                    'Maximum 12 characters allowed';
                                              });
                                            }
                                            if (roomNumberController
                                                .text.isEmpty) {
                                              setState(() {
                                                roomError =
                                                    'Room number is required';
                                              });
                                            } else if (roomNumberController
                                                    .text.length >
                                                3) {
                                              setState(() {
                                                roomError =
                                                    'Invalid Room Number';
                                              });
                                            }
                                            if (mobileNumberController
                                                .text.isEmpty) {
                                              setState(() {
                                                mobileError =
                                                    'Mobile number is required';
                                              });
                                            } else if (mobileNumberController
                                                    .text.length !=
                                                10) {
                                              setState(() {
                                                mobileError =
                                                    'Mobile Number must have 10 digits';
                                              });
                                            }
                                            if (image == null &&
                                                user.image_ == null) {
                                              setState(() {
                                                imageError =
                                                    'Image is required';
                                              });
                                            }
                                            if (nameError == null &&
                                                roomError == null &&
                                                mobileError == null &&
                                                imageError == null) {
                                              saveProfile(
                                                      image,
                                                      nicknameController.text,
                                                      roomNumberController.text,
                                                      mobileNumberController
                                                          .text)
                                                  .then((value) {
                                                if (value.statusCode == 200) {
                                                  _signOut().then((value) {
                                                    Navigator.pop(context);
                                                    Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              const LoginPage(),
                                                        ));
                                                  });
                                                }
                                              });
                                            }
                                          },
                                          child: const Text(
                                            'Submit',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          )),
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                )
              ],
            )
          ],
        );
      }),
    );
  }
}

class MyDropDown extends StatefulWidget {
  final List<String> items;
  final String hint;
  final Function(String) changed;

  const MyDropDown(
      {super.key,
      required this.items,
      required this.hint,
      required this.changed});

  @override
  State<MyDropDown> createState() => _MyDropDownState();
}

class _MyDropDownState extends State<MyDropDown> {
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: DropdownButtonHideUnderline(
          child: DropdownButton2(
            isExpanded: true,
            hint: const Row(
              children: [
                Expanded(
                  child: Text(
                    'ID',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            items: widget.items
                .map((item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList(),
            value: selectedValue,
            onChanged: (value) {
              setState(() {
                selectedValue = value as String;
              });
              widget.changed(value as String);
            },
            buttonStyleData: ButtonStyleData(
              height: 40,
              width: 70,
              padding: const EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: (selectedValue == null)
                        ? Colors.red
                        : const Color.fromRGBO(23, 171, 144, 1),
                    width: 1),
                color: Colors.white,
              ),
              elevation: 0,
            ),
            iconStyleData: const IconStyleData(
              icon: Icon(
                Icons.arrow_drop_down_rounded,
              ),
              iconSize: 20,
              iconEnabledColor: Colors.black87,
              iconDisabledColor: Colors.black45,
            ),
            dropdownStyleData: DropdownStyleData(
                maxHeight: 200,
                width: 60,
                padding: null,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 1, color: Colors.black54),
                  color: Colors.white,
                ),
                elevation: 5,
                offset: const Offset(0, 0),
                scrollbarTheme: ScrollbarThemeData(
                  thumbColor: MaterialStateProperty.all(Colors.black54),
                  radius: const Radius.circular(40),
                  thickness: MaterialStateProperty.all(6),
                  thumbVisibility: MaterialStateProperty.all(true),
                )),
            menuItemStyleData: const MenuItemStyleData(
              height: 40,
              padding: EdgeInsets.only(left: 13, right: 13),
            ),
          ),
        ),
      ),
    );
  }
}
