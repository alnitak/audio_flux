import 'package:audio_flux/audio_flux.dart';

class Shaders {
  static const List<ShaderParams> shaderParams = [
    
    /// 2D LED Spectrum
    ShaderParams(
      shaderName: '2D LED Spectrum',
      shaderPath: 'assets/shaders/2d_led_spectrum.frag',
      params: [
        ShaderParam(
          label: 'bands',
          min: 10,
          max: 256,
          value: 32,
        ),
        ShaderParam(
          label: 'segments',
          min: 10,
          max: 128,
          value: 32,
        ),
      ],
      paramsRange: [],
    ),

    /// 
    ShaderParams(
      shaderName: 'SoundEclipse rpm',
      shaderPath: 'assets/shaders/sound_eclipse_rpm.frag',
      params: [
        ShaderParam(
          label: 'RADIUS',
          min: 0,
          max: 10,
          value: 0.6,
        ),
        ShaderParam(
          label: 'BRIGHTNESS',
          min: 0,
          max: 10,
          value: 0.2,
        ),
        ShaderParam(
          label: 'SPEED',
          min: 0,
          max: 10,
          value: 0.5,
        ),
      ],
      paramsRange: [],
    ),
  ];
}
