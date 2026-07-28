import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  static const String routeName = '/contact-support';

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _submitting = false);

    _formKey.currentState!.reset();
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _subjectController.clear();
    _messageController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Your message has been sent. We\'ll reply shortly.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.paddingOf(context).bottom;

    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: const TextScaler.linear(1)),
      child: Scaffold(
        backgroundColor: _ContactColors.background,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  _ContactResponsive.pagePadding(context),
                  12,
                  _ContactResponsive.pagePadding(context),
                  24 + bottomSafe,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(<Widget>[
                    const _TopBar(),
                    const SizedBox(height: 18),
                    const _HeaderSection(),
                    const SizedBox(height: 28),
                    const _ContactInfoCard(
                      icon: Icons.call_outlined,
                      title: 'Call us',
                      value: '+966 534032722',
                      hint: 'Sat–Thu, 9:00 AM – 10:00 PM',
                    ),
                    const SizedBox(height: 14),
                    const _ContactInfoCard(
                      icon: Icons.mail_outline_rounded,
                      title: 'Email us',
                      value: 'support@altamampharma.com',
                      hint: 'We reply within 24 hours',
                    ),
                    const SizedBox(height: 14),
                    const _ContactInfoCard(
                      icon: Icons.location_on_outlined,
                      title: 'Visit us',
                      value: 'Riyadh, Saudi Arabia',
                      hint: 'Open daily',
                    ),
                    const SizedBox(height: 14),
                    const _EmergencyLineNotice(),
                    const SizedBox(height: 28),
                    _MessageFormCard(
                      formKey: _formKey,
                      nameController: _nameController,
                      emailController: _emailController,
                      phoneController: _phoneController,
                      subjectController: _subjectController,
                      messageController: _messageController,
                      submitting: _submitting,
                      onSubmit: _submit,
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.maybePop(context),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _ContactColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _ContactColors.border, width: 1.2),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              size: 20,
              color: _ContactColors.title,
            ),
          ),
        ),
        const Expanded(
          child: Text(
            'Contact Support',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              height: 22 / 16,
              fontWeight: FontWeight.w600,
              color: _ContactColors.title,
            ),
          ),
        ),
        const SizedBox(width: 38),
      ],
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _ContactColors.primaryLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.support_agent_rounded,
            size: 28,
            color: _ContactColors.primary,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Contact Us',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
            height: 28 / 22,
            fontWeight: FontWeight.w700,
            color: _ContactColors.title,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Questions about an order, a product or your prescription? '
          'Our team is here to help — reach out any time.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            height: 20 / 13,
            fontWeight: FontWeight.w400,
            color: _ContactColors.body,
          ),
        ),
      ],
    );
  }
}

