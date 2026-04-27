import 'dart:io';
import 'package:baatien/models/apis.dart';
import 'package:baatien/models/chat_user.dart';
import 'package:baatien/models/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:image_picker/image_picker.dart';
import 'package:screenshot/screenshot.dart';
import 'package:whiteboard/whiteboard.dart';

class InputMessage extends StatefulWidget {
  double heightForInputField;
  ChatUser user;
  List<Message>? messageList;
  InputMessage(
      {required this.heightForInputField,
      required this.user,
      required this.messageList});

  @override
  State<InputMessage> createState() => _InputMessageState();
}

bool _isTyping = false;
double _animatedContainerHeight = 75;
double? _whiteBoardHeight = null;
double _distance = 100;
bool _whiteBoardEnabled = false;
bool erase = false;
double _penStrokeWidth = 5;
double _eraserStrokeWidhth = 5;
TextEditingController _textController = TextEditingController();
bool _isUploading = false;
File? whiteBoardScribble;
ScreenshotController scribbleCaptureController = ScreenshotController();
String? scribbleURl;
bool sendingScribble = false;
Color pickerColor = Colors.blue;
Color currentColor = Colors.blue;

WhiteBoardController whiteBoardController = WhiteBoardController();

class _InputMessageState extends State<InputMessage> {
  void _expandAnimatedContainer() {
    setState(() {
      _animatedContainerHeight = widget.heightForInputField * .5;
    });
  }

  void _expandAnimatedContainerForTextInput() {
    setState(() {
      _animatedContainerHeight = widget.heightForInputField * .15;
    });
  }

  void _shrinkAnimatedContainer() {
    setState(() {
      _animatedContainerHeight = widget.heightForInputField * .11;
      _isUploading = false;
    });
  }

  void _showWhiteBoard() {
    setState(() {
      _whiteBoardHeight = 60;
      _distance = 0;
      _whiteBoardEnabled = true;
      _isTyping = false;
    });
    Future.delayed(const Duration(milliseconds: 50), () {
      setState(() {
        _whiteBoardHeight = 300;
      });
    });
  }

