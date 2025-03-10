import 'package:example/controls/sliders.dart';
import 'package:example/model/model.dart';
import 'package:flutter/material.dart';

class CommonControls extends StatefulWidget {
  const CommonControls({
    super.key,
    required this.model,
  });

  final AudioVisualizerModel model;

  @override
  State<CommonControls> createState() => _CommonControlsState();
}

class _CommonControlsState extends State<CommonControls> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SliderParam(
            label: 'audioScale',
            min: 0.1,
            max: 10.0,
            value: widget.model.painterParams.audioScale,
            onChanged: (value) {
              widget.model.updatePainterParams(audioScale: value);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}
