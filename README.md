Audio visualizer which uses [flutter_soloud](https://pub.dev/packages/flutter_soloud) and [flutter_recorder](https://pub.dev/packages/flutter_recorder) to acquire the audio data and display them using a CustomPainter or [shader_buffer](https://pub.dev/packages/shader_buffers) to render them to shaders.

## Getting started

Since this package uses [flutter_soloud](https://pub.dev/packages/flutter_soloud) and [flutter_recorder](https://pub.dev/packages/flutter_recorder), you need to add them to your pubspec.yaml file:

```yaml
dependencies:
    flutter:
      sdk: flutter
    flutter_soloud: any
    flutter_recorder: any
```
this lets you start, stop, play sound etc and visualize the audio.

Please refer to the [flutter_soloud](https://pub.dev/packages/flutter_soloud) and [flutter_recorder](https://pub.dev/packages/flutter_recorder) packages for more information like adding recording permission or support for the web.


## Usage

```dart
AudioFlux(
  fluxType: ...,
  dataSource: ...,
  modelParams: ...,
)
```

where:
- **`fluxType`** is the enum to choose from the different visualizers:
    - `FluxType.waveform` visualizes the waveform
    - `FluxType.fft` visualizes the FFT
    - `FluxType.shader` visualizes a shader
- **`dataSource`** is the enum to choose from the different data sources:
    - `DataSource.soloud` uses flutter_soloud to acquire the audio data
    - `DataSource.recorder` uses flutter_recorder to acquire the audio data
- **`modelParams`** is the map of common parameters and parameters for the choosen `fluxType`. See the [documentation](https://github.com/alnitak/audio_flux/blob/ca016844cbc5dc33b64b044c6985b2594d7014e8/lib/src/params/model_params.dart) for more details.

**To know better how `modelParams` parameters work all togheter, please run the provided example or go [here](https://marcobavagnoli.com/audio_flux/) for a web demo.**

The shaders in the example, but the `Dancing Flutter` which I made for fun, are from [Shadertoy](https://www.shadertoy.com/).

#### Waveform visualization

```dart
AudioFlux(
  fluxType: FluxType.waveform,
  dataSource: DataSource.soloud,
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
  dataSource: DataSource.soloud,
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

To add a shader to your app, you need to add the shader code to your assets, add it to your pubspec.yaml and provide the path to the shader in the `modelParams` map:

```yaml
flutter:
  uses-material-design: true

  shaders:
    - assets/shaders/dancing_flutter.frag
```

```dart
AudioFlux(
  fluxType: FluxType.shader,
  dataSource: DataSource.soloud,
  modelParams: ModelParams(
    shaderParams: ShaderParams(
      shaderPath: 'assets/shaders/dancing_flutter.frag',
      params: /* eventually add your custom uniform parameters */
    ),
  ),
)
```

#### write a shader

In the `example/assets/shaders/common` folder you can find the `common_header.frag` file which contains the common code for all the shaders used by the *shader_buffer* package. Include that file in your shader and add your custom code:

```glsl
// This will include some common uniforms that you can use in your shader:
// - [iResolution] the widget width and height
// - [iTime] the current time in seconds from the start of rendering
// - [iFrame] the current rendering frame number
// - [iMouse] for user interaction with pointer (see https://github.com/alnitak/shader_buffers/blob/main/lib/src/imouse.dart)
// and the output variable `fragColor`
#include <common/common_header.frag>

// Mandatory uniform which is sent by audio_flux and it represents the audio data.
// This texture is a matrix of 256x2 RGBA pixels representing:
// in the 1st row the frequencies data
// in the 2nd row the amplitudes data
uniform sampler2D iChannel0;

// Other uniforms if your want to add custom parameters and control them from Dart
uniform float customUniform;

// The shader code.

// If you want to copy/paste ShaderToy shader, you also need to include
// this at the end of the code:
#include <common/main_shadertoy.frag>
```