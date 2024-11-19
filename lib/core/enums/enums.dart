enum ThemeMode {
  light,
  dark,
}

enum UserKarma {
  comment(1),
  textPost(2),
  linkPost(3),
  imagePost(3),
  awardPost(5),
  videoPost(6),
  deletePost(-1);

  final int karma;
  const UserKarma(this.karma);
}
