// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:shader_buffers/shader_buffers.dart';

/// Definition of shader parameters that can have a value in a range.
class ShaderParam {
  ///
  const ShaderParam({
    required this.label,
    required this.min,
    required this.max,
    required this.value,
  });

  /// The parameter name
  final String label;

  /// The minimum value
  final double min;

  /// The maximum value
  final double max;

  /// The current value
  final double value;

  ///
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

/// Definition of shader parameters that have a range of values that must
/// be in a range of [min] and [max].
///
/// For example for a FFT bins data, the`minBinIndex` and `maxBinIndex` must
/// be between 0 and 255.
class ShaderParamRange {
  ///
  const ShaderParamRange({
    required this.label,
    required this.min,
    required this.max,
    required this.minValue,
    required this.maxValue,
  });

  /// The parameter name
  final String label;

  /// The minimum value
  final double min;

  /// The maximum value
  final double max;

  /// The minimum value
  final double minValue;

  /// The maximum value
  final double maxValue;

  ///
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

class TextureChannel extends IChannel {
  TextureChannel({
    super.assetsTexturePath,
    super.texture,
  }) : assert(
          /// Only one of [assetsTexturePath] or [texture] must be given
          assetsTexturePath != null || texture != null,
          'Only [assetsTexturePath] or [texture] must be given!',
        );
}

/// Definition of shader parameters.
class ShaderParams {
  ///
  const ShaderParams({
    this.shaderName = '',
    this.shaderPath = '',
    this.params,
    this.paramsRange,
    this.textureChannels,
  });

  /// The shader name
  final String shaderName;

  /// The shader path in the `assets` folder
  final String shaderPath;

  /// The shader parameters
  final List<ShaderParam>? params;

  /// The shader parameters that have a range
  final List<ShaderParamRange>? paramsRange;

  /// The shader textures
  final List<TextureChannel>? textureChannels;

  ///
  ShaderParams copyWith({
    String? shaderName,
    String? shaderPath,
    List<ShaderParam>? params,
    List<ShaderParamRange>? paramsRange,
    List<TextureChannel>? textureChannels,
  }) {
    return ShaderParams(
      shaderName: shaderName ?? this.shaderName,
      shaderPath: shaderPath ?? this.shaderPath,
      params: params ?? this.params,
      paramsRange: paramsRange ?? this.paramsRange,
      textureChannels: textureChannels ?? this.textureChannels,
    );
  }
}
