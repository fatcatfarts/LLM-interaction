import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String? username;
  final String? token;

  const User({
    required this.id,
    required this.email,
    this.username,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) { // a factory constructor which allows us to preprocess data before returning it
    //here we take data as map json and return a user(meaning processing the incoming json data into json model)
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String?,
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() { //a method to convert the given provided data into json data
    return {
      'id': id,
      'email': email,
      'username': username,
      'token': token,
    };
  }

  @override
  List<Object?> get props => [id, email, username, token];
}