// ignore_for_file: public_member_api_docs, sort_constructors_first
class ShaderParam {
  const ShaderParam({
    required this.label,
    required this.min,
    required this.max,
    required this.value,
  });

  final String label;
  final double min;
  final double max;
  final double value;

  ShaderParam copyWith({
    String? label,
    double? min,
    double? max,
    double? value,
  }) {
    return ShaderParam(
      label: label ?? this.label,
      min: min ?? this.min,
      max: max ?? this.max,
      value: value ?? this.value,
    );
  }
}

class ShaderParamRange {
  const ShaderParamRange({
    required this.label,
    required this.min,
    required this.max,
    required this.minValue,
    required this.maxValue,
  });

  final String label;
  final double min;
  final double max;
  final double minValue;
  final double maxValue;

  ShaderParamRange copyWith({
    String? label,
    double? min,
    double? max,
    double? minValue,
    double? maxValue,
  }) {
    return ShaderParamRange(
      label: label ?? this.label,
      min: min ?? this.min,
      max: max ?? this.max,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
    );
  }
}

class ShaderParams {
  const ShaderParams({
    this.shaderName = '',
    this.shaderPath = '',
    this.bins = const ShaderParamRange(
      label: 'bins',
      min: 0,
      max: 255,
      minValue: 0,
      maxValue: 255,
    ),
    this.fftSmoothing = const ShaderParam(
      label: 'fftSmoothing',
      min: 0.0,
      max: 1.0,
      value: 0.93,
    ),
    this.params,
    this.paramsRange,
  });

  final String shaderName;
  final String shaderPath;

  final ShaderParamRange bins;
  final ShaderParam fftSmoothing;

  final List<ShaderParam>? params;
  final List<ShaderParamRange>? paramsRange;


  ShaderParams copyWith({
    String? shaderName,
    String? shaderPath,
    ShaderParamRange? bins,
    ShaderParam? fftSmoothing,
    List<ShaderParam>? params,
    List<ShaderParamRange>? paramsRange,
  }) {
    return ShaderParams(
      shaderName: shaderName ?? this.shaderName,
      shaderPath: shaderPath ?? this.shaderPath,
      bins: bins ?? this.bins,
      fftSmoothing: fftSmoothing ?? this.fftSmoothing,
      params: params ?? this.params,
      paramsRange: paramsRange ?? this.paramsRange,
    );
  }
}
