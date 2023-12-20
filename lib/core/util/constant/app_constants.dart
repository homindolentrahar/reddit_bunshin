import 'package:reddit_bunshin/gen/assets.gen.dart';

abstract class AppConstants {
  static const bannerDefault =
      "https://thumbs.dreamstime.com/b/abstract-stained-pattern-rectangle-background-blue-sky-over-fiery-red-orange-color-modern-painting-art-watercolor-effe-texture-123047399.jpg";
  static const avatarDefault =
      "https://external-preview.redd.it/5kh5OreeLd85QsqYO1Xz_4XSLYwZntfjqou-8fyBFoE.png?auto=webp&s=dbdabd04c399ce9c761ff899f5d38656d1de87c2";

  static final awards = {
    'awesomeAns': Assets.images.award.awesomeanswer.path,
    'gold': Assets.images.award.gold.path,
    'platinum': Assets.images.award.platinum.path,
    'helpful': Assets.images.award.helpful.path,
    'plusone': Assets.images.award.plusone.path,
    'rocket': Assets.images.award.rocket.path,
    'thankyou': Assets.images.award.thankyou.path,
    'til': Assets.images.award.til.path,
  };
}
