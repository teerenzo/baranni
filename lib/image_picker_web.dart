// <<<<<<< HEAD
// // import 'dart:async';
// // import 'package:barrani/image_picker_platform.dart';
// // import 'package:flutter/foundation.dart';
// // import 'package:image_picker/image_picker.dart';
// // import 'dart:html' as html;
// //
// //
// // class ImagePickerWeb extends ImagePickerPlatform{
// //   Future<XFile?> pickImage() async {
// //     if (kIsWeb) {
// //       // Web-specific image picking code
// //
// //       final Completer<XFile?> completer = Completer();
// //
// //       final input = html.FileUploadInputElement()..accept = 'image/*';
// //       input.click();
// //
// //       input.onChange.listen((e) {
// //         final file = input.files!.first;
// //         final reader = html.FileReader();
// //
// //         reader.readAsDataUrl(file);
// //         reader.onLoadEnd.listen((e) {
// //           // Convert the data URL to an XFile and complete the Future
// //           completer.complete(XFile(reader.result as String));
// //         });
// //       });
// //
// //       return completer.future;
// //
// //     } else {
// //       // Mobile-specific image picking code
// //
// //       final ImagePicker picker = ImagePicker();
// //
// //       // Use the picker to pick an image and return it
// //       return await picker.pickImage(source: ImageSource.gallery, );
// //     }
// //   }
// //
// // }
// //
// //
// //
// =======
// import 'dart:async';
// import 'dart:html' as html;

// import 'package:barrani/image_picker_platform.dart';
// import 'package:flutter/foundation.dart';
// import 'package:image_picker/image_picker.dart';

// class ImagePickerWeb extends ImagePickerPlatform {
//   @override
//   Future<XFile?> pickImage() async {
//     if (kIsWeb) {
//       // Web-specific image picking code

//       final Completer<XFile?> completer = Completer();

//       final input = html.FileUploadInputElement()..accept = 'image/*';
//       input.click();

//       input.onChange.listen((e) {
//         final file = input.files!.first;
//         final reader = html.FileReader();

//         reader.readAsDataUrl(file);
//         reader.onLoadEnd.listen((e) {
//           // Convert the data URL to an XFile and complete the Future
//           completer.complete(XFile(reader.result as String));
//         });
//       });

//       return completer.future;
//     } else {
//       // Mobile-specific image picking code

//       final ImagePicker picker = ImagePicker();

//       // Use the picker to pick an image and return it
//       return await picker.pickImage(
//         source: ImageSource.gallery,
//       );
//     }
//   }
// }
// >>>>>>> 662beb8f63b58e5eec3ab04bc1a39162872d6eea
