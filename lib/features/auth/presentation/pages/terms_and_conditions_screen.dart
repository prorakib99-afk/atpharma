import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});
  static const _sections = <({String title, String body})>[
    (
      title: '1. Acceptance of Terms',
      body:
          'By accessing or using the Taj AL Tamam Pharmacy website and placing an order, you agree to be bound by these Terms & Conditions and all policies referenced here. If you do not agree, please do not use the service.',
    ),
    (
      title: '2. Eligibility',
      body:
          'You must be at least 18 years old and capable of forming a legally binding contract to place an order. By ordering, you confirm that the information you provide is accurate and complete.',
    ),
    (
      title: '3. Products & Pricing',
      body:
          'We make every effort to display product details, availability, and prices accurately. Prices are shown in the currency indicated at checkout and may change without notice.\n\nIn the event of a pricing or description error, we reserve the right to cancel or correct the affected order and refund any amount already charged.',
    ),
    (
      title: '4. Prescription Medicines',
      body:
          'Certain products are marked as prescription-only. For these items you may be required to provide a valid prescription before your order is dispatched. Orders that cannot be verified may be cancelled and refunded.\n\nTaj AL Tamam Pharmacy does not provide medical advice. Always consult a qualified healthcare professional before starting, stopping, or changing any medication.',
    ),
    (
      title: '5. Orders & Payment',
      body:
          'An order constitutes an offer to purchase. We may accept or decline it at our discretion. Payment is processed securely through our payment providers (including Stripe) or collected as cash on delivery where available.\n\nPlacing an order authorizes us to charge the selected payment method for the order total, including applicable taxes and delivery charges.',
    ),
    (
      title: '6. Shipping & Delivery',
      body:
          'Delivery times are estimates and are not guaranteed. Risk of loss passes to you upon delivery. Please ensure the delivery address and contact details are correct.',
    ),
    (
      title: '7. Returns & Refunds',
      body:
          'For reasons of safety and regulation, medicines and certain healthcare products may not be returnable once dispatched, except where the item is damaged, defective, or incorrectly supplied. Contact our support team as soon as possible to arrange a resolution.',
    ),
    (
      title: '8. Acceptable Use',
      body:
          'You agree not to misuse the service, attempt to gain unauthorized access, disrupt the platform, or use it for any unlawful purpose. We may suspend or terminate access for any breach of these terms.',
    ),
    (
      title: '9. Limitation of Liability',
      body:
          'To the fullest extent permitted by law, Taj AL Tamam Pharmacy is not liable for any indirect, incidental, or consequential damages arising from your use of the service. Nothing in these terms limits liability that cannot be excluded by law.',
    ),
    (
      title: '10. Changes to These Terms',
      body:
          'We may update these Terms & Conditions from time to time. Changes take effect when posted on this page. Your continued use of the service after changes are posted constitutes acceptance of the revised terms.',
    ),
    (
      title: '11. Contact Us',
      body: 'Questions about these terms can be sent to support@atmart.com.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.sizeOf(context).width <= 390 ? 20.0 : 24.0;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(padding - 8, 4, 16, 0),
              child: TextButton.icon(
                onPressed: () => Navigator.of(context).maybePop(),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xff0b83d9),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                ),
                icon: const Icon(Icons.arrow_back_rounded, size: 20),
                label: const Text(
                  'Back',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            Expanded(
              child: Scrollbar(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(padding, 8, padding, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Terms & Conditions',
                        style: TextStyle(
                          fontSize: 24,
                          height: 32 / 24,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff131415),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Last updated: 12 July 2026',
                        style: TextStyle(
                          fontSize: 11,
                          height: 16 / 11,
                          color: Color(0xff98a1b3),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xffe7f3fb),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Please read these terms carefully before using Taj AL Tamam Pharmacy. They set out the rules for using our website and purchasing medicines and healthcare products from us.',
                          style: TextStyle(
                            fontSize: 12,
                            height: 20 / 12,
                            color: Color(0xff415265),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      for (final section in _sections) ...[
                        Text(
                          section.title,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 22 / 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff191e28),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          section.body,
                          style: const TextStyle(
                            fontSize: 12,
                            height: 20 / 12,
                            color: Color(0xff666e80),
                          ),
                        ),
                        const SizedBox(height: 22),
                      ],
                    ],
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
