import '../entities/promo_banner.dart';

abstract class BannerRepository {
  Stream<List<PromoBanner>> watchActiveBanners();
}
