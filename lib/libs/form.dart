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
    // await _question('¿Cuál es su número de celular?', 'phone');

    // cuarta pregunta
    await _question('¿Cuál es su correo electronico?', 'email');

    // agradecimiento
    await _tts.speak('Gracias por su colaboración');
    await Future.delayed(const Duration(seconds: 3));

    print('**************Formulario llenado***************');
    print('myName: $myName');
    print('name: $name');
    //  sacar solo los numeros y eliminar espacios
    phone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    print('phone: $phone');
    // eliminar espacios y pasar a minusculas
    // verificar que sea un correo valido
    email = email.replaceAll(' ', '').toLowerCase();
    print('email: $email');
    print('**********************************************');
    // guardar datos
    await _data.saveData('myName', myName);
    await _data.saveData('name', name);
    await _data.saveData('phone', phone);
    await _data.saveData('email', email);
  }

  Future<void> _verifInfo(String message, String type) async {
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
      case 'email':
        if (message != '' && _verifEmail(message)) {
          await _tts.speak('El correo electrónico que dijo es $message');
        } else {
          await _tts.speak('No se pudo reconocer el correo electrónico');
          await Future.delayed(const Duration(seconds: 5));
        }
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
      }
      await _verifInfo(_speech.transcription, type);
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
        case 'email':
          email = _speech.transcription;
          break;
        default:
      }
      await Future.delayed(const Duration(seconds: 7));
    } catch (e) {
      print(e);
    }
  }

  bool _verifEmail(String emailV) {
    emailV = emailV.replaceAll(' ', '').toLowerCase();
    if (!RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
        .hasMatch(emailV)) {
      return false;
    }
    return true;
  }
}
