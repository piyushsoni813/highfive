import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

////////////////////CALL BUTTON/////////////////////

class CallButton extends StatefulWidget {
  const CallButton({super.key, required this.phonenumber});
  final String phonenumber;

  @override
  State<CallButton> createState() => _CallButtonState();
}

class _CallButtonState extends State<CallButton> {
  bool _hasCallSupport = false;
  //Future<void>? _launched;

  @override
  void initState() {
    super.initState();
    // Check for phone call support.
    canLaunchUrl(Uri(scheme: 'tel', path: '123')).then((bool result) {
      setState(() {
        _hasCallSupport = result;
      });
    });
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: ElevatedButton(
        onPressed: _hasCallSupport
            ? () => setState(() {
                  //_launched = _makePhoneCall(widget.phonenumber)
                  _makePhoneCall(widget.phonenumber);
                })
            : null,
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            fixedSize: const Size.fromHeight(40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            )),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _hasCallSupport
                ? const Text(
                    "Call Now",
                    style: TextStyle(color: Colors.white),
                  )
                : const Text("Not Supported",
                    style: TextStyle(color: Colors.white)),
            const Expanded(child: Icon(Icons.call))
          ],
        ),
      ),
    );
  }
}
