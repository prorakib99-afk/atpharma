import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../shared/widgets/navigation_page_scaffold.dart';

class PrescriptionScreen extends StatefulWidget {
  const PrescriptionScreen({
    super.key,
    this.onAttachTap,
    this.onCameraTap,
    this.onSendMessage,
    this.answerQuestion,
  });

  final VoidCallback? onAttachTap;
  final VoidCallback? onCameraTap;
  final ValueChanged<String>? onSendMessage;
  final Future<String> Function(String question)? answerQuestion;

  static const String routeName = '/prescription';

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  static const int _maxUploadBytes = 15 * 1024 * 1024;

  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = <_ChatMessage>[];
  final ImagePicker _imagePicker = ImagePicker();
  bool _isAnswering = false;

  static const _suggestions = <_SuggestionItem>[
    _SuggestionItem(Icons.medication_outlined, 'Paracetamol 500mg'),
    _SuggestionItem(Icons.wb_sunny_outlined, 'Vitamin D3'),
    _SuggestionItem(Icons.water_drop_outlined, 'Cough syrup'),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send([String? suggestion]) async {
    final text = (suggestion ?? _messageController.text).trim();
    if (text.isEmpty || _isAnswering) return;
    widget.onSendMessage?.call(text);
    _messageController.clear();
    setState(() {
      _messages.add(_ChatMessage(text, isUser: true));
      _isAnswering = true;
    });
    _scrollToBottom();

    try {
      final answer =
          await (widget.answerQuestion?.call(text) ??
              _MedicalKnowledgeBase.answer(text));
      if (!mounted) return;
      setState(() => _messages.add(_ChatMessage(answer)));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          const _ChatMessage(
            'I could not answer that right now. Please try again, or ask a pharmacist for help.',
            isError: true,
          ),
        );
      });
    } finally {
      if (mounted) {
        setState(() => _isAnswering = false);
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _capturePrescription() async {
    if (widget.onCameraTap != null) {
      widget.onCameraTap!();
      return;
    }

    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );
      if (photo == null) return;

      final int size = await photo.length();
      if (size > _maxUploadBytes) {
        _showUploadError(
          'The captured photo is ${_formatBytes(size)}. '
          'Please upload a file smaller than 15 MB.',
        );
        return;
      }
      _recordUpload(imageBytes: await photo.readAsBytes());
    } on PlatformException catch (error) {
      final denied =
          error.code == 'camera_access_denied' ||
          error.code == 'camera_access_denied_without_prompt' ||
          error.code == 'camera_access_restricted';
      _showUploadError(
        denied
            ? 'Camera permission is required. Please allow camera access from your device settings and try again.'
            : 'Could not open the camera. Please try again.',
      );
    }
  }

  Future<void> _pickPrescription() async {
    if (widget.onAttachTap != null) {
      widget.onAttachTap!();
      return;
    }

    try {
      final FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        withData: true,
        allowedExtensions: const <String>['jpg', 'jpeg', 'png', 'webp', 'pdf'],
      );
      if (result == null || result.files.isEmpty) return;

      final PlatformFile file = result.files.single;
      if (file.size > _maxUploadBytes) {
        _showUploadError(
          '${file.name} is ${_formatBytes(file.size)}. '
          'Only images or PDFs up to 15 MB can be uploaded.',
        );
        return;
      }
      final String extension = file.extension?.toLowerCase() ?? '';
      final bool isImage = <String>{
        'jpg',
        'jpeg',
        'png',
        'webp',
      }.contains(extension);
      _recordUpload(
        imageBytes: isImage ? file.bytes : null,
        isPdf: extension == 'pdf',
      );
    } on PlatformException {
      _showUploadError(
        'Could not select that file. Please choose an image or PDF up to 15 MB.',
      );
    }
  }

  void _recordUpload({
    Uint8List? imageBytes,
    bool isPdf = false,
  }) {
    if (!mounted) return;
    setState(() {
      _messages.add(
        _ChatMessage(
          '',
          isUser: true,
          imageBytes: imageBytes,
          isPdf: isPdf,
        ),
      );
    });
    _scrollToBottom();
  }

  void _showUploadError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFB42318),
        ),
      );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: NavigationPageScaffold(
        currentPage: NavigationPage.prescription,
        backgroundColor: Colors.white,
        extendBody: false,
        body: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = constraints.maxWidth <= 340
                  ? 16.0
                  : 20.0;
              return Stack(
                children: [
                  const _BackgroundGlow(),
                  Column(
                    children: [
                      Expanded(
                        child: CustomScrollView(
                          controller: _scrollController,
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          physics: const BouncingScrollPhysics(),
                          slivers: [
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(
                                horizontalPadding,
                                constraints.maxHeight <= 650 ? 10 : 16,
                                horizontalPadding,
                                12,
                              ),
                              sliver: SliverList.list(
                                children: [
                                  const _AnimatedAssistantOrb(),
                                  const SizedBox(height: 16),
                                  const _AssistantBadge(),
                                  const SizedBox(height: 24),
                                  const _HeroText(),
                                  const SizedBox(height: 32),
                                  const _DisclaimerCard(),
                                  const SizedBox(height: 48),
                                  _SuggestionChips(
                                    suggestions: _suggestions,
                                    onSelected: _send,
                                  ),
                                  if (_messages.isNotEmpty) ...[
                                    const SizedBox(height: 20),
                                    _ChatHistory(
                                      messages: _messages,
                                      isAnswering: _isAnswering,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          8,
                          horizontalPadding,
                          12,
                        ),
                        child: _MessageComposer(
                          controller: _messageController,
                          onCameraTap: _capturePrescription,
                          onAttachTap: _pickPrescription,
                          onSendTap: _send,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            left: -210,
            top: -150,
            child: _glow(380, const Color(0x1F0B83D9)),
          ),
          Positioned(
            right: -245,
            top: 30,
            child: _glow(420, const Color(0x1C0B83D9)),
          ),
        ],
      ),
    );
  }

  Widget _glow(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: [color, color.withValues(alpha: .04), Colors.transparent],
      ),
    ),
  );
}

class _AnimatedAssistantOrb extends StatefulWidget {
  const _AnimatedAssistantOrb();

  @override
  State<_AnimatedAssistantOrb> createState() => _AnimatedAssistantOrbState();
}

class _AnimatedAssistantOrbState extends State<_AnimatedAssistantOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context).width <= 340 ? 160.0 : 183.0;
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final progress = disableAnimations ? 0.0 : _controller.value;
            final phase = progress * math.pi * 2;
            final wave = (math.sin(phase) + 1) / 2;
            return Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: size * (.82 + wave * .15),
                  height: size * (.82 + wave * .15),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(
                          0xFF168BFF,
                        ).withValues(alpha: .16 + wave * .20),
                        blurRadius: 24 + wave * 24,
                        spreadRadius: 2 + wave * 5,
                      ),
                    ],
                  ),
                ),
                CustomPaint(
                  size: Size.square(size * .79),
                  painter: _GlowRingPainter(),
                ),
                child!,
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, .0012)
                    ..rotateX(math.sin(phase) * .045)
                    ..rotateZ(phase),
                  child: ClipOval(
                    child: SizedBox(
                      width: size * .657,
                      height: size * .657,
                      child: Stack(
                        clipBehavior: Clip.hardEdge,
                        children: <Widget>[
                          Positioned.fill(
                            child: SvgPicture.asset(
                              'assets/icons/ai_sphere_base.svg',
                              fit: BoxFit.fill,
                            ),
                          ),
                          Positioned(
                            left: size * -.141,
                            top: size * -.0615,
                            width: size * .912,
                            height: size * .773,
                            child: SvgPicture.asset(
                              'assets/icons/ai_orb_ribbons.svg',
                              fit: BoxFit.fill,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SvgPicture.asset(
                  'assets/icons/ai_outer_rim.svg',
                  width: size * .657,
                  height: size * .657,
                  fit: BoxFit.fill,
                ),
                Positioned(
                  left: size * .204,
                  top: size * .176,
                  width: size * .552,
                  height: size * .193,
                  child: SvgPicture.asset(
                    'assets/icons/ai_upper_rim_highlight.svg',
                    fit: BoxFit.fill,
                  ),
                ),
              ],
            );
          },
          child: SvgPicture.asset(
            'assets/icons/ai_icon.svg',
            width: size,
            height: size,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _GlowRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        colors: [
          Color(0x00168BFF),
          Color(0xFF50D9FF),
          Colors.white,
          Color(0xFF168BFF),
          Color(0x00168BFF),
        ],
        stops: [0, .25, .48, .7, 1],
      ).createShader(rect);
    canvas.drawCircle(size.center(Offset.zero), size.width / 2 - 2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AssistantBadge extends StatelessWidget {
  const _AssistantBadge();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 8,
              offset: Offset(4, 8),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              size: 20,
              color: Color(0xFF0B83D9),
            ),
            SizedBox(width: 8),
            Text(
              'AI Prescription Assistant',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                height: 16 / 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0B83D9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroText extends StatelessWidget {
  const _HeroText();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [Color(0xFF011556), Color(0xFF0B77CA)],
          ).createShader(bounds),
          child: const Text(
            'How can I help you today?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              height: 28 / 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Upload a photo or PDF of your prescription and\nI'll find the matching medicines from PHARMA",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            height: 24 / 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF666E80),
          ),
        ),
      ],
    );
  }
}

