import 'package:flutter/material.dart';

class TextComposer extends StatefulWidget {


  TextComposer(this.sendMessege);

  Function(String) sendMessege;

  @override
  State<TextComposer> createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {

  final TextEditingController _controller = TextEditingController();

  bool _isComposing = false;

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
              onPressed: (){

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
                  widget.sendMessege(text);
                  _reset();
                },
              ),
          ),
          IconButton(
            icon: Icon(Icons.send),
              onPressed: _isComposing ? (){
                widget.sendMessege(_controller.text);
                _reset();
              } :null,
          ),
        ],
      ),
    );
  }
}