  void _hideWhiteBoard() {
    setState(() {
      _whiteBoardHeight = 60;
      _whiteBoardEnabled = false;
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        _distance = 100;
        _whiteBoardHeight = null;
      });
    }).then((value) => _shrinkAnimatedContainer());
  }

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  void _selectPicker() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pick a color!'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: changeColor,
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text(
              'Got it',
              style: TextStyle(fontFamily: "Poppins"),
            ),
            onPressed: () {
              setState(() => currentColor = pickerColor);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _adjustPenStrokeWidth() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Container(
          width: MediaQuery.of(context).size.width * .9,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
          ),
          child: StatefulBuilder(builder: (context, state) {
            return Slider(
              value: _penStrokeWidth,
              min: 1,
              max: 50,
              divisions: 50,
              label: _penStrokeWidth.round().toString(),
              onChanged: (double value) {
                state(() {
                  _penStrokeWidth = value;
                });
                setState(() {});
              },
            );
          }),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              "Set",
              style: TextStyle(fontFamily: "Poppins"),
            ),
          ),
        ],
      ),
    );
  }

  void _adjustEraserStrokeWidth() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Container(
          width: MediaQuery.of(context).size.width * .9,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
          ),
          child: StatefulBuilder(builder: (context, state) {
            return Slider(
              value: _eraserStrokeWidhth,
              min: 1,
              max: 50,
              divisions: 50,
              label: _eraserStrokeWidhth.round().toString(),
              onChanged: (double value) {
                state(() {
                  _eraserStrokeWidhth = value;
                });
                setState(() {});
              },
            );
          }),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              "Set",
              style: TextStyle(fontFamily: "Poppins"),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    _isTyping = false;
    _animatedContainerHeight = widget.heightForInputField * .11;
    _whiteBoardHeight = 60;
    _distance = 100;
    _whiteBoardEnabled = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _animatedContainerHeight,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButtonLocation: _isTyping
            ? _textController.text != ""
                ? null
                : ExpandableFab.location
            : _whiteBoardEnabled
                ? FloatingActionButtonLocation.endFloat
                : ExpandableFab.location,
        floatingActionButton: _whiteBoardEnabled
            ? sendingScribble
                ? FloatingActionButton(
                    onPressed: () {},
                    child: const CircularProgressIndicator(
                      color: Color.fromARGB(255, 255, 235, 176),
                    ),
                  )
                : FloatingActionButton(
                    splashColor: Colors.black38,
                    backgroundColor: Colors.amber,
                    onPressed: () async {
                      setState(() {
                        sendingScribble = true;
                      });
                      final image = await scribbleCaptureController.capture();
                      await APIs.sendScribble(widget.user, image!)
                          .then((value) => whiteBoardController.clear());
                      setState(() {
                        sendingScribble = false;
                      });
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Icon(
                        Icons.send_outlined,
                        size: 30,
                      ),
                    ),
                  )
            : _isTyping && _textController.text != ""
                ? FloatingActionButton(
                    splashColor: Colors.black38,
                    backgroundColor: Colors.amber,
                    onPressed: () {
                      if (_textController.text != "" ||
                          // ignore: unnecessary_null_comparison
                          _textController.text != null ||
                          _textController.text.isNotEmpty) {
                        _textController.text.trim();
                        if (widget.messageList!.isNotEmpty) {
                          APIs.sendMessage(
                              widget.user, _textController.text, Type.text);
                        } else {
                          APIs.sendFirstMessage(
                              widget.user, _textController.text, Type.text);
                        }
                        _textController.text = "";
                        setState(() {});
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Icon(
                        Icons.send_outlined,
                        size: 30,
                      ),
                    ),
                  )
                : _isUploading
                    ? const Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 25, horizontal: 20),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : ExpandableFab(
                        overlayStyle: ExpandableFabOverlayStyle(
                          blur: 5,
                        ),
                        distance: _distance,
                        duration: const Duration(milliseconds: 300),
                        onOpen: () => _expandAnimatedContainer(),
                        onClose: () {
                          _shrinkAnimatedContainer();
                        },
                        expandedFabSize: ExpandableFabSize.small,
                        child: const Icon(Icons.add),
                        children: [
                          FloatingActionButton.small(
                            heroTag: null,
                            child: const Icon(Icons.camera_alt_outlined),
                            onPressed: () async {
                              final ImagePicker picker = ImagePicker();
                              final XFile? image = await picker.pickImage(
                                  source: ImageSource.camera);
                              _shrinkAnimatedContainer();
                              if (image != null) {
                                setState(() {
                                  _isUploading = true;
                                });
                                await APIs.sendChatImage(
                                        widget.user, File(image.path))
                                    .then((value) => _isUploading = false);
                                setState(() {});
                              }
                            },
                          ),
                          FloatingActionButton.small(
                            heroTag: null,
                            child: const Icon(Icons.image),
                            onPressed: () async {
                              final ImagePicker picker = ImagePicker();
                              final List<XFile> images =
                                  await picker.pickMultiImage();
                              _shrinkAnimatedContainer();
                              for (var element in images) {
                                setState(() {
                                  _isUploading = true;
                                });
                                await APIs.sendChatImage(
                                        widget.user, File(element.path))
                                    .then((value) => _isUploading = false);
                                setState(() {});
                              }
                            },
                          ),
                          FloatingActionButton.small(
                            heroTag: null,
                            child: const Icon(Icons.draw_outlined),
                            onPressed: () {
                              _showWhiteBoard();
                              setState(() {});
                            },
                          ),
                        ],
                      ),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _whiteBoardEnabled
                  ? Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 8,
                              fixedSize: const Size(40, 40),
                              shadowColor: Colors.grey,
                              shape: const CircleBorder(),
                            ),
                            onPressed: () {
                              whiteBoardController.clear();
                            },
                            child: const Icon(
                              Icons.crop_square_outlined,
                              size: 30,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 8,
                              fixedSize: const Size(40, 40),
                              shadowColor: Colors.grey,
                              shape: const CircleBorder(),
                            ),
                            onPressed: () {
                              whiteBoardController.undo();
                            },
                            child: const Icon(
                              Icons.undo_outlined,
                              size: 30,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 8,
                              fixedSize: const Size(40, 40),
                              shadowColor: Colors.grey,
                              shape: const CircleBorder(),
                            ),
                            onPressed: () {
                              whiteBoardController.redo();
                            },
                            child: const Icon(
                              Icons.redo_outlined,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
              Row(
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: AnimatedContainer(
                      curve: Curves.bounceOut,
                      height: _whiteBoardEnabled
                          ? _whiteBoardHeight
                          : _whiteBoardHeight,
                      duration: const Duration(milliseconds: 1000),
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: _whiteBoardEnabled
                          ? BoxDecoration(
                              border: const Border(
                                bottom: BorderSide(width: .75),
                                top: BorderSide(width: .75),
                                right: BorderSide(width: .75),
                                left: BorderSide(width: .75),
                              ),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50),
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(0, 10),
                                    blurRadius: 10)
                              ],
                            )
                          : null,
                      child: _whiteBoardEnabled
                          ? buildWhiteBoard(context)
                          : TextFormField(
                              keyboardType: TextInputType.multiline,
                              controller: _textController,
                              maxLines: 3,
                              minLines: 1,
                              onChanged: (value) {
                                _expandAnimatedContainerForTextInput();
                                if (value == "" || value.trim() == "") {
                                  _shrinkAnimatedContainer();
                                  setState(() {
                                    _isTyping = false;
                                  });
                                } else {
                                  setState(() {
                                    _isTyping = true;
                                  });
                                }
                              },
                              decoration: InputDecoration(
                                label: const Text("Message...",
                                    style: TextStyle(fontFamily: "Poppins")),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                            ),
                    ),
                  ),
                  _whiteBoardEnabled
                      ? SizedBox(
                          height: widget.heightForInputField * .4,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(5),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: currentColor,
                                    elevation: 8,
                                    fixedSize: const Size(40, 40),
                                    shadowColor: Colors.grey,
                                    shape: const CircleBorder(),
                                  ),
                                  onPressed: () {
                                    _selectPicker();
                                  },
                                  child: const Icon(
                                    Icons.color_lens_outlined,
                                    size: 30,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    elevation: 8,
                                    fixedSize: const Size(40, 40),
                                    shadowColor: Colors.grey,
                                    shape: const CircleBorder(),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      erase = true;
                                    });
                                  },
                                  onLongPress: () {
                                    setState(() {
                                      erase = true;
                                    });
                                    _adjustEraserStrokeWidth();
                                  },
                                  child: const Icon(
                                    Icons.crop_3_2_rounded,
                                    size: 30,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    elevation: 8,
                                    fixedSize: const Size(40, 40),
                                    shadowColor: Colors.grey,
                                    shape: const CircleBorder(),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      erase = false;
                                    });
                                  },
                                  onLongPress: () {
                                    setState(() {
                                      erase = false;
                                    });
                                    _adjustPenStrokeWidth();
                                  },
                                  child: const Icon(
                                    Icons.create_outlined,
                                    size: 30,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    elevation: 8,
                                    fixedSize: const Size(40, 40),
                                    shadowColor: Colors.grey,
                                    shape: const CircleBorder(),
                                  ),
                                  onPressed: () {
                                    if (!sendingScribble) _hideWhiteBoard();
                                  },
                                  child: sendingScribble
                                      ? const SizedBox()
                                      : const Icon(
                                          Icons.close,
                                          size: 30,
                                        ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : SizedBox(
                          width: MediaQuery.of(context).size.width * .2,
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildWhiteBoard(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
    ),
    child: Stack(
      alignment: Alignment.center,
      children: [
        Screenshot(
          controller: scribbleCaptureController,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: WhiteBoard(
              controller: whiteBoardController,
              isErasing: erase,
              strokeColor: currentColor,
              strokeWidth: erase ? _eraserStrokeWidhth : _penStrokeWidth,
            ),
          ),
        ),
        sendingScribble
            ? const Expanded(child: CircularProgressIndicator())
            : const SizedBox(),
      ],
    ),
  );
}
