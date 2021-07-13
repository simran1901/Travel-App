import 'package:flutter/material.dart';

class SeatLayout extends StatefulWidget {
  SeatLayout(this.seatSelect, this.bookedSeats);

  final List<dynamic> bookedSeats;
  final void Function(
    List<int> seats,
  ) seatSelect;

  @override
  _SeatLayoutState createState() => _SeatLayoutState();
}

class _SeatLayoutState extends State<SeatLayout> {
  List<int> index = [];
  @override
  Widget build(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: ScrollPhysics(),
      children: [
        GridView.builder(
          primary: false,
          physics: ScrollPhysics(),
          itemCount: 20,
          itemBuilder: (ctx, i) => IconButton(
            icon: Icon(
              Icons.event_seat,
              size: 40,
              color: widget.bookedSeats.contains(i)
                  ? Theme.of(context).primaryColor
                  : index.contains(i)
                      ? Colors.green
                      : Colors.grey,
            ),
            onPressed: widget.bookedSeats.contains(i)
                ? null
                : () {
                    setState(() {
                      if (index.contains(i))
                        index.removeWhere((element) => element == i);
                      else
                        index.add(i);
                      widget.seatSelect(index);
                    });
                  },
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 4 / 2,
            crossAxisSpacing: 1,
            mainAxisSpacing: 6,
          ),
        ),
        GridView.builder(
          primary: false,
          physics: ScrollPhysics(),
          itemCount: 20,
          itemBuilder: (ctx, i) => IconButton(
            icon: Icon(
              Icons.event_seat,
              size: 40,
              color: widget.bookedSeats.contains(20 + i)
                  ? Theme.of(context).primaryColor
                  : index.contains(20 + i)
                      ? Colors.green
                      : Colors.grey,
            ),
            onPressed: widget.bookedSeats.contains(20 + i)
                ? null
                : () {
                    setState(() {
                      if (index.contains(20 + i))
                        index.removeWhere((element) => element == (20 + i));
                      else
                        index.add(20 + i);
                      widget.seatSelect(index);
                    });
                  },
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 4 / 2,
            crossAxisSpacing: 1,
            mainAxisSpacing: 6,
          ),
        ),
      ],
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 4 / 10,
        crossAxisSpacing: 70,
        mainAxisSpacing: 1,
      ),
    );
  }
}
