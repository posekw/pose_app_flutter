import 'gallery_detail_model.dart';

class CartItem {
  final GalleryImage image;
  final ProductVariation variation;

  CartItem({
    required this.image,
    required this.variation,
  });

  double get price => variation.price;
}
