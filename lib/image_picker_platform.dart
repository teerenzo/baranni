import 'package:barrani/image_picker_mobile.dart';
import 'package:image_picker/image_picker.dart';
export 'image_picker_web.dart' if (dart.library.io) 'image_picker_mobile.dart';

abstract class ImagePickerPlatform {
  Future<XFile?> pickImage();

  static ImagePickerPlatform get instance {
    // return kIsWeb ? ImagePickerWeb() : ImagePickerMobile();
    return ImagePickerMobile();
  }
}
