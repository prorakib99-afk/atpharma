import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/validation/checkout_validation.dart';
import '../../../../core/validation/checkout_phone_input_formatter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../shared/widgets/navigation_page_scaffold.dart';
import '../bloc/checkout/checkout_bloc.dart';
import '../bloc/checkout/checkout_event.dart';
import '../bloc/checkout/checkout_state.dart';
import 'favorite_header_button.dart';
import 'floating_profile_screen.dart';
import 'notification_screen.dart';
import 'review_order_screen.dart';
import 'screen_product_details.dart';

void _openNotifications(BuildContext context) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.08),
    builder: (_) => const SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: EdgeInsets.only(top: 66, right: 28),
          child: NotificationScreen(maxHeight: 280, width: 330),
        ),
      ),
    ),
  );
}

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, this.purchaseItems, this.initialArguments});

  static const String routeName = '/checkout';
  final List<ProductCartItem>? purchaseItems;
  final ReviewOrderArguments? initialArguments;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _address1Controller = TextEditingController();
  final TextEditingController _address2Controller = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final ReviewOrderArguments? initial = widget.initialArguments;
    if (initial != null) {
      _fullNameController.text = initial.fullName;
      _phoneController.text = initial.phone;
      _address1Controller.text = initial.addressLine1;
      _address2Controller.text = initial.addressLine2;
      _districtController.text = initial.district;
      _postalCodeController.text = initial.postalCode;
    }
  }

  List<ProductCartItem> get _items =>
      widget.purchaseItems ?? ProductCart.instance.items;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _districtController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    context.read<CheckoutBloc>().add(
      CheckoutSubmitted(
        items: _items,
        fullName: _fullNameController.text,
        phone: _phoneController.text,
        addressLine1: _address1Controller.text,
        addressLine2: _address2Controller.text,
        district: _districtController.text,
        postalCode: _postalCodeController.text,
      ),
    );
  }

  void _selectCountry({bool forPhone = false}) {
    showCountryPicker(
      context: context,
      showPhoneCode: forPhone,
      favorite: const <String>['SA', 'AE', 'BD', 'IN', 'GB', 'US'],
      countryListTheme: CountryListThemeData(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        bottomSheetHeight: MediaQuery.sizeOf(context).height * .72,
        inputDecoration: _CheckoutInputDecoration.inputDecoration(
          hint: 'Search country',
        ),
      ),
      onSelect: (Country country) {
        _phoneController.clear();
        context.read<CheckoutBloc>().add(
          CheckoutCountryChanged(
            name: country.name,
            countryCode: country.countryCode,
            phoneCode: country.phoneCode,
            flagEmoji: country.flagEmoji,
          ),
        );
      },
    );
  }

  Future<void> _selectCity(CheckoutState state) async {
    if (state.status == CheckoutStatus.loadingCities || state.cities.isEmpty) {
      return;
    }
    final String? city = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (BuildContext context) => _CityPickerSheet(
        countryName: state.countryName,
        cities: state.cities,
      ),
    );
    if (city != null && mounted) {
      context.read<CheckoutBloc>().add(CheckoutCityChanged(city));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.paddingOf(context).bottom;
    final pagePadding = _CheckoutResponsive.pagePadding(context);
    final List<ProductCartItem> cartItems = _items;
    final int itemCount = cartItems.fold<int>(
      0,
      (int sum, ProductCartItem item) => sum + item.quantity,
    );
    final double total = cartItems.fold<double>(
      0,
      (double sum, ProductCartItem item) =>
          sum + (item.product.price * item.quantity),
    );

    return BlocConsumer<CheckoutBloc, CheckoutState>(
      listenWhen: (CheckoutState previous, CheckoutState current) =>
          previous.status != current.status ||
          previous.message != current.message,
      listener: (BuildContext context, CheckoutState state) {
        if (state.status == CheckoutStatus.success) {
          Navigator.of(context).pushNamed(
            AppRoutes.stripePayment,
            arguments: ReviewOrderArguments(
              purchaseItems: widget.purchaseItems,
              fullName: state.fullName,
              phone: state.phone,
              addressLine1: state.addressLine1,
              addressLine2: state.addressLine2,
              district: state.district,
              postalCode: state.postalCode,
              countryName: state.countryName,
              city: state.city,
            ),
          );
        } else if (state.status == CheckoutStatus.failure &&
            state.message != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message!)));
        }
      },
      builder: (BuildContext context, CheckoutState state) =>
          NavigationPageScaffold(
            currentPage: NavigationPage.cart,
            backgroundColor: _CheckoutColors.white,
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      pagePadding,
                      8,
                      pagePadding,
                      0,
                    ),
                    child: _CheckoutHeader(itemCount: itemCount),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      pagePadding,
                      24,
                      pagePadding,
                      0,
                    ),
                    child: const _CheckoutStepCard(),
                  ),
                  Expanded(
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            pagePadding,
                            24,
                            pagePadding,
                            120 + bottomSafe,
                          ),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              _ShippingSectionHeader(onNext: _submit),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _CheckoutColors.card,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: <Widget>[
                                    _InputField(
                                      label: 'Full Name',
                                      hint: 'Enter your full name',
                                      required: true,
                                      controller: _fullNameController,
                                      errorText: state.fieldErrors['fullName'],
                                      textInputAction: TextInputAction.next,
                                    ),
                                    const SizedBox(height: 16),
                                    _PhoneInputField(
                                      controller: _phoneController,
                                      state: state,
                                      onCountryTap: () =>
                                          _selectCountry(forPhone: true),
                                      errorText: state.fieldErrors['phone'],
                                    ),
                                    const SizedBox(height: 16),
                                    _ResponsiveTwoColumn(
                                      left: _SelectField(
                                        label: 'Country',
                                        value: state.countryName,
                                        required: true,
                                        onTap: _selectCountry,
                                        errorText: state.fieldErrors['country'],
                                      ),
                                      right: _SelectField(
                                        label: 'City',
                                        value: state.city ?? 'Select city',
                                        required: true,
                                        loading:
                                            state.status ==
                                            CheckoutStatus.loadingCities,
                                        onTap: () => _selectCity(state),
                                        errorText: state.fieldErrors['city'],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    _InputField(
                                      label: 'Address Line 1',
                                      hint:
                                          'House/Building No, Street Name, Area',
                                      required: true,
                                      controller: _address1Controller,
                                      errorText:
                                          state.fieldErrors['addressLine1'],
                                      textInputAction: TextInputAction.next,
                                    ),
                                    const SizedBox(height: 16),
                                    _InputField(
                                      label: 'Address Line 2 (Optional)',
                                      hint: 'Apartment, Suite, Floor, Landmark',
                                      controller: _address2Controller,
                                      textInputAction: TextInputAction.next,
                                    ),
                                    const SizedBox(height: 16),
                                    _ResponsiveTwoColumn(
                                      left: _InputField(
                                        label: 'District',
                                        hint: 'Enter your district',
                                        required: true,
                                        controller: _districtController,
                                        errorText:
                                            state.fieldErrors['district'],
                                        textInputAction: TextInputAction.next,
                                      ),
                                      right: _InputField(
                                        label: 'Postal Code',
                                        hint: 'Enter postal code',
                                        required: true,
                                        controller: _postalCodeController,
                                        errorText:
                                            state.fieldErrors['postalCode'],
                                        keyboardType: TextInputType.number,
                                        textInputAction: TextInputAction.done,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              const _TermsAndPrivacyText(),
                              const SizedBox(height: 24),
                              _ContinueButton(
                                total: total,
                                isLoading: state.isSubmitting,
                                onPressed: _submit,
                              ),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

class _CheckoutHeader extends StatelessWidget {
  const _CheckoutHeader({required this.itemCount});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width <= 390;

    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Checkout',
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      height: 22 / 16,
                      fontWeight: FontWeight.w600,
                      color: _CheckoutColors.title,
                    ),
                  ),
                ),
              ),
              SizedBox(width: compact ? 6 : 10),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 8 : 11,
                  vertical: compact ? 6 : 8,
                ),
                decoration: BoxDecoration(
                  color: _CheckoutColors.primaryLight,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '${itemCount.toString().padLeft(2, '0')} Items',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w500,
                    color: _CheckoutColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: compact ? 8 : 12),
        _RoundIconButton(
          icon: Icons.notifications_none_rounded,
          onTap: () => _openNotifications(context),
        ),
        SizedBox(width: compact ? 6 : 8),
        FavoriteHeaderButton(
          size: 40,
          iconSize: 20,
          borderColor: _CheckoutColors.card,
          inactiveColor: _CheckoutColors.title,
        ),
        SizedBox(width: compact ? 6 : 8),
        const _ProfileAvatar(),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const size = 40.0;

    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _CheckoutColors.white,
          shape: BoxShape.circle,
          border: Border.all(color: _CheckoutColors.card),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 28,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: _CheckoutColors.title),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    const size = 40.0;

    return InkWell(
      onTap: () => FloatingProfileScreen.show(
        context,
        avatarAssetPath: 'assets/images/at_pharma_icon.png',
        onProfileTap: () => Navigator.of(context).pushNamed(AppRoutes.profile),
        onSignOutTap: () => signOutFromProfile(context),
      ),
      customBorder: const CircleBorder(),
      child: ClipOval(
        child: Image.asset(
          'assets/images/at_pharma_icon.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _ShippingSectionHeader extends StatelessWidget {
  const _ShippingSectionHeader({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Expanded(
          child: Text(
            'Shipping Details',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              height: 22 / 16,
              fontWeight: FontWeight.w600,
              color: _CheckoutColors.title,
            ),
          ),
        ),
        InkWell(
          onTap: onNext,
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            child: Row(
              children: <Widget>[
                Text(
                  'Next',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _CheckoutColors.title,
                  ),
                ),
                SizedBox(width: 2),
                Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CheckoutStepCard extends StatelessWidget {
  const _CheckoutStepCard();

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.sizeOf(context).width <= 360;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 14 : 18,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: _CheckoutColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _CheckoutColors.white, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const _StepItem(
            icon: Icons.local_shipping_outlined,
            label: 'Shipping',
            active: true,
          ),
          const _StepLine(),
          const _StepItem(icon: Icons.credit_card_rounded, label: 'Payment'),
          const _StepLine(),
          const _StepItem(icon: Icons.receipt_long_rounded, label: 'Review'),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.icon,
    required this.label,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: active ? _CheckoutColors.primary : _CheckoutColors.white,
              shape: BoxShape.circle,
              border: active
                  ? null
                  : Border.all(color: _CheckoutColors.body, width: 1.6),
            ),
            child: Icon(
              icon,
              size: 16,
              color: active ? _CheckoutColors.white : _CheckoutColors.body,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              height: 16 / 12,
              fontWeight: FontWeight.w500,
              color: active ? _CheckoutColors.primary : _CheckoutColors.body,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepLine extends StatelessWidget {
  const _StepLine();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 22),
        child: Container(
          height: 2,
          decoration: BoxDecoration(
            color: _CheckoutColors.border,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.hint,
    this.required = false,
    this.keyboardType,
    this.textInputAction,
    this.controller,
    this.errorText,
  });

  final String label;
  final String hint;
  final bool required;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextEditingController? controller;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: label, required: required),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            height: 16 / 12,
            fontWeight: FontWeight.w400,
            color: _CheckoutColors.title,
          ),
          decoration: _CheckoutInputDecoration.inputDecoration(
            hint: hint,
            errorText: errorText,
          ),
        ),
      ],
    );
  }
}

