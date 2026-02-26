import 'package:audio_flux/audio_flux.dart';

/// A list of available shaders.
class Shaders {
  // ignore: public_member_api_docs
  static List<ShaderParams> shaderParams = [
    /// 2D LED Spectrum
    const ShaderParams(
      shaderName: '2D LED Spectrum',
      shaderPath: 'shaders/2d_led_spectrum.frag',
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
    ),

    /// Sound Eclipse
    const ShaderParams(
      shaderName: 'SoundEclipse rpm',
      shaderPath: 'shaders/sound_eclipse_rpm.frag',
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
    ),

    /// Frequency Visualization
    const ShaderParams(
      shaderName: 'Frequency Visualization',
      shaderPath: 'shaders/frequency_visualization.frag',
    ),

    /// Audio Wave Form
    const ShaderParams(
      shaderName: 'Audio Wave Form',
      shaderPath: 'shaders/audio_wave_form.frag',
    ),

    /// Sound Sinus Wave
    const ShaderParams(
      shaderName: 'Sound Sinus Wave',
      shaderPath: 'shaders/sound_sinus_wave.frag',
    ),

    /// Audio Visualizer - Raymarching
    const ShaderParams(
      shaderName: 'Audio Visualizer - Raymarching',
      shaderPath: 'shaders/audio_visualizer_raymarching.frag',
    ),

    /// Sound Grid
    const ShaderParams(
      shaderName: 'Sound Grid',
      shaderPath: 'shaders/sound_grid.frag',
    ),

    /// Smoke Rings
    const ShaderParams(
      shaderName: 'Smoke Rings',
      shaderPath: 'shaders/smoke_rings.frag',
    ),

    /// Dancing Flutter
    const ShaderParams(
      shaderName: 'Dancing Flutter',
      shaderPath: 'shaders/dancing_flutter.frag',
    ),

    /// Texture
    ShaderParams(
      shaderName: 'Texture',
      shaderPath: 'shaders/texture.frag',
      textureChannels: [
        TextureChannel(assetsTexturePath: 'assets/dash.png'),
      ],
    ),
  ];
}
