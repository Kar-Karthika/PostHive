class Usermodel {
  String email;
  String username;
  String bio;
  String profileImage;
  List following;
  List followers;
  Usermodel(this.bio, this.email, this.followers, this.following, this.profileImage,
      this.username);
}
