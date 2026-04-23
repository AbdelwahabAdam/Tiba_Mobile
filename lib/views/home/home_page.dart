import 'package:flutter/material.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/user_segment_controller.dart';
import '../../core/services/token_storage.dart';
import '../categories/category_page.dart';
import '../categories/sub_category_page.dart';
import '../orders/order_page.dart';
import '../products/price_segment.dart';
import '../products/product_page.dart';
import '../banners/banner_page.dart';
import '../offers/offer_page.dart';
import '../users/user_page.dart';
import '../users/user_segment.dart';
import 'account_page.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;
  List<Widget> pages = [];
  List<BottomNavigationBarItem> tabs = [];
  bool _bootstrapped = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final productCtrl = Get.put(ProductController(), permanent: true);
    await productCtrl.loadAllForLookup();

    final userSegmentCtrl = Get.put(UserSegmentController(), permanent: true);
    await userSegmentCtrl.fetch(reset: true);

    await loadRole();
  }

  Future<void> loadRole() async {
    final role = await TokenStorage.read('role');

    if (role == 'admin') {
      pages = [
        CategoryPage(),
        SubCategoryPage(),
        ProductPage(),
        OfferPage(),
        BannerPage(),
        OrderPage(),
        UserPage(),
        UserSegmentPage(),
        PriceSegmentPage(),
        const AccountPage(),
      ];

      tabs = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.category_outlined),
          activeIcon: Icon(Icons.category),
          label: 'Categories',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt_outlined),
          activeIcon: Icon(Icons.list_alt_rounded),
          label: 'Subcategories',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag_outlined),
          activeIcon: Icon(Icons.shopping_bag),
          label: 'Products',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_offer_outlined),
          activeIcon: Icon(Icons.local_offer),
          label: 'Offers',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.view_carousel_outlined),
          activeIcon: Icon(Icons.view_carousel),
          label: 'Banners',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          activeIcon: Icon(Icons.people),
          label: 'Users',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group_outlined),
          activeIcon: Icon(Icons.group),
          label: 'Segments',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.price_change_outlined),
          activeIcon: Icon(Icons.price_change),
          label: 'Pricing',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Account',
        ),
      ];
    } else {
      pages = [CategoryPage(), const AccountPage()];

      tabs = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.category),
          label: 'Categories',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
      ];
    }

    setState(() {
      _bootstrapped = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_bootstrapped || pages.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.admin_panel_settings_rounded,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Loading...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: pages[index],
      bottomNavigationBar: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: index,
          items: tabs,
          onTap: (i) => setState(() => index = i),
        ),
      ),
    );
  }
}
