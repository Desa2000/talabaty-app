import 'dart:io';

void main() {
  final dir = Directory('lib/features');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.contains('tabs') && f.path.endsWith('.dart'));
  
  for (var file in files) {
    String content = file.readAsStringSync();
    if (content.contains('''import '../../../''')) {
      content = content.replaceAll('''import '../../../''', '''import '../../../../''');
      file.writeAsStringSync(content);
      print('Updated: ${file.path}');
    }
  }
}
