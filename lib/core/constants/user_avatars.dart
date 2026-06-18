/// Локальные аватары из [assets/user/].
/// При добавлении новых PNG в папку — допишите имя файла сюда.
const kUserAvatarFiles = [
  'enot.png',
  'kozel.png',
  'lev.png',
  'lisa.png',
  'ris.png',
  'sova.png',
  'wolf.png',
  'mich.png',
  'micka.png',
  'men1.png',
  'men2.png',
  'men3.png',
  'men4.png',
  'men5.png',
  'women1.png',
  'women2.png',
  'women3.png',
  'women4.png',
  'women5.png',
  'Gemini_Generated_Image_xncw4oxncw4oxncw (1).png',
];

String userAvatarAssetPath(String fileName) => 'assets/user/$fileName';

bool isKnownUserAvatar(String fileName) => kUserAvatarFiles.contains(fileName);

String resolveUserAvatarFile(String? fileName) {
  if (fileName != null && isKnownUserAvatar(fileName)) {
    return fileName;
  }
  return kUserAvatarFiles.first;
}
