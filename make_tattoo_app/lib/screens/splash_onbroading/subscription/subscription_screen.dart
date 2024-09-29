import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:get/get.dart';
import 'package:make_tattoo_app/screens/home/home_screen.dart';
import 'package:make_tattoo_app/utils/style_config.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String? _selectedSubscription;
  @override
  void initState() {
    super.initState();
    _selectedSubscription = 'LIFETIME'.tr;
  }

  void _onSubscriptionTap(String subscription) {
    setState(() {
      _selectedSubscription = subscription;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.close,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose Version',
              style: TextStyle(
                  color: Colors.amber,
                  fontSize: 26,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              'Keep using free version or Unlock All Features',
              style: TextStyle(color: textColor, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  PhosphorIcons.checks,
                  color: Color.fromARGB(255, 241, 203, 87),
                ),
                const SizedBox(width: 4),
                Text(
                  'Ad-free',
                  style: TextStyle(color: textColor, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  PhosphorIcons.checks,
                  color: Color.fromARGB(255, 241, 203, 87),
                ),
                const SizedBox(width: 4),
                Text(
                  'Premium tattoo design',
                  style: TextStyle(color: textColor, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  PhosphorIcons.checks,
                  color: Color.fromARGB(255, 241, 203, 87),
                ),
                const SizedBox(width: 4),
                Text(
                  'Best quality',
                  style: TextStyle(color: textColor, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  PhosphorIcons.checks,
                  color: Color.fromARGB(255, 241, 203, 87),
                ),
                const SizedBox(width: 4),
                Text(
                  'Latest tattoo designs access',
                  style: TextStyle(color: textColor, fontSize: 16),
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.11,
            ),
            Expanded(
              child: ListView(
                children: [
                  SubscriptionCard(
                    title: 'WEEKLY'.tr,
                    price: '48.000 đ',
                    description: 'Charged every week'.tr,
                    secondaryPrice: '161.000 đ',
                    isSelected: _selectedSubscription == 'WEEKLY'.tr,
                    isChecked: _selectedSubscription == 'WEEKLY'.tr,
                    onTap: () => _onSubscriptionTap('WEEKLY'.tr),
                  ),
                  const SizedBox(height: 6),
                  SubscriptionCard(
                    title: 'LIFETIME'.tr,
                    price: '192.598 đ',
                    description: 'Paid once only'.tr,
                    secondaryPrice: '643.362 đ',
                    isSelected: _selectedSubscription == 'LIFETIME'.tr,
                    isChecked: _selectedSubscription == 'LIFETIME'.tr,
                    onTap: () => _onSubscriptionTap('LIFETIME'.tr),
                  ),
                  const SizedBox(height: 6),
                  SubscriptionCard(
                    title: 'YEARLY'.tr,
                    price: '144.000 đ',
                    description: 'Charged every year'.tr,
                    secondaryPrice: '481.000 đ',
                    isSelected: _selectedSubscription == 'YEARLY'.tr,
                    isChecked: _selectedSubscription == 'YEARLY'.tr,
                    onTap: () => _onSubscriptionTap('YEARLY'.tr),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'GET PREMIUM VERSION'.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 221, 179, 53),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'FREE USE WITH AD'.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 10,
                left: 15,
                right: 15,
              ),
              child: Center(
                child: Text(
                  'Renews automatically. Cancel at least 24 hours prior to your renewal date'
                      .tr,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () {},
                child: Text(
                  'Terms of Use'.tr,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color.fromARGB(255, 221, 179, 53),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SubscriptionCard extends StatelessWidget {
  final String title;
  final String price;
  final String description;
  final String secondaryPrice;
  final bool isSelected;
  final bool isChecked;
  final VoidCallback onTap;

  const SubscriptionCard({
    required this.title,
    required this.price,
    required this.description,
    required this.secondaryPrice,
    required this.isSelected,
    required this.isChecked,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? Colors.amber : Colors.transparent,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                              fontSize: 18),
                        ),
                        Text(
                          price,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 255, 253, 253),
                              fontSize: 18),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            description,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white30,
                                fontSize: 15),
                          ),
                        ),
                        Text(
                          secondaryPrice,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 255, 253, 253),
                            fontSize: 18,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: Color.fromARGB(255, 255, 253, 253),
                            decorationThickness: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                isChecked
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: Colors.amber,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
