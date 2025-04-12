import 'package:audio_flux/audio_flux.dart';

/// A list of available shaders.
class Shaders {
  // ignore: public_member_api_docs
  static List<ShaderParams> shaderParams = [
    /// 2D LED Spectrum
    const ShaderParams(
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
      textureChannels: [],
    ),

    /// Sound Eclipse
    const ShaderParams(
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

    /// Frequency Visualization
    const ShaderParams(
      shaderName: 'Frequency Visualization',
      shaderPath: 'assets/shaders/frequency_visualization.frag',
      params: [],
      paramsRange: [],
    ),

    /// Audio Wave Form
    const ShaderParams(
      shaderName: 'Audio Wave Form',
      shaderPath: 'assets/shaders/audio_wave_form.frag',
      params: [],
      paramsRange: [],
    ),

    /// Sound Sinus Wave
    const ShaderParams(
      shaderName: 'Sound Sinus Wave',
      shaderPath: 'assets/shaders/sound_sinus_wave.frag',
      params: [],
      paramsRange: [],
    ),

    /// Audio Visualizer - Raymarching
    const ShaderParams(
      shaderName: 'Audio Visualizer - Raymarching',
      shaderPath: 'assets/shaders/audio_visualizer_raymarching.frag',
      params: [],
      paramsRange: [],
    ),

    /// Sound Grid
    const ShaderParams(
      shaderName: 'Sound Grid',
      shaderPath: 'assets/shaders/sound_grid.frag',
      params: [],
      paramsRange: [],
    ),

    /// Smoke Rings
    const ShaderParams(
      shaderName: 'Smoke Rings',
      shaderPath: 'assets/shaders/smoke_rings.frag',
      params: [],
      paramsRange: [],
    ),

    /// Dancing Flutter
    const ShaderParams(
      shaderName: 'Dancing Flutter',
      shaderPath: 'assets/shaders/dancing_flutter.frag',
      params: [],
      paramsRange: [],
    ),
  ];
}