class _ContactInfoCard extends StatelessWidget {
  const _ContactInfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.hint,
  });

  final IconData icon;
  final String title;
  final String value;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _ContactColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _ContactColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _ContactColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: _ContactColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    height: 20 / 14,
                    fontWeight: FontWeight.w700,
                    color: _ContactColors.title,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    height: 18 / 13,
                    fontWeight: FontWeight.w500,
                    color: _ContactColors.body,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 12,
                      color: _ContactColors.muted,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        hint,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          height: 16 / 11,
                          fontWeight: FontWeight.w400,
                          color: _ContactColors.muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyLineNotice extends StatelessWidget {
  const _EmergencyLineNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _ContactColors.dangerLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _ContactColors.dangerBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.phone_in_talk_rounded,
                size: 17,
                color: _ContactColors.danger,
              ),
              const SizedBox(width: 8),
              const Text(
                'Emergency line',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w700,
                  color: _ContactColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                height: 18 / 13,
                fontWeight: FontWeight.w400,
                color: _ContactColors.title,
              ),
              children: [
                TextSpan(text: 'For urgent medicine needs, call '),
                TextSpan(
                  text: '+880 123 456 789',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _ContactColors.danger,
                  ),
                ),
                TextSpan(text: ' any time.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageFormCard extends StatelessWidget {
  const _MessageFormCard({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.subjectController,
    required this.messageController,
    required this.submitting,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController subjectController;
  final TextEditingController messageController;
  final bool submitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.sizeOf(context).width <= 380;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _ContactColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _ContactColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 20,
                  color: _ContactColors.primary,
                ),
                SizedBox(width: 8),
                Text(
                  'Send us a message',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    height: 22 / 16,
                    fontWeight: FontWeight.w700,
                    color: _ContactColors.title,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Fill in the form and we\'ll get back to you shortly.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                height: 18 / 12,
                fontWeight: FontWeight.w400,
                color: _ContactColors.body,
              ),
            ),
            const SizedBox(height: 20),
            if (isNarrow) ...[
              _FormField(
                label: 'Full name',
                required: true,
                controller: nameController,
                hint: 'Your name',
                validator: _requiredValidator,
              ),
              const SizedBox(height: 14),
              _FormField(
                label: 'Email',
                required: true,
                controller: emailController,
                hint: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                validator: _emailValidator,
              ),
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _FormField(
                      label: 'Full name',
                      required: true,
                      controller: nameController,
                      hint: 'Your name',
                      validator: _requiredValidator,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FormField(
                      label: 'Email',
                      required: true,
                      controller: emailController,
                      hint: 'you@example.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: _emailValidator,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 14),
            if (isNarrow) ...[
              _FormField(
                label: 'Phone (optional)',
                controller: phoneController,
                hint: '+880...',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),
              _FormField(
                label: 'Subject (optional)',
                controller: subjectController,
                hint: 'How can we help?',
              ),
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _FormField(
                      label: 'Phone (optional)',
                      controller: phoneController,
                      hint: '+880...',
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FormField(
                      label: 'Subject (optional)',
                      controller: subjectController,
                      hint: 'How can we help?',
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 14),
            _FormField(
              label: 'Message',
              required: true,
              controller: messageController,
              hint: 'Write your message...',
              maxLines: 5,
              validator: _requiredValidator,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: submitting ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: _ContactColors.primary,
                  foregroundColor: _ContactColors.white,
                  disabledBackgroundColor: _ContactColors.primary.withValues(
                    alpha: 0.6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: _ContactColors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Send Message',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              height: 22 / 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.send_rounded, size: 18),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  static String? _emailValidator(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'This field is required';
    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed);
    if (!valid) return 'Enter a valid email address';
    return null;
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.controller,
    required this.hint,
    this.required = false,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final bool required;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              height: 18 / 13,
              fontWeight: FontWeight.w600,
              color: _ContactColors.title,
            ),
            children: [
              TextSpan(text: label),
              if (required)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: _ContactColors.danger),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          textCapitalization: maxLines > 1
              ? TextCapitalization.sentences
              : TextCapitalization.none,
          inputFormatters: keyboardType == TextInputType.phone
              ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s]'))]
              : null,
          validator: validator,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: _ContactColors.title,
          ),
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: _ContactColors.muted,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: maxLines > 1 ? 14 : 15,
            ),
            filled: true,
            fillColor: _ContactColors.card,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _ContactColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _ContactColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: _ContactColors.primary,
                width: 1.4,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _ContactColors.danger),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _ContactColors.danger),
            ),
            errorStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: _ContactColors.danger,
            ),
          ),
        ),
      ],
    );
  }
}

class _ContactResponsive {
  static double pagePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width <= 340) return 16;
    if (width <= 390) return 20;
    if (width <= 480) return 24;
    return 32;
  }
}

class _ContactColors {
  static const Color white = Color(0xffffffff);
  static const Color background = Color(0xfff7f8fa);
  static const Color title = Color(0xff131415);
  static const Color body = Color(0xff666e80);
  static const Color muted = Color(0xff98a1b3);
  static const Color border = Color(0xffe1e2e6);
  static const Color card = Color(0xfff7f8fa);

  static const Color primary = Color(0xff0b83d9);
  static const Color primaryLight = Color(0xffe7f3fb);

  static const Color danger = Color(0xffd92d20);
  static const Color dangerLight = Color(0xfffef3f2);
  static const Color dangerBorder = Color(0xfffecdca);
}
