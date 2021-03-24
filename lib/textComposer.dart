import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class TextComposer extends StatefulWidget {
  TextComposer(this.sendMessage);
  final Function({String text, File imgFile}) sendMessage;
  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  final TextEditingController _controler = TextEditingController();
  bool _isComposing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.photo_camera),
            onPressed: () async {
              final File imgFile =
                  await ImagePicker.pickImage(source: ImageSource.gallery);
              if (imgFile == null) return;
              widget.sendMessage(imgFile: imgFile);
            },
          ),
          Expanded(
            child: TextField(
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.multiline,
              minLines: 1,
              maxLines: 3,
              controller: _controler,
              decoration: InputDecoration.collapsed(hintText: "Send message"),
              onChanged: (text) {
                setState(() {
                  _isComposing = text.isNotEmpty;
                });
              },
            ),
          ),
          IconButton(
            onPressed: _isComposing
                ? () {
                    widget.sendMessage(text: _controler.text);
                    _controler.clear();
                    setState(() {
                      _isComposing = false;
                    });
                  }
                : null,
            icon: Icon(Icons.send),
          )
        ],
      ),
    );
  }
}
