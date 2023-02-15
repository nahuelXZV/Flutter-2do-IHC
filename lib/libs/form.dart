import 'speak.dart';
import '../data/data.dart';
import 'speech.dart';

class FormClass {
  final SpeakClass _tts = SpeakClass(3);
  late SpeechClass _speech;
  late Data _data;
  String myName = '';
  String name = '';
  String phone = '';
  String email = '';

  FormClass() {
    _data = Data();
    _tts.initForm();
    _speech = SpeechClass();
  }

  Future<void> questions() async {
    // primera pregunta
    await _question('¿Cuál es tu nombre?', 'myName');

    // segunda pregunta
    await _question('¿Cuál es el nombre de su contacto de emergencia?', 'name');

    // tercera pregunta
    await _question('¿Cuál es el número de celular de $name?', 'phone');

    // agradecimiento
    await _tts.speak('Gracias por su colaboración');
    await Future.delayed(const Duration(seconds: 3));

    print('**************Formulario llenado***************');
    print('myName: $myName');
    print('name: $name');
    //  sacar solo los numeros y eliminar espacios
    phone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    print('phone: $phone');
    print('**********************************************');
    // guardar datos
    await _data.saveData('myName', myName);
    await _data.saveData('name', name);
    await _data.saveData('phone', phone);
    // await _data.saveData('email', email);
  }

  Future<void> _verifInfo(String message, String type, String question) async {
    switch (type) {
      case 'myName':
        if (message != '') {
          await _tts.speak('El nombre que dijo es $message');
        } else {
          await _tts.speak('No se pudo reconocer el nombre');
          await Future.delayed(const Duration(seconds: 3));
        }
        break;
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
          await _tts.speak('El número de celular que dijo es $message');
        } else {
          await _tts.speak('No se pudo reconocer el número de celular');
          await Future.delayed(const Duration(seconds: 5));
        }
        break;
      default:
    }
    if (_speech.transcription == '') {
      await _tts.speak('Por favor repita la información');
      await Future.delayed(const Duration(seconds: 3));
      await _question(question, type);
      return;
    }
    switch (type) {
      case 'myName':
        myName = _speech.transcription;
        break;
      case 'name':
        name = _speech.transcription;
        break;
      case 'phone':
        phone = _speech.transcription;
        break;
      default:
    }
  }

  Future<void> _question(String question, type) async {
    try {
      await _tts.speak(question);
      await Future.delayed(const Duration(seconds: 3));
      _speech.startSpeech();
      print('**************Escuchando***************');
      while (!_speech.isComplete) {
        await Future.delayed(const Duration(seconds: 1));
        print(_speech.isComplete);
        if (type == 'phone') {
          if (_speech.transcription.length == 8) {
            _speech.stopSpeech();
          }
        }
      }
      await _verifInfo(_speech.transcription, type, question);
      await Future.delayed(const Duration(seconds: 7));
    } catch (e) {
      print(e);
    }
  }
}
