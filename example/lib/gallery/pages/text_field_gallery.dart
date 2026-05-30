import 'package:flutter/material.dart';
import 'package:d3_ui/d3_ui.dart';

import '../shared/gallery_section.dart';

class TextFieldGallery extends StatefulWidget {
  const TextFieldGallery({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });

  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  @override
  State<TextFieldGallery> createState() => _TextFieldGalleryState();
}

class _TextFieldGalleryState extends State<TextFieldGallery> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _passwordController = TextEditingController();
  final _amountController =
      D3NumericController(initialValue: 1250.00, decimalPlaces: 2);
  final _websiteController = TextEditingController(text: 'danlee.dev');

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _passwordController.dispose();
    _amountController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.d3Colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'D3TextField',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: colors.onSurfaceVariant,
            ),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            children: [
              GallerySection(
                title: 'States',
                child: Column(
                  children: [
                    D3TextField(
                      label: 'Email address',
                      hintText: 'you@example.com',
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      helperText: 'We\'ll never share your email',
                      validator: (v) => (v != null && v.contains('@'))
                          ? null
                          : 'Enter a valid email address',
                      controller: _emailController,
                    ),
                    const SizedBox(height: 16),
                    D3TextField(
                      label: 'Username',
                      hintText: 'danleedelacruz',
                      autocorrect: false,
                      successText: 'Username is available',
                      controller: _usernameController,
                    ),
                    const SizedBox(height: 16),
                    D3TextField(
                      label: 'Account ID',
                      isReadOnly: true,
                      controller: TextEditingController(text: 'USR-00482910'),
                    ),
                    const SizedBox(height: 16),
                    D3TextField(
                      label: 'Disabled field',
                      hintText: 'Cannot edit this',
                      isEnabled: false,
                      controller: TextEditingController(),
                    ),
                  ],
                ),
              ),
              GallerySection(
                title: 'Tooltip (tap the ⓘ icon)',
                child: D3TextField(
                  label: 'Referral code',
                  hintText: 'e.g. DAN-2024',
                  helperText: 'Optional — skip if you don\'t have one',
                  tooltip:
                      'Ask a friend who already uses the app. Each code is 8 characters, case-insensitive, and expires 30 days after issue.',
                  controller: TextEditingController(),
                ),
              ),
              GallerySection(
                title: 'Prefix & Suffix slots',
                child: Column(
                  children: [
                    D3TextField(
                      label: 'Search',
                      hintText: 'flutter design',
                      prefixIcon: Icons.search_rounded,
                      suffixWidget: GestureDetector(
                        onTap: () {},
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      controller: TextEditingController(text: 'flutter design'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: D3TextField(
                            label: 'Amount',
                            prefixText: '\$',
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            controller: _amountController,
                            inputFormatters: [_amountController.formatter],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: D3TextField(
                            label: 'Website',
                            prefixText: 'https://',
                            suffixIcon: Icons.check_circle_outline_rounded,
                            controller: _websiteController,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GallerySection(
                title: 'Password',
                child: D3TextField(
                  label: 'Password',
                  isRequired: true,
                  obscureText: true,
                  helperText: 'Min 8 characters, one uppercase, one number',
                  controller: _passwordController,
                ),
              ),
              GallerySection(
                title: 'Character counter',
                child: D3TextField(
                  label: 'Bio',
                  hintText: 'Tell us about yourself…',
                  maxLines: 4,
                  minLines: 3,
                  maxLength: 100,
                  controller: _bioController,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
