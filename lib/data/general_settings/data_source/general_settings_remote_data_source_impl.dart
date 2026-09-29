import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hr_management_system/data/general_settings/data_source/general_settings_remote_data_source.dart';
import 'package:hr_management_system/data/general_settings/model/general_settings_model.dart';

class GeneralSettingsRemoteDataSourceImpl
    implements GeneralSettingsRemoteDataSource {
  static const String collectionName = 'general_settings';
  static const String documentId = 'main';

  final FirebaseFirestore firestore;

  GeneralSettingsRemoteDataSourceImpl(this.firestore);

  DocumentReference<Map<String, dynamic>> get _document {
    return firestore.collection(collectionName).doc(documentId);
  }

  @override
  Future<GeneralSettingsModel> getGeneralSettings() async {
    final snapshot = await _document.get();

    if (!snapshot.exists) {
      return GeneralSettingsModel.defaults();
    }

    return GeneralSettingsModel.fromFirestore(snapshot);
  }

  @override
  Future<void> updateGeneralSettings(GeneralSettingsModel settings) async {
    await _document.set(settings.toFirestore());
  }
}
