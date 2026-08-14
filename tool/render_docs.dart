import 'dart:convert';
import 'dart:io';

void main(List<String> arguments) {
  final check = arguments.contains('--check');
  final root = Directory.current;
  final files =
      <File>[
        File('${root.path}${Platform.pathSeparator}RULES.md'),
        File(
          '${root.path}${Platform.pathSeparator}.specify${Platform.pathSeparator}memory${Platform.pathSeparator}constitution.md',
        ),
        ...Directory('${root.path}${Platform.pathSeparator}specs')
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) => file.path.endsWith('.md')),
      ].where((file) => file.existsSync()).toList()..sort(
        (a, b) => a.path.compareTo(b.path),
      );

  var failed = false;
  for (final source in files) {
    final target = File(
      source.path.substring(0, source.path.length - 3) + '.html',
    );
    final rendered = _render(source.readAsStringSync());
    if (check) {
      if (!target.existsSync() || target.readAsStringSync() != rendered) {
        stderr.writeln('Outdated or missing: ${target.path}');
        failed = true;
      }
    } else {
      target.writeAsStringSync(rendered);
      stdout.writeln('Rendered ${target.path}');
    }
  }
  if (failed) exitCode = 1;
}

String _render(String markdown) {
  final out = StringBuffer('''<!doctype html>
<html lang="zh-CN"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<style>body{font:16px/1.65 system-ui,sans-serif;max-width:980px;margin:32px auto;padding:0 20px;color:#202124}h1,h2,h3{line-height:1.25}code,pre{font-family:ui-monospace,monospace;background:#f4f5f6}code{padding:2px 4px}pre{padding:14px;overflow:auto;border-radius:4px}li{margin:4px 0}blockquote{border-left:3px solid #aaa;padding-left:12px;color:#555}</style></head><body>
''');
  var inCode = false;
  var inList = false;
  final lines = const LineSplitter().convert(markdown);
  for (final raw in lines) {
    if (raw.startsWith('```')) {
      if (inList) {
        out.writeln('</ul>');
        inList = false;
      }
      out.writeln(inCode ? '</code></pre>' : '<pre><code>');
      inCode = !inCode;
      continue;
    }
    if (inCode) {
      out.writeln(const HtmlEscape().convert(raw));
      continue;
    }
    final heading = RegExp(r'^(#{1,6})\s+(.+)$').firstMatch(raw);
    if (heading != null) {
      if (inList) {
        out.writeln('</ul>');
        inList = false;
      }
      final level = heading.group(1)!.length;
      out.writeln('<h$level>${_inline(heading.group(2)!)}</h$level>');
      continue;
    }
    final item = RegExp(r'^-\s+(.*)$').firstMatch(raw);
    if (item != null) {
      if (!inList) {
        out.writeln('<ul>');
        inList = true;
      }
      var content = item.group(1)!;
      final checked = RegExp(r'^\[([ xX])\]\s+(.*)$').firstMatch(content);
      if (checked != null) {
        final mark = checked.group(1)!.trim().isNotEmpty ? ' checked' : '';
        content =
            '<input type="checkbox" disabled$mark> ${_inline(checked.group(2)!)}';
      } else {
        content = _inline(content);
      }
      out.writeln('<li>$content</li>');
      continue;
    }
    if (inList) {
      out.writeln('</ul>');
      inList = false;
    }
    if (raw.trim().isEmpty) continue;
    if (raw.startsWith('> ')) {
      out.writeln('<blockquote>${_inline(raw.substring(2))}</blockquote>');
    } else {
      out.writeln('<p>${_inline(raw)}</p>');
    }
  }
  if (inList) out.writeln('</ul>');
  if (inCode) out.writeln('</code></pre>');
  out.writeln('</body></html>');
  return out.toString();
}

String _inline(String value) {
  var escaped = const HtmlEscape().convert(value);
  escaped = escaped.replaceAllMapped(
    RegExp(r'`([^`]+)`'),
    (match) => '<code>${match.group(1)}</code>',
  );
  escaped = escaped.replaceAllMapped(
    RegExp(r'\[([^\]]+)\]\(([^)]+)\)'),
    (match) => '<a href="${match.group(2)}">${match.group(1)}</a>',
  );
  return escaped;
}
