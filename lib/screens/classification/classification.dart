import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:odysee/services/storage.dart';
import 'package:odysee/shared/styles.dart';
import 'package:provider/provider.dart';
import 'package:odysee/models/user.dart';

import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';

class ClassifyImage extends StatefulWidget {
  @override
  _ClassifyImageState createState() => _ClassifyImageState();
}

class _ClassifyImageState extends State<ClassifyImage> {

  File _image;
  List _recognitions;
  double _imageHeight;
  double _imageWidth;
  bool _busy = false;

  Future predictImagePicker(String uid, bool fromCamera) async {

    // if (_image != null) {
    //   _image = null;
    // }

    var imageSource = fromCamera ? ImageSource.camera : ImageSource.gallery;

    var image = await ImagePicker.pickImage(source: imageSource);
    if (image == null) return;
    setState(() {
      _busy = true;
    });
    predictImage(image);

    Storage store = Storage(fileObject: image, uid:uid);
    await store.uploadImage();
  }

  Future predictImage(File image) async {
    if (image == null) return;

    await recognizeImage(image);

    new FileImage(image)
        .resolve(new ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      setState(() {
        _imageHeight = info.image.height.toDouble();
        _imageWidth = info.image.width.toDouble();
      });
    }));

    setState(() {
      _image = image;
      _busy = false;
    });
  }

  @override
  void initState() {
    super.initState();

    _busy = true;

    loadModel().then((val) {
      setState(() {
        _busy = false; 
      });
      print('Model has been lad');
    });
  }

  Future loadModel() async {
    Tflite.close();
    try {
      String res;
      res = await Tflite.loadModel(
            model: "assets/models/odysee/model_v2.tflite",
            labels: "assets/models/odysee/labels_imagenet_slim.txt",
      );   

            print('Printing Model next');
            print(res);
    } on PlatformException catch(e) {
      print('Failed to load model.');
      print(e);
    }
  }

  Future recognizeImage(File image) async {
    print('starting RECOGNITION ...................');
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 6,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _recognitions = recognitions;
    });

    print('Recognitions:');

    print(_recognitions);

    //_recognitions.map((re) =>
    var re = _recognitions[0];

    print("${re["label"]} ${(re["confidence"] * 100).toStringAsFixed(0)}%");
  
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    List<Widget> stackChildren = [];

    final user = Provider.of<User>(context);

    List<Widget> recognitionsList () {
      return _recognitions != null
            ? _recognitions.map((res) {
                return Text(
                  "${res["label"]}: ${res["confidence"].toStringAsFixed(3)}",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                    background: Paint()..color = Colors.white,
                  ),
                );
              }).toList()
            : [] ;
    }


 
    stackChildren.add(Center(
      child: Column(
        children: [
          Container(
          child: _image == null ? Text('No image selected.') : Image.file(_image),
          alignment: Alignment.center,
          height: size.height * 0.7,
          width: size.width * 0.95
          )
        ]..addAll(recognitionsList()),
      ),
    ));


    if (_busy) {
      stackChildren.add(const Opacity(
        child: ModalBarrier(dismissible: false, color: Colors.grey),
        opacity: 0.3,
      ));
      stackChildren.add(
        
        SpinKitChasingDots(
          color: Colors.brown,
          size: 50.0
          ) 
        );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Classify Image'),
        backgroundColor: Styles.appBarStyle,
        elevation : 0.0,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
        child: Stack(
          children: stackChildren,
        ),
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: () async {
              predictImagePicker(user.uid, false );
            },
            tooltip: 'Pick Image from Gallery',
            child: Icon(Icons.image),
            heroTag: null,
          ),
          SizedBox(height: 5.0),
          FloatingActionButton(
            onPressed: () async {
              predictImagePicker(user.uid, true);
            },
            tooltip: 'Pick Image from Camera',
            child: Icon(Icons.camera),
            heroTag: null,
          ),
        ],
      )
      

    );

  }

}