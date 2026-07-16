import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/opportunity_model.dart';
import '../models/application_model.dart';
class FirestoreService {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;


  // Get all opportunities

  Stream<List<OpportunityModel>> getOpportunities() {

    return _firestore
        .collection("opportunities")
        .snapshots()
        .map((snapshot) {


      return snapshot.docs.map((doc) {


        return OpportunityModel.fromFirestore(
          doc.data(),
          doc.id,
        );


      }).toList();


    });
  }



  // Get one opportunity

  Future<OpportunityModel?> getOpportunity(
      String id,
  ) async {


    final doc = await _firestore
        .collection("opportunities")
        .doc(id)
        .get();


    if(doc.exists){

      return OpportunityModel.fromFirestore(
        doc.data()!,
        doc.id,
      );

    }


    return null;
  }





  // Apply for opportunity

  Future<void> apply(
      ApplicationModel application,
  ) async {


    await _firestore
        .collection("applications")
        .add(
          application.toMap(),
        );

  }






  // Get applications for user

  Stream<List<ApplicationModel>> getUserApplications(
      String userId,
  ){


    return _firestore
        .collection("applications")
        .where(
          "studentUid",
          isEqualTo: userId,
        )
        .snapshots()
        .map((snapshot){


          return snapshot.docs.map((doc){


            return ApplicationModel.fromFirestore(
              doc.data(),
              doc.id,
            );


          }).toList();


        });

  }

}