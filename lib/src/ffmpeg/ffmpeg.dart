part of media.ffmpeg;

class FfmpegWrapper {
  final List<String> args;

  Process _process;
  Process get process => _process;

  bool get isRunning => _process != null;

  FfmpegWrapper(this.args);

  Future init() async {
    await kill();
    _process = await Process.start("ffmpeg", args);
  }

  Future<int> get onDone {
    if (_process != null) {
      return _process.exitCode;
    } else {
      return new Future<int>.value(-1);
    }
  }

  Stream<Uint8List> read() async* {
    await for (List<int> data in _process.stdout) {
      Uint8List list;

      if (data is Uint8List) {
        list = data;
      } else {
        list = new Uint8List.fromList(data);
      }

      yield list;
    }
  }

  void add(List<int> data) {
    if (_process != null) {
      _process.stdin.add(data);
    }
  }

  void done() {
    if (_process != null) {
      _process.stdin.close();
    }
  }

  Future pipe(Stream<List<int>> data) async {
    if (_process != null) {
      return await data.pipe(_process.stdin);
    }
  }

  Future convertFile(File input, File output) async {
    if (_process == null) {
      await init();
    }

    await Future.wait([readFromFile(input), writeToFile(output)]);
  }

  Future writeToFile(File file) async {
    var sink = await file.openWrite();
    try {
      await for (Uint8List bytes in read()) {
        sink.add(bytes);
      }
    } finally {
      sink.close();
    }
  }

  Future readFromFile(File file) async {
    await for (List<int> bytes in file.openRead()) {
      add(bytes);
    }
    done();
  }

  Future kill() async {
    if (_process != null) {
      _process.kill();
      _process = null;
    }
  }
}
