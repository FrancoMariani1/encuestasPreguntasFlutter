import 'package:postgres/postgres.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  final PostgreSQLConnection _connection = PostgreSQLConnection(
    'localhost',
    5432,
    'Surveys',
    username: 'Franco',
    password: '160120',
  );

  Future<void> connect() async {
    if (_connection.isClosed) {
      try {
        await _connection.open();
        print('Conexión exitosa');
      } catch (e) {
        print('Error de conexión: $e');
        rethrow;
      }
    }
  }

  Future<void> _checkConnection() async {
    if (_connection.isClosed) {
      await connect();
    }
  }

  Future<List<Map<String, dynamic>>> getSurveys() async {
    try {
      final result = await _connection.query(
        'SELECT id_encuesta, nombre_encuesta FROM encuestas',
      );

      final List<Map<String, dynamic>> retrievedSurveys = [];
      for (final row in result) {
        final surveyId = row[0] as int;
        final surveyName = row[1] as String;
        retrievedSurveys.add({
          'id': surveyId,
          'name': surveyName,
        });
      }
      return retrievedSurveys;
    } catch (e) {
      print('Error al obtener encuestas: $e');
      return [];
    }
  }

  Future<void> insertSurvey(String surveyName) async {
    try {
      await _connection.query(
        'INSERT INTO encuestas (nombre_encuesta) VALUES (@surveyName)',
        substitutionValues: {'surveyName': surveyName},
      );
    } catch (e) {
      print('Error al insertar encuesta: $e');
    }
  }

  Future<void> insertQuestion(
      String surveyName, String questionText, bool isMandatory) async {
    try {
      await _connection.query(
        'INSERT INTO preguntas (id_encuesta, texto_pregunta, es_obligatoria) VALUES ((SELECT id_encuesta FROM encuestas WHERE nombre_encuesta = @surveyName LIMIT 1), @questionText, @isMandatory)',
        substitutionValues: {
          'surveyName': surveyName,
          'questionText': questionText,
          'isMandatory': isMandatory,
        },
      );
    } catch (e) {
      print('Error al insertar pregunta: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getQuestionsForSurvey(
      String surveyName) async {
    try {
      final result = await _connection.query(
        'SELECT id_pregunta, texto_pregunta, es_obligatoria FROM preguntas WHERE id_encuesta = (SELECT id_encuesta FROM encuestas WHERE nombre_encuesta = @surveyName LIMIT 1)',
        substitutionValues: {'surveyName': surveyName},
      );

      final List<Map<String, dynamic>> retrievedQuestions = [];

      for (final row in result) {
        final questionId = row[0] as int;
        final questionText = row[1] as String;
        final isMandatory = row[2] as bool;
        retrievedQuestions.add({
          'id': questionId,
          'text': '$questionText (Obligatoria: ${isMandatory ? 'Sí' : 'No'})',
          'isMandatory': isMandatory,
        });
      }

      return retrievedQuestions;
    } catch (e) {
      print('Error al obtener preguntas: $e');
      return [];
    }
  }

  Future<void> updateQuestion(String surveyName, int questionId,
      String newQuestionText, bool isMandatory) async {
    try {
      await _connection.query(
        'UPDATE preguntas SET texto_pregunta = @newQuestionText, es_obligatoria = @isMandatory WHERE id_pregunta = @questionId AND id_encuesta = (SELECT id_encuesta FROM encuestas WHERE nombre_encuesta = @surveyName LIMIT 1)',
        substitutionValues: {
          'surveyName': surveyName,
          'questionId': questionId,
          'newQuestionText': newQuestionText,
          'isMandatory': isMandatory,
        },
      );
    } catch (e) {
      print('Error al actualizar la pregunta: $e');
    }
  }

  Future<void> deleteQuestion(String surveyName, int questionId) async {
    try {
      await _connection.query(
        'DELETE FROM preguntas WHERE id_pregunta = @questionId AND id_encuesta = (SELECT id_encuesta FROM encuestas WHERE nombre_encuesta = @surveyName LIMIT 1)',
        substitutionValues: {
          'surveyName': surveyName,
          'questionId': questionId
        },
      );
    } catch (e) {
      print('Error al eliminar la pregunta: $e');
    }
  }

  Future<void> deleteQuestionsForSurvey(int surveyId) async {
    try {
      await _connection.query(
        'DELETE FROM preguntas WHERE id_encuesta = @surveyId',
        substitutionValues: {'surveyId': surveyId},
      );
    } catch (e) {
      print('Error al eliminar las preguntas: $e');
    }
  }

  Future<void> deleteSurvey(int surveyId) async {
    try {
      // Primero, elimina las preguntas asociadas a esta encuesta
      await deleteQuestionsForSurvey(surveyId);

      // Luego, elimina la encuesta
      await _connection.query(
        'DELETE FROM encuestas WHERE id_encuesta = @surveyId',
        substitutionValues: {'surveyId': surveyId},
      );
    } catch (e) {
      print('Error al eliminar la encuesta: $e');
    }
  }

  Future<void> close() async {
    await _connection.close();
  }
}