class _DisclaimerCard extends StatelessWidget {
  const _DisclaimerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0x14F59E0B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x66F59E0B)),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: 24, color: Color(0xFFF26C0C)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'It helps find products—not medical advice. Confirm medicines and dosages with a pharmacist. Prescription-only items are verified before dispatch.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                height: 16 / 10,
                color: Color(0xFFA94C08),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionChips extends StatelessWidget {
  const _SuggestionChips({required this.suggestions, required this.onSelected});

  final List<_SuggestionItem> suggestions;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final item = suggestions[index];
          return InkWell(
            onTap: () => onSelected(item.label),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFE1E2E6)),
              ),
              child: Row(
                children: [
                  Icon(item.icon, size: 14, color: const Color(0xFF168BFF)),
                  const SizedBox(width: 5),
                  Text(
                    item.label,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      height: 16 / 10,
                      color: Color(0xFF168BFF),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ChatHistory extends StatelessWidget {
  const _ChatHistory({required this.messages, required this.isAnswering});

  final List<_ChatMessage> messages;
  final bool isAnswering;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final message in messages) ...[
          Align(
            alignment: message.isUser
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * .78,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: message.isUser
                    ? const Color(0xFF0B83D9)
                    : message.isError
                    ? const Color(0xFFFFF2F0)
                    : const Color(0xFFF2F7FC),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 16),
                ),
                border: message.isUser
                    ? null
                    : Border.all(
                        color: message.isError
                            ? const Color(0xFFFFCCC7)
                            : const Color(0xFFD9ECFA),
                      ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.imageBytes != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        message.imageBytes!,
                        width: 230,
                        height: 170,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (message.isPdf) ...[
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.picture_as_pdf_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'PDF prescription',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (message.text.isNotEmpty)
                    Text(
                      message.text,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        height: 1.55,
                        color: message.isUser
                            ? Colors.white
                            : message.isError
                            ? const Color(0xFFB42318)
                            : const Color(0xFF25364A),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (isAnswering)
          const Align(
            alignment: Alignment.centerLeft,
            child: _TypingIndicator(),
          ),
      ],
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F7FC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFF0B83D9),
        ),
      ),
    );
  }
}

