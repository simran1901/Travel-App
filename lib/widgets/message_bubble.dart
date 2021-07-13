import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  MessageBubble(
    this.message,
    // this.userName,
    // this.userImage,
    this.isMe, {
    this.key,
  });

  final Key key;
  final String message;
  // final String userName;
  // final String userImage;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return 
        Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width/1.8),
              decoration: BoxDecoration(
                color: isMe ? Colors.pink[200] : Colors.orange[200],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(isMe ? 12 : 0),
                  bottomRight: Radius.circular(isMe ? 0 : 12),
                ),
              ),
              // width: 140,
              padding: EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 15,
              ),
              margin: EdgeInsets.symmetric(
                vertical: 3,
                horizontal: 8,
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: <Widget>[
                  // Text(
                  //   userName,
                  //   style: TextStyle(
                  //     fontWeight: FontWeight.bold,
                  //     color: isMe
                  //         ? Colors.white
                  //         : Theme.of(context).accentTextTheme.headline6.color,
                  //   ),
                  // ),
                  Text(
                    message,
                    style: TextStyle(
                      color: isMe
                          ? Colors.white
                          : Theme.of(context).accentTextTheme.headline6.color,
                    ),
                    textAlign: isMe ? TextAlign.end : TextAlign.start,
                  ),
                ],
              ),
            ),
          ],
        );
        // Positioned(
        //   top: 0,
        //   left: isMe ? null : 120,
        //   right: isMe ? 120 : null,
        //   child: CircleAvatar(
        //     backgroundImage: NetworkImage(userImage),
        //   ),
        // ),
      
  }
}
