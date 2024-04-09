import 'package:flutter/material.dart';

class InventoryCard extends StatefulWidget {
  final String name;
  final String imageurl;
  final String quantity;
  final String location;

  const InventoryCard({
    super.key,
    required this.name,
    required this.imageurl,
    required this.quantity,
    required this.location,
  });

  @override
  State<InventoryCard> createState() => _InventoryCardState();
}

class _InventoryCardState extends State<InventoryCard> {
  bool isReported = false;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: MediaQuery.of(context).size.height / 7,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(
              flex: 3,
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Image.network(
                  widget.imageurl,
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(),
            ),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Location: ${widget.location}",
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        color: Colors.black54),
                  ),
                  Text(
                    (int.parse(widget.quantity) == 0)
                        ? "Not available"
                        : "Available: ${widget.quantity}",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        color: (int.parse(widget.quantity) == 0)
                            ? Colors.red
                            : Colors.green),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
