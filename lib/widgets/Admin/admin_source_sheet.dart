import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class AdminImageSourceSheet extends StatelessWidget {
  const AdminImageSourceSheet(this.onImageSelected, {super.key});
  final Function(XFile) onImageSelected;

  void imageSelected(XFile image) async {
    final CroppedFile? croppedImage = await ImageCropper().cropImage(sourcePath: image.path);

    XFile? finalImage;
    if (croppedImage != null) {
      // Converter de CroppedFile para XFile
      finalImage = XFile(croppedImage.path);
    } else {
      // Se croppedImage for null, use a imagem original
      finalImage = image;
    }

    onImageSelected(finalImage);
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      onClosing: () {},
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () async {
              XFile? image = await ImagePicker().pickImage(source: ImageSource.camera);
              if (image != null) {
                imageSelected(image);
              }
            },
            child: const Text("Câmera"),
          ),
          TextButton(
            onPressed: () async {
              XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
              if (image != null) {
                imageSelected(image);
              }
            },
            child: const Text("Galeria"),
          ),
        ],
      ),
    );
  }
}
