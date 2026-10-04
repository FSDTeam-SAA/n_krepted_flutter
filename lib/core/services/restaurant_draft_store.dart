import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keeps unfinished owner submissions and selected photos across app restarts.
class RestaurantDraftStore {
  static Future<void> _tail = Future.value();
  static String _key(String userId) => 'nk_restaurant_draft_$userId';

  static Future<void> save(String userId, Map<String, dynamic> draft) {
    final task = _tail.then((_) async {
      final root = await getApplicationDocumentsDirectory();
      final folder = Directory(
        '${root.path}/restaurant_drafts/${Uri.encodeComponent(userId)}',
      );
      await folder.create(recursive: true);
      Future<List<String>> persist(List<XFile> images) async {
        final paths = <String>[];
        for (final image in images) {
          final source = File(image.path);
          if (!await source.exists()) continue;
          if (source.parent.path == folder.path) {
            paths.add(source.path);
          } else {
            final target =
                '${folder.path}/${image.path.hashCode.abs()}_${image.name.replaceAll(RegExp(r"[^a-zA-Z0-9._-]"), "_")}';
            if (!await File(target).exists()) await source.copy(target);
            paths.add(target);
          }
        }
        return paths;
      }

      final data = Map<String, dynamic>.from(draft);
      final images = (data.remove('imageFiles') as List).cast<XFile>();
      final paths = await persist(images);
      data['imagePaths'] = paths;
      final categories = (draft['newPhotoCategories'] as List).cast<String>();
      data['newPhotoCategories'] = [
        for (var i = 0; i < images.length; i++)
          if (await File(images[i].path).exists()) categories[i],
      ];
      data['signatureDishes'] = await Future.wait(
        (draft['signatureDishes'] as List).map((raw) async {
          final dish = Map<String, dynamic>.from(raw as Map);
          dish['imagePaths'] = await persist(
            (dish.remove('imageFiles') as List).cast<XFile>(),
          );
          return dish;
        }),
      );
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_key(userId), jsonEncode(data));
    });
    _tail = task.catchError((Object _) {});
    return task;
  }

  static Future<Map<String, dynamic>?> load(String userId) async {
    await _tail;
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_key(userId));
    if (raw == null) return null;
    try {
      final draft = jsonDecode(raw) as Map<String, dynamic>;
      final paths = (draft.remove('imagePaths') as List).cast<String>();
      final categories = (draft['newPhotoCategories'] as List).cast<String>();
      draft['imageFiles'] = [
        for (final path in paths)
          if (await File(path).exists()) XFile(path),
      ];
      draft['newPhotoCategories'] = [
        for (var i = 0; i < paths.length; i++)
          if (await File(paths[i]).exists()) categories[i],
      ];
      for (final dish in draft['signatureDishes'] as List) {
        dish['imageFiles'] = [
          for (final path in dish.remove('imagePaths') as List)
            if (await File(path as String).exists()) XFile(path),
        ];
      }
      return draft;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear(String userId) async {
    await _tail;
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_key(userId));
  }
}