class _MessageComposer extends StatefulWidget {
  const _MessageComposer({
    required this.controller,
    required this.onCameraTap,
    required this.onAttachTap,
    required this.onSendTap,
  });

  final TextEditingController controller;
  final VoidCallback? onCameraTap;
  final VoidCallback? onAttachTap;
  final VoidCallback onSendTap;

  @override
  State<_MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<_MessageComposer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _borderController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();

  @override
  void dispose() {
    _borderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool disableAnimations = MediaQuery.disableAnimationsOf(context);

    return AnimatedBuilder(
      animation: disableAnimations
          ? kAlwaysDismissedAnimation
          : _borderController,
      builder: (BuildContext context, Widget? child) => CustomPaint(
        foregroundPainter: _RotatingComposerBorderPainter(
          progress: disableAnimations ? 0 : _borderController.value,
        ),
        child: child,
      ),
      child: Container(
        height: 56,
        padding: const EdgeInsets.only(left: 14, right: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [
            BoxShadow(color: Color(0x14000000), blurRadius: 56),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => widget.onSendTap(),
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  hintText: 'Ask about a medicine...',
                  hintStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Color(0xFF98A1B3),
                  ),
                ),
              ),
            ),
            _ComposerButton(
              icon: Icons.camera_alt_outlined,
              onTap: widget.onCameraTap,
            ),
            const SizedBox(width: 4),
            _ComposerButton(
              icon: Icons.attach_file_rounded,
              onTap: widget.onAttachTap,
            ),
            const SizedBox(width: 4),
            Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: widget.onSendTap,
                customBorder: const CircleBorder(),
                child: Ink(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0187ED), Color(0xFF021E79)],
                    ),
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    size: 20,
                    color: Colors.white,
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

