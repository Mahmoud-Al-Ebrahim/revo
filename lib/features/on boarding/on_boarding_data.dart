


const List<PageViewData> onBoardingData = [
  PageViewData(
      'assets/svg/community.svg',
      'Discover Diverse Communities',
      'Explore a vast array of communities tailored to your interests, from niche hobbies to global discussions. Whether you\'re into gaming, cooking, art, or science, Reddit has a community waiting for you'),
  PageViewData(
      'assets/svg/personalization.svg',
      'Personalized Content Feed',
    'Your Reddit experience begins with a personalized content feed curated just for you. Get recommendations based on your interests, past interactions, and trending topics, ensuring you always see the most relevant and engaging posts'
  ),
  PageViewData(
      'assets/svg/discussion.svg',
      'Join Engaging Discussions',
   'Dive into lively discussions and debates on topics that matter to you. Share your thoughts, ask questions, and connect with like-minded individuals from around the world. With Reddit, every voice is welcome, and every conversation is an opportunity to learn and grow')
];


class PageViewData{
  final String imageUrl;
  final String title;
  final String description;

  const PageViewData(this.imageUrl,this.title,this.description);
}