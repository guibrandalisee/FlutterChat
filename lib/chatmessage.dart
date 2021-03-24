import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  ChatMessage(this.data, this.mine);
  final Map<String, dynamic> data;
  final bool mine;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          !mine
              ? Padding(
                  padding: EdgeInsets.only(right: 7),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(data["senderPhotoUrl"]),
                  ),
                )
              : Container(),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  data["senderName"],
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.purple),
                ),
                data["imgUrl"] != null
                    ? Image.network(
                        data["imgUrl"],
                        width: 250,
                      )
                    : Text(
                        data["text"],
                        textAlign: mine ? TextAlign.end : TextAlign.start,
                        style: TextStyle(fontSize: 13),
                      ),
              ],
            ),
          ),
          mine
              ? Padding(
                  padding: EdgeInsets.only(left: 7),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(data["senderPhotoUrl"]),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
