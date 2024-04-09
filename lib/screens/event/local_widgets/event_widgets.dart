import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Event extends StatefulWidget {
  const Event(
      {super.key,
      required this.title,
      required this.detail,
      required this.posturl});

  final String title;
  final String detail;
  final String posturl;

  @override
  State<Event> createState() => _EventState();
}

class _EventState extends State<Event> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Card(
        shadowColor: Colors.transparent,
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(15, 10, 10, 10),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      foregroundImage: AssetImage("assets/images/logo.png"),
                      backgroundColor: Colors.transparent,
                    ),
                    const SizedBox(width: 10),
                    Text(widget.title,
                        style: GoogleFonts.volkhov(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87)),
                  ],
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 1.5,
                child: InteractiveViewer(
                  // Allows zooming to the full image size
                  minScale: 0.5, // Adjust this as needed
                  maxScale: 3.0, // Adjust this as needed
                  child: Image.network(
                    widget.posturl.toString(),
                    fit: BoxFit
                        .fitWidth, // You can choose the BoxFit that suits your layout
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                alignment: Alignment.topLeft,
                child: Text(widget.detail.toString(),
                    textAlign: TextAlign.justify,
                    style: GoogleFonts.ubuntu(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w400)),
              ),
              const Divider()
            ],
          ),
        ),
      ),
    );
  }
}
