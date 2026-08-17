class HlsManifestProxy {
  Future<Uri?> prepare(Uri remoteUri, Map<String, String> headers) async =>
      null;

  static bool isM3u8Path(Uri uri) => uri.path.toLowerCase().endsWith('.m3u8');

  Future<void> close() async {}
}
