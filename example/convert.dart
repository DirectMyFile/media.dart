import "dart:io";

import "package:media/ffmpeg.dart";

main(List<String> args) async {
  if (args.length != 4) {
    print(
      "Usage: convert <input format>"
      " <output format> <input file> <output file>");
  }

  var inputFormat = args[0];
  var outputFormat = args[1];
  var inputPath = args[2];
  var outputPath = args[3];

  var converter = new FfmpegConverter(inputFormat, outputFormat);
  await converter.convertFile(new File(inputPath), new File(outputPath));
}
