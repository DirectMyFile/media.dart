part of media.ffmpeg;

class FfmpegConverter {
  final String inputFormat;
  final String outputFormat;
  final List<String> inputArguments;
  final List<String> outputArguments;
  final bool enableVideoOutput;
  final bool enableAudioOutput;
  final String duration;
  final int loopCount;

  FfmpegWrapper _wrapper;

  FfmpegConverter(this.inputFormat, this.outputFormat, {
    this.enableVideoOutput: true,
    this.enableAudioOutput: true,
    this.loopCount,
    this.duration,
    this.inputArguments,
    this.outputArguments
  });

  Future start() async {
    await stop();

    var args = <String>[
      "-f",
      inputFormat
    ];

    if (loopCount != null) {
      args.addAll(["-stream_loop", loopCount]);
    }

    if (duration != null) {
      args.addAll(["-t", duration]);
    }

    if (inputArguments != null) {
      args.addAll(inputArguments);
    }

    args.addAll([
      "-i",
      "-"
    ]);

    if (!enableVideoOutput) {
      args.add("-vn");
    }

    if (!enableAudioOutput) {
      args.add("-an");
    }

    if (outputArguments != null) {
      args.addAll(outputArguments);
    }

    args.addAll(["-f", outputFormat, "-"]);

    _wrapper = new FfmpegWrapper(args);

    await _wrapper.init();
  }

  Stream<Uint8List> read() => _wrapper.read();

  void add(List<int> data) {
    _wrapper.add(data);
  }

  void done() {
    _wrapper.done();
  }

  Future pipe(Stream<List<int>> stream) {
    return _wrapper.pipe(stream);
  }

  Future convertFile(File input, File output) async {
    if (_wrapper == null) {
      await start();
    }

    await _wrapper.convertFile(input, output);

    await stop();
  }

  Future stop() async {
    if (_wrapper != null) {
      _wrapper.kill();
      _wrapper = null;
    }
  }
}