class _RotatingComposerBorderPainter extends CustomPainter {
  const _RotatingComposerBorderPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect bounds = Offset.zero & size;
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..shader = SweepGradient(
        transform: GradientRotation(progress * math.pi * 2),
        colors: const <Color>[
          Color(0xFF0078F0),
          Color(0xFF54E4FF),
          Color(0xFF0078F0),
          Color(0xFF02369F),
          Color(0xFF0078F0),
        ],
        stops: const <double>[0, .18, .42, .72, 1],
      ).createShader(bounds);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        bounds.deflate(1),
        Radius.circular(size.height / 2),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RotatingComposerBorderPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _ComposerButton extends StatelessWidget {
  const _ComposerButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: CircleBorder(side: BorderSide(color: const Color(0xFFE1E2E6))),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 18, color: const Color(0xFF131415)),
        ),
      ),
    );
  }
}

class _SuggestionItem {
  const _SuggestionItem(this.icon, this.label);

  final IconData icon;
  final String label;
}

class _ChatMessage {
  const _ChatMessage(
    this.text, {
    this.isUser = false,
    this.isError = false,
    this.imageBytes,
    this.isPdf = false,
  });

  final String text;
  final bool isUser;
  final bool isError;
  final Uint8List? imageBytes;
  final bool isPdf;
}

abstract final class _MedicalKnowledgeBase {
  static Future<String> answer(String question) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    final query = question.toLowerCase();

    if (_hasAny(query, const [
      'chest pain',
      'difficulty breathing',
      'can’t breathe',
      "can't breathe",
      'unconscious',
      'severe bleeding',
      'stroke',
      'suicide',
      'overdose',
    ])) {
      return 'This may be an emergency. Please contact your local emergency service or go to the nearest emergency department now. Do not wait for an online answer.';
    }

    if (_hasAny(query, const ['paracetamol', 'acetaminophen', 'napa'])) {
      return 'Paracetamol (acetaminophen) is used for fever and mild-to-moderate pain. Avoid taking it with other products that also contain paracetamol, and do not exceed the label dose. People with liver disease, heavy alcohol use, pregnancy, or children needing a dose should check with a doctor or pharmacist.';
    }
    if (_hasAny(query, const ['ibuprofen', 'nurofen', 'advil'])) {
      return 'Ibuprofen is an NSAID used for pain, fever, and inflammation. It can irritate the stomach and may not be suitable with ulcers, kidney disease, blood thinners, some heart conditions, or during pregnancy. Take only as directed and ask a pharmacist if you use other medicines.';
    }
    if (_hasAny(query, const ['antibiotic', 'amoxicillin', 'azithromycin'])) {
      return 'Antibiotics treat certain bacterial infections—not colds or flu. Use them only when prescribed, follow the exact course, and do not share leftovers. Seek urgent help for breathing difficulty, facial swelling, or a severe rash after a dose.';
    }
    if (_hasAny(query, const ['diabetes', 'blood sugar', 'glucose'])) {
      return 'Diabetes causes blood glucose to stay too high. Common signs include unusual thirst, frequent urination, fatigue, blurred vision, and slow-healing wounds, though some people have no symptoms. Diagnosis needs a blood test. Healthy meals, activity, monitoring, and prescribed medicine help control it.';
    }
    if (_hasAny(query, const [
      'hypertension',
      'high blood pressure',
      'blood pressure',
    ])) {
      return 'High blood pressure often has no symptoms, so a proper measurement is important. Repeated readings of 180/120 mmHg or higher—especially with chest pain, breathlessness, weakness, confusion, or vision changes—need urgent medical care. Do not stop prescribed pressure medicine suddenly.';
    }
    if (_hasAny(query, const ['fever', 'temperature'])) {
      return 'Fever is commonly caused by infection. Rest, fluids, and a correctly dosed fever medicine may help. Seek medical advice for a fever lasting more than a few days, dehydration, a stiff neck, confusion, breathing trouble, a new rash, or any fever in a very young infant.';
    }
    if (_hasAny(query, const ['cold', 'cough', 'flu'])) {
      return 'Most colds and many coughs are viral and improve with rest, fluids, and symptom care. Antibiotics usually do not help. Get medical advice for breathing difficulty, chest pain, coughing blood, dehydration, symptoms that worsen, or a cough that persists.';
    }
    if (_hasAny(query, const ['gastric', 'acidity', 'heartburn', 'reflux'])) {
      return 'Heartburn or acid reflux can improve with smaller meals, avoiding late-night food, and limiting personal triggers. Frequent symptoms, trouble swallowing, vomiting blood, black stool, weight loss, or chest pressure need medical assessment.';
    }

    return 'I can provide general information about common diseases and medicines. Please include the medicine or condition name and what you want to know—for example: “What is paracetamol used for?” or “What are common diabetes symptoms?” I cannot diagnose you or choose a prescription; a doctor or pharmacist should confirm personal treatment.';
  }

  static bool _hasAny(String text, List<String> terms) {
    return terms.any(text.contains);
  }
}
