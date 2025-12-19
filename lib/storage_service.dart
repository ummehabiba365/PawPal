import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadImage({
    required String filename,
    required Uint8List bytes,
  }) async {
    try {
      // Create reference
      final ref = _storage.ref().child('pet_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

      // Upload with metadata
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
      );

      // Upload the file
      final uploadTask = ref.putData(bytes, metadata);

      // Wait for upload
      final snapshot = await uploadTask.whenComplete(() {});

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Storage upload error: $e');
      return null; // Return null instead of throwing
    }
  }
}