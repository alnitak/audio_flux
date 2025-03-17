import 'package:flutter/material.dart';

class SliderParam extends StatefulWidget {
  const SliderParam({
    required this.label,
    required this.min,
    required this.max,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String label;
  final double min;
  final double max;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  State<SliderParam> createState() => _SliderParamState();
}

class _SliderParamState extends State<SliderParam> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(widget.label),
        ),
        Expanded(
          child: Slider(
            min: widget.min,
            max: widget.max,
            value: widget.value,
            onChanged: widget.onChanged,
          ),
        ),
        SizedBox(
          width: 80,
          child: Text(widget.value.toStringAsFixed(2)),
        ),
      ],
    );
  }
}

class RangeSliderParam extends StatefulWidget {
  const RangeSliderParam({
    required this.label,
    required this.min,
    required this.max,
    required this.values,
    required this.onChanged,
    super.key,
  });

  final String label;
  final double min;
  final double max;
  final RangeValues values;
  final ValueChanged<RangeValues> onChanged;

  @override
  State<RangeSliderParam> createState() => _RangeSliderParamState();
}

class _RangeSliderParamState extends State<RangeSliderParam> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(widget.label),
        ),
        Expanded(
          child: RangeSlider(
            min: widget.min,
            max: widget.max,
            values: widget.values,
            onChanged: widget.onChanged,
          ),
        ),
        SizedBox(
          width: 90,
          child: Text(
            '${widget.values.start.toStringAsFixed(2)} - '
            '${widget.values.end.toStringAsFixed(2)}',
          ),
        ),
      ],
    );
  }
}
