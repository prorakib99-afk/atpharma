import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _sections = <({String title, String body})>[
    (
      title: '1. Information We Collect',
      body:
          'We collect information you provide directly - such as your name, contact details, delivery address, and order history - as well as information needed to process payments and, where applicable, prescriptions.\n\nWe also collect limited technical information automatically, such as device and browsing data, to operate and improve the service.',
    ),
    (
      title: '2. How We Use Your Information',
      body:
          'We use your information to process and deliver orders, verify prescriptions, provide customer support, prevent fraud, comply with legal obligations, and - where you have opted in - send you offers and updates.',
    ),
    (
      title: '3. Sharing Your Information',
      body:
          'We share information only as needed to run the service: with payment processors (such as Stripe), delivery partners, and service providers acting on our behalf, or when required by law. We do not sell your personal information.',
    ),
    (
      title: '4. Cookies & Tracking',
      body:
          'We use cookies and similar technologies to keep you signed in, remember your cart, and understand how the site is used. You can control cookies through your browser settings, though some features may not work without them.',
    ),
    (
      title: '5. Data Security',
      body:
          'We apply reasonable technical and organizational measures to protect your information. Card details are handled by our PCI-compliant payment providers and are not stored on our servers. No method of transmission or storage is completely secure, however.',
    ),
    (
      title: '6. Your Rights',
      body:
          'Subject to applicable law, you may request access to, correction of, or deletion of your personal information, and you may opt out of marketing communications at any time. To exercise these rights, contact us using the details below.',
    ),
    (
      title: '7. Data Retention',
      body:
          'We retain your information for as long as needed to provide the service and to meet legal, accounting, and regulatory requirements - for example, records related to medicine orders may be kept for a period required by law.',
    ),
    (
      title: "8. Children's Privacy",
      body:
          'The service is intended for adults. We do not knowingly collect personal information from children. If you believe a child has provided us information, please contact us so we can remove it.',
    ),
    (
      title: '9. Changes to This Policy',
      body:
          'We may update this Privacy Policy from time to time. Changes take effect when posted on this page, with the date above reflecting the latest revision.',
    ),
    (
      title: '10. Contact Us',
      body:
          'For privacy questions or requests, email us at support@atmart.com.',
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
                        'Privacy Policy',
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
                          'This policy explains what information Taj AL Tamam Pharmacy collects, how we use it, and the choices you have. It applies to your use of our website and services.',
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
