import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploader {
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<String?> uploadImage(File imageFile) async {

      File file = File(imageFile.path);
      try {
        // Create a reference to the location you want to upload to
        Reference ref = storage.ref().child('images/house.jpeg');

        // Upload the image file to Firebase Storage
        await ref.putFile(file);
        // Get the download URL
        String downloadUrl = await ref.getDownloadURL();
        print('Upload complete');
        return downloadUrl; // Return the URL

      } catch (e) {
        print('Error uploading image: $e');
      }
      return null;

  }

  Future<String> getImageUrl(String filePath) async {
    try {
      String downloadUrl = await storage.ref(filePath).getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error getting image URL: $e");
      return "";
    }
  }


}
