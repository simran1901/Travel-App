import 'package:flutter/material.dart';

class Choice extends StatelessWidget {
  final String title;
  final String url;
  final Function onPress;

  Choice(this.title, this.url, this.onPress);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onPress,
        splashColor: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(15),
        child: GridTile(
          child: FadeInImage(
            placeholder: AssetImage('assets/placeholder.png'),
            image: NetworkImage(url),
            fit: BoxFit.cover,
          ),
          footer: GridTileBar(
            title: Center(
              child: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            backgroundColor: Colors.black54,
          ),
        ),
      ),
    );
  }
}
