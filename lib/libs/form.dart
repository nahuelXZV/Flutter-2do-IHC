import 'speak.dart';
import '../data/data.dart';
import 'speech.dart';

class FormClass {
  final SpeakClass _tts = SpeakClass(3);
  late SpeechClass _speech;
  late Data _data;
  String name = '';
  String phone = '';
  String email = '';

  FormClass() {
    _data = Data();
    _speech = SpeechClass();
    _tts.initForm();
  }

  questions() async {
    // primera pregunta
    await _question('¿Cual es el nombre de su contacto de emergencia?', 'name');

    // segunda pregunta
    await _question('¿Cual es su numero de celular?', 'phone');

    // tercera pregunta
    await _question('¿Cual es su correo electronico?', 'email');

    // agradecimiento
    await _tts.speak('Gracias por su colaboracion');
    await Future.delayed(const Duration(seconds: 3));

    print('**************Formulario llenado***************');
    print('name: $name');
    print('phone: $phone');
    print('email: $email');
    print('**********************************************');
    // guardar datos
    await _data.saveData('formDone', 'true');
    await _data.saveData('name', name);
    await _data.saveData('phone', phone);
    await _data.saveData('email', email);
  }

  _verifInfo(String message, String type) async {
    switch (type) {
      case 'name':
        if (message != '') {
          await _tts.speak('El nombre que dijo es $message');
        } else {
          await _tts.speak('No se pudo reconocer el nombre');
          await Future.delayed(const Duration(seconds: 3));
        }
        break;
      case 'phone':
        if (message != '') {
          await _tts.speak('El numero de celular que dijo es $message');
        } else {
          await _tts.speak('No se pudo reconocer el numero de celular');
          await Future.delayed(const Duration(seconds: 5));
        }
        break;
      case 'email':
        if (message != '') {
          await _tts.speak('El correo electronico que dijo es $message');
        } else {
          await _tts.speak('No se pudo reconocer el correo electronico');
          await Future.delayed(const Duration(seconds: 5));
        }
        break;
      default:
        return false;
    }
  }

  _question(String question, type) async {
    await _tts.speak(question);
    await Future.delayed(const Duration(seconds: 3));
    try {
      _speech.startSpeech();
      while (!_speech.isComplete) {
        await Future.delayed(const Duration(seconds: 1));
      }
      await _verifInfo(_speech.transcription, type);
      if (_speech.transcription == '') {
        await _tts.speak('Por favor repita la informacion');
        await Future.delayed(const Duration(seconds: 3));
        await _question(question, type);
        return;
      }
      switch (type) {
        case 'name':
          name = _speech.transcription;
          break;
        case 'phone':
          phone = _speech.transcription;
          break;
        case 'email':
          email = _speech.transcription;
          break;
        default:
      }
      await Future.delayed(const Duration(seconds: 5));
    } catch (e) {
      _question(question, type);
    }
  }
}
