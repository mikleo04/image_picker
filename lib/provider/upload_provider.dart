import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image/image.dart' as img;
import 'package:take_image/data/api/api_service.dart';
import 'package:take_image/data/model/upload_response.dart';

class UploadProvider extends ChangeNotifier {
  final ApiService apiService;

  bool isUploading = false;
  String message = "";
  UploadResponse? uploadResponse;

  UploadProvider(this.apiService);

  Future<void> upload(
    List<int> bytes,
    String fileName,
    String description,
  ) async {
    try {
      message = "";
      uploadResponse = null;
      isUploading = true;
      notifyListeners();

      uploadResponse =
          await apiService.uploadDocument(bytes, fileName, description);
      message = uploadResponse?.message ?? "success";
      isUploading = false;
      notifyListeners();
    } catch (e) {
      isUploading = false;
      message = e.toString();
      notifyListeners();
    }
  }

  Future<List<int>> compressImage(List<int> bytes) async {
    int imageLength = bytes.length;
    if (imageLength < 1000000) return bytes;

    final img.Image image = img.decodeImage(Uint8List.fromList(bytes))!;
    int compressQuality = 100;
    int length = imageLength;
    List<int> newByte = [];
    do {
      ///
      compressQuality -= 10;
      newByte = img.encodeJpg(
        image,
        quality: compressQuality,
      );
      length = newByte.length;
    } while (length > 1000000);
    return newByte;
  }

  Future<List<int>> resizeImage(List<int> bytes) async {
    int imageLength = bytes.length;
    if (imageLength < 1000000) return bytes;

    final img.Image image = img.decodeImage(Uint8List.fromList(bytes))!;
    bool isWidthMoreTaller = image.width > image.height;
    int imageTall = isWidthMoreTaller ? image.width : image.height;
    double compressTall = 1;
    int length = imageLength;
    List<int> newByte = bytes;

    do {
      ///
      compressTall -= 0.1;

      final newImage = img.copyResize(
        image,
        width: isWidthMoreTaller ? (imageTall * compressTall).toInt() : null,
        height: !isWidthMoreTaller ? (imageTall * compressTall).toInt() : null,
      );

      length = newImage.length;
      if (length < 1000000) {
        newByte = img.encodeJpg(newImage);
      }
    } while (length > 1000000);

    return newByte;
  }
}
