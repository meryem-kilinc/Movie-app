import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NoteFirebaseService {

  // Tek doküman olarak kaydet
static Future<void> saveNote({
  required String movieId,
  required String note,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception('Kullanıcı giriş yapmamış.');

  await FirebaseFirestore.instance
      .collection('Kullanici_Notlari')
      .doc('${user.uid}_$movieId') // unique doc id: kullanıcı + film id
      .set({
        'movieId': movieId,
        'uid': user.uid,
        'note': note,
        'timestamp': FieldValue.serverTimestamp(),
      });
}

// Tek doküman olarak oku
static Stream<DocumentSnapshot> getUserNoteForMovie(String movieId) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return const Stream.empty();

  return FirebaseFirestore.instance
      .collection('Kullanici_Notlari')
      .doc('${user.uid}_$movieId')
      .snapshots();
}
}



