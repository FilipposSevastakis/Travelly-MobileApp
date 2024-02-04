import 'package:username_gen/username_gen.dart';

var user = Profile(username: UsernameGen().generate().substring(0, 10));

//Αυτή η κλάση υπάρχει τόσο για την αλλαγή του Description-Bios τόσο και για την βάση δεδομένων
class Profile {
  int? tag;
  String? description;
  String username;
  String? photo;

  /// Constructor (δομητής) της κλάσης
  Profile({this.tag, this.description, required this.username, this.photo});
}
