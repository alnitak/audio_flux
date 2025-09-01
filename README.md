A versatile audio visualization package for Flutter that captures and displays real-time audio data. Using [flutter_soloud](https://pub.dev/packages/flutter_soloud) for playback and [flutter_recorder](https://pub.dev/packages/flutter_recorder) for recording, it offers both traditional CustomPainter rendering and high-performance shader-based visualizations through [shader_buffer](https://pub.dev/packages/shader_buffers).

||||
|-|-|-|
|![custom_painter](https://github.com/user-attachments/assets/59471aa9-1f53-4920-90cc-7793e17b9eec)|![Dancing Flutter](https://github.com/user-attachments/assets/5e35069f-4dc3-4f49-97b5-0d75bcaaaa74)|![shaders](https://github.com/user-attachments/assets/d69e14f2-23af-4912-8c28-071bdf1d8c62)|
[web demo](https://marcobavagnoli.com/audio_flux/)

## Getting started

This package requires two main dependencies to handle audio processing:
- [flutter_soloud](https://pub.dev/packages/flutter_soloud): Handles audio playback
- [flutter_recorder](https://pub.dev/packages/flutter_recorder): Manages audio input capture

Add these to your pubspec.yaml:

```yaml
dependencies:
    flutter:
      sdk: flutter
    flutter_soloud: any
    flutter_recorder: any
```
These dependencies provide comprehensive audio functionality, enabling playback control, recording, and real-time audio visualization.

Before using the package, ensure you've configured the necessary platform-specific settings and permissions as described in the documentation of each dependency.

## Usage

AudioFlux provides three powerful visualization modes through a simple, configurable widget:

```dart
AudioFlux(
  fluxType: ...,
  dataSource: ...,
  modelParams: ...,
)
```

where:
- **`fluxType`**: Select your visualization style:
    - `FluxType.waveform`: Real-time oscilloscope-style display of audio waves
    - `FluxType.fft`: Frequency spectrum analysis visualization
    - `FluxType.shader`: Custom GPU-accelerated visual effects
- **`dataSource`**: Choose your audio source:
    - `DataSource.soloud`: Captures audio from playback stream
    - `DataSource.recorder`: Captures audio from microphone/input
- **`modelParams`**: Configure visualization behavior with type-specific parameters

**Explore the interactive [web demo](https://marcobavagnoli.com/audio_flux/) to see how different parameters affect the visualizations in real-time.**

**Note**: All shader examples except 'Dancing Flutter' are adapted from [Shadertoy](https://www.shadertoy.com/).

> [!TIP]  
> When starting to play something or initializing the recorder, the audio flux widget will automatically start capturing audio data and updating the visualization.

#### Waveform visualization

```dart
AudioFlux(
  fluxType: FluxType.waveform,
  dataSource: DataSources.soloud,
  modelParams: ModelParams(
    waveformParams: WaveformPainterParams(
      barsWidth: 2,
      barSpacingScale: 0.5,
      chunkSize: 1,
    ),
  ),
)
```

#### FFT visualization

```dart
AudioFlux(
  fluxType: FluxType.fft,
  dataSource: DataSources.soloud,
  modelParams: ModelParams(
    fftParams: FftParams(
      minBinIndex: 5,
      maxBinIndex: 140,
      fftSmoothing: 0.95,
    ),
  ),
)
```

## Adding a shader to your app

To implement shader-based visualizations, follow these steps:
1. Add your shader file to the assets directory
2. Register it in pubspec.yaml
3. Configure AudioFlux to use your shader

```yaml
flutter:
  uses-material-design: true

  shaders:
    - assets/shaders/dancing_flutter.frag
```

```dart
AudioFlux(
  fluxType: FluxType.shader,
  dataSource: DataSources.soloud,
  modelParams: ModelParams(
    shaderParams: ShaderParams(
      shaderPath: 'assets/shaders/dancing_flutter.frag',
      params: /* eventually add your custom uniform parameters */
      paramsRange: /* eventually add your custom range parameters */
      textureChannels: /* eventually add your `ui.Image` or asset texture */
    ),
  ),
)
```

#### Creating custom shaders

The `common_header.frag` file provides essential uniforms for shader development:
- `iResolution`: Current widget dimensions (vec2)
- `iTime`: Elapsed time in seconds (float)
- `iFrame`: Current frame number (int)
- `iMouse`: Pointer interaction data (vec4) (see [iMouse](https://github.com/alnitak/shader_buffers/blob/main/lib/src/imouse.dart))
and the output variable `fragColor` (vec4).

In the `example/assets/shaders/common` folder you can find the `common_header.frag` file which contains the common code for all the shaders used by the *shader_buffer* package. Include that file in your shader and add your custom code:

```glsl
#include <common/common_header.frag>

// At least one `sampler2D` is a mandatory uniform you must declare. It is sent
// by "audio_flux" and it represents the audio data.
// This texture is a matrix of 256x2 RGBA pixels representing:
// in the 1st row the frequencies data
// in the 2nd row the amplitudes data
uniform sampler2D iChannel0;
// After the first mandatory sampler2D, you can add any number of textures.
uniform sampler2D myOtherTexture;

// Other uniforms if you want to add custom parameters and control them from Dart
uniform float customUniform;

// The shader code.
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // ...
}

// If you want to copy/paste ShaderToy shader, you also need to include
// this at the end of the code:
#include <common/main_shadertoy.frag>
```
