import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  
  for (final file in files) {
    String content = file.readAsStringSync();
    if (content.contains('0xFF6366F1')) {
      content = content.replaceAll('0xFF6366F1', '0xFF0EA5E9');
      file.writeAsStringSync(content);
      print('Updated ${file.path}');
    }
  }
}
