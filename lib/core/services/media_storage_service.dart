import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Copia arquivos de mídia (fotos de cartões, vídeos do Diário de
/// Vídeo) para uma pasta permanente dentro da área de dados do
/// próprio app.
///
/// O `image_picker` costuma devolver arquivos guardados numa pasta
/// de CACHE temporário do sistema — que o Android/iOS pode limpar
/// sozinho a qualquer momento para liberar espaço, fazendo fotos e
/// vídeos sumirem sem aviso, mesmo com o registro continuando salvo
/// no banco de dados. Este serviço resolve isso: sempre que uma
/// mídia é escolhida, ela é copiada para uma pasta que só o próprio
/// app controla, e é esse novo caminho que deve ser salvo no Hive.
class MediaStorageService {
  MediaStorageService._();

  static const _subfolder = 'fala_comigo_media';

  /// Copia [sourcePath] para a pasta permanente do app e devolve o
  /// novo caminho definitivo.
  static Future<String> persistFile(String sourcePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory('${appDir.path}/$_subfolder');
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }

    final extension =
        sourcePath.contains('.') ? sourcePath.substring(sourcePath.lastIndexOf('.')) : '';
    final fileName = '${DateTime.now().millisecondsSinceEpoch}$extension';
    final destinationPath = '${mediaDir.path}/$fileName';

    await File(sourcePath).copy(destinationPath);
    return destinationPath;
  }

  /// Remove um arquivo salvo permanentemente (usado ao excluir um
  /// cartão ou vídeo, para não deixar lixo ocupando espaço).
  static Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