class _PhoneInputField extends StatelessWidget {
  const _PhoneInputField({
    required this.controller,
    required this.state,
    required this.onCountryTap,
    this.errorText,
  });

  final TextEditingController controller;
  final CheckoutState state;
  final VoidCallback onCountryTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.sizeOf(context).width <= 340;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        final errorText = value.text.isEmpty
            ? this.errorText
            : CheckoutValidation.phone(
                value.text,
                countryCode: state.countryCode,
                countryName: state.countryName,
              );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _FieldLabel(label: 'Phone Number', required: true),
            const SizedBox(height: 4),
            Container(
              height: 44,
              padding: EdgeInsets.symmetric(horizontal: isSmall ? 10 : 16),
              decoration: BoxDecoration(
                color: _CheckoutColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: errorText == null
                      ? _CheckoutColors.border
                      : _CheckoutColors.danger,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: onCountryTap,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          state.flagEmoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: _CheckoutColors.title,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '+${state.phoneCode}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      height: 20 / 14,
                      fontWeight: FontWeight.w400,
                      color: _CheckoutColors.muted,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 1,
                    height: 24,
                    color: _CheckoutColors.border,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        CheckoutPhoneInputFormatter(state.countryCode),
                      ],
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        hintText: 'Number without country code',
                        hintStyle: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          height: 20 / 14,
                          fontWeight: FontWeight.w400,
                          color: _CheckoutColors.muted,
                        ),
                      ),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        height: 20 / 14,
                        fontWeight: FontWeight.w400,
                        color: _CheckoutColors.title,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (errorText != null) ...<Widget>[
              const SizedBox(height: 6),
              Text(errorText, style: _CheckoutInputDecoration.errorStyle),
            ],
          ],
        );
      },
    );
  }
}

