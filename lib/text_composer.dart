import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {


  TextComposer(this.sendMessege);

  final Function({String text, PickedFile imgFile}) sendMessege;

  @override
  State<TextComposer> createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {

  final TextEditingController _controller = TextEditingController();

  bool _isComposing = false;

  var picker = ImagePicker();

  void _reset(){
    _controller.clear();
    setState((){
      _isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: <Widget>[
          IconButton(icon: Icon(Icons.photo_camera),
              onPressed: () async {
                final PickedFile imgFile =
                  await picker.getImage(source: ImageSource.camera);
                final File file = File(imgFile.path);
                if (file == null) return;
                widget.sendMessege(imgFile: imgFile);
              },
          ),
          Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration.collapsed(hintText: 'Enviar uma mensagem'),
                onChanged: (text){
                  setState((){
                    _isComposing = text.isNotEmpty;
                  });
                },
                onSubmitted: (text){
                  widget.sendMessege(text: text);
                  _reset();
                },
              ),
          ),
          IconButton(
            icon: Icon(Icons.send),
              onPressed: _isComposing ? (){
                widget.sendMessege(text: _controller.text);
                _reset();
              } :null,
          ),
        ],
      ),
    );
  }
}
