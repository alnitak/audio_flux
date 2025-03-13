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
    this.params,
    this.paramsRange,
  });

  final String shaderName;
  final String shaderPath;

  final List<ShaderParam>? params;
  final List<ShaderParamRange>? paramsRange;


  ShaderParams copyWith({
    String? shaderName,
    String? shaderPath,
    List<ShaderParam>? params,
    List<ShaderParamRange>? paramsRange,
  }) {
    return ShaderParams(
      shaderName: shaderName ?? this.shaderName,
      shaderPath: shaderPath ?? this.shaderPath,
      params: params ?? this.params,
      paramsRange: paramsRange ?? this.paramsRange,
    );
  }
}