class _SelectField extends StatelessWidget {
  const _SelectField({
    required this.label,
    required this.value,
    this.required = false,
    this.onTap,
    this.loading = false,
    this.errorText,
  });

  final String label;
  final String value;
  final bool required;
  final VoidCallback? onTap;
  final bool loading;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: label, required: required),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: _CheckoutColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _CheckoutColors.border, width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      height: 16 / 12,
                      fontWeight: FontWeight.w400,
                      color: _CheckoutColors.title,
                    ),
                  ),
                ),
                if (loading)
                  const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 22,
                    color: _CheckoutColors.title,
                  ),
              ],
            ),
          ),
        ),
        if (errorText != null) ...<Widget>[
          const SizedBox(height: 6),
          Text(errorText!, style: _CheckoutInputDecoration.errorStyle),
        ],
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, this.required = false});

  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              height: 24 / 14,
              fontWeight: FontWeight.w500,
              color: _CheckoutColors.textPrimary,
            ),
          ),
        ),
        if (required) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              height: 24 / 14,
              fontWeight: FontWeight.w500,
              color: _CheckoutColors.danger,
            ),
          ),
        ],
      ],
    );
  }
}

class _ResponsiveTwoColumn extends StatelessWidget {
  const _ResponsiveTwoColumn({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    final shouldStack = MediaQuery.sizeOf(context).width <= 330;

    if (shouldStack) {
      return Column(children: [left, const SizedBox(height: 20), right]);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({
    required this.total,
    required this.isLoading,
    required this.onPressed,
  });

  final double total;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_CheckoutColors.primary, Color(0xff0968c3)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            alignment: Alignment.center,
            child: isLoading
                ? const SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Continue to Payment  •  SAR ${total.toStringAsFixed(2)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      height: 24 / 14,
                      fontWeight: FontWeight.w500,
                      color: _CheckoutColors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _TermsAndPrivacyText extends StatelessWidget {
  const _TermsAndPrivacyText();

  @override
  Widget build(BuildContext context) {
    const baseStyle = TextStyle(
      fontFamily: 'Poppins',
      fontSize: 12,
      height: 16 / 12,
      color: _CheckoutColors.body,
    );
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text('By continuing, you agree to our ', style: baseStyle),
        InkWell(
          onTap: () =>
              Navigator.of(context).pushNamed(AppRoutes.termsAndConditions),
          borderRadius: BorderRadius.circular(4),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 2),
            child: Text(
              'Terms & Conditions',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                height: 16 / 12,
                fontWeight: FontWeight.w600,
                color: _CheckoutColors.primary,
              ),
            ),
          ),
        ),
        const Text(' and ', style: baseStyle),
        InkWell(
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.privacyPolicy),
          borderRadius: BorderRadius.circular(4),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 2),
            child: Text(
              'Privacy Policy',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                height: 16 / 12,
                fontWeight: FontWeight.w600,
                color: _CheckoutColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CityPickerSheet extends StatefulWidget {
  const _CityPickerSheet({required this.countryName, required this.cities});

  final String countryName;
  final List<String> cities;

  @override
  State<_CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<_CityPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final List<String> visible = widget.cities
        .where(
          (String city) => city.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList(growable: false);
    return FractionallySizedBox(
      heightFactor: .72,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Select city in ${widget.countryName}',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              autofocus: true,
              onChanged: (String value) => setState(() => _query = value),
              decoration: _CheckoutInputDecoration.inputDecoration(
                hint: 'Search city',
              ).copyWith(prefixIcon: const Icon(Icons.search_rounded)),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: visible.isEmpty
                  ? const Center(child: Text('No cities found.'))
                  : ListView.separated(
                      itemCount: visible.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (BuildContext context, int index) {
                        final String city = visible[index];
                        return ListTile(
                          title: Text(city),
                          onTap: () => Navigator.of(context).pop(city),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutInputDecoration {
  static const TextStyle errorStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 11,
    color: _CheckoutColors.danger,
  );

  static InputDecoration inputDecoration({
    required String hint,
    String? errorText,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w400,
        color: _CheckoutColors.muted,
      ),
      filled: true,
      errorText: errorText,
      errorStyle: errorStyle,
      fillColor: _CheckoutColors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _CheckoutColors.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _CheckoutColors.primary, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _CheckoutColors.danger, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _CheckoutColors.danger, width: 1),
      ),
    );
  }
}

class _CheckoutResponsive {
  static double pagePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width <= 340) return 16;
    if (width <= 390) return 20;
    if (width <= 480) return 24;
    return 32;
  }
}

class _CheckoutColors {
  static const Color white = Color(0xffffffff);
  static const Color title = Color(0xff131415);
  static const Color textPrimary = Color(0xff191e28);
  static const Color body = Color(0xff666e80);
  static const Color muted = Color(0xff98a1b3);
  static const Color border = Color(0xffe1e2e6);
  static const Color card = Color(0xfff7f8fa);
  static const Color primary = Color(0xff0b83d9);
  static const Color primaryLight = Color(0xffe7f3fb);
  static const Color danger = Color(0xffe71c05);
}
