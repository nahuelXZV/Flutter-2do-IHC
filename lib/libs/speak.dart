import 'package:text_to_speech/text_to_speech.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SpeakClass {
  late TextToSpeech tts;
  final FlutterTts flutterTts = FlutterTts();

  final String _greet1 =
      'Hola, soy tu asistente virtual, incline el celular a la izquierda para saber su ubicación actual, a la derecha para enviar su ubicación y hacia atrás para modificar su contacto de emergencia. Cuando cierre la aplicación incline el celular hacia la izquierda para saber su ubicación actual y hacia la derecha para conocer los lugares cercanos';
  final String _greet2 =
      'A continuación le mencionaré el menú, incline el celular a la izquierda para saber su ubicación actual, a la derecha para enviar su ubicación y hacia atrás para modificar su contacto de emergencia. Cuando cierre la aplicación incline el celular hacia la izquierda para saber su ubicación actual y hacia la derecha para conocer los lugares cercanos';
  final String _noIdea = 'Lo siento no entendí, por favor puedes repetir';

  SpeakClass(typeGreeting) {
    if (typeGreeting == 1) {
      speak(_greet1);
    } else if (typeGreeting == 2) {
      speak(_greet2);
    }
  }

  void _handlerTextToSpeech() async {
    double volume = 1.0;
    tts.setVolume(volume);
    double rate = 0.7;
    tts.setRate(rate);
    double pitch = 1.0;
    tts.setPitch(pitch);
    String language = 'es-BO';
    tts.setLanguage(language);
  }

  speak(String text) async {
    await flutterTts.setLanguage("es-ES");
    await flutterTts.setPitch(1);
    await flutterTts.speak(text);
  }

  void _ttsGreet() async {
    await speak(_greet1);
  }

  void ttsError() async {
    await speak(_noIdea);
  }

  ttlSpeak(String transcription) async {
    await speak(transcription);
  }

  void dispose() {
    flutterTts.stop();
  }

  void initForm(type) {
    if (type == 1) {
      speak(
          'Bienvenido a ayúdame, Empezaremos el registro de su contacto de emergencia');
    } else {
      speak('Empezaremos con la modificación de sus datos');
    }
  }
}
