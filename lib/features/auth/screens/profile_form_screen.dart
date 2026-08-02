import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../../core/theme/theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/router/app_router.dart' show invalidateProfileCache;
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../shared/widgets/app_text_field.dart'; // adjust path to wherever AppTextField actually lives

class ProfileFormScreen extends ConsumerStatefulWidget {
  const ProfileFormScreen({super.key});

  @override
  ConsumerState<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends ConsumerState<ProfileFormScreen> {
  final _nicknameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _bioController = TextEditingController();

  String? _gender;
  DateTime? _dob;
  String? _avatarUrl; // uploaded/remote URL
  File? _pickedAvatarFile; // local preview before/while uploading

  bool _isLoadingProfile = true;
  bool _isSaving = false;
  bool _isUploadingAvatar = false;
  String? _errorMessage;

  static const _genderOptions = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _fullNameController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      setState(() => _isLoadingProfile = false);
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        _nicknameController.text = response['display_name'] ?? '';
        _fullNameController.text = response['full_name'] ?? '';
        _locationController.text = response['location'] ?? '';
        _bioController.text = response['bio'] ?? '';
        _gender = response['gender'] as String?;
        _avatarUrl = response['avatar_url'] as String?;
        final dobRaw = response['date_of_birth'] as String?;
        if (dobRaw != null) _dob = DateTime.tryParse(dobRaw);
      }
    } catch (e) {
      _errorMessage = 'Failed to load profile';
    } finally {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  Future<void> _pickAndCropAvatar() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked == null) return;

    final supportsCropper = kIsWeb || Platform.isAndroid || Platform.isIOS;
    File? finalFile;

    if (supportsCropper) {
      try {
        final cropped = await ImageCropper().cropImage(
          sourcePath: picked.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop photo',
              lockAspectRatio: true,
              cropStyle: CropStyle.circle,
            ),
            IOSUiSettings(
              title: 'Crop photo',
              aspectRatioLockEnabled: true,
              cropStyle: CropStyle.circle,
            ),
            WebUiSettings(
              context: context,
              presentStyle: WebPresentStyle.dialog,
            ),
          ],
        );
        finalFile = cropped != null ? File(cropped.path) : null;
      } catch (e) {
        finalFile = File(
          picked.path,
        ); // cropper errored — fall back to uncropped
      }
    } else {
      // Windows/Linux/macOS desktop: image_cropper has no native impl, skip cropping
      finalFile = File(picked.path);
    }

    if (finalFile == null) return;

    setState(() {
      _pickedAvatarFile = finalFile;
      _isUploadingAvatar = true;
    });

    try {
      await _uploadAvatar(finalFile);
    } catch (e) {
      setState(() => _errorMessage = 'Failed to upload photo');
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  Future<void> _uploadAvatar(File file) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    // assumes a Supabase Storage bucket named 'avatars' already exists
    final storagePath = '$userId/avatar.png';
    final bytes = await file.readAsBytes();

    await Supabase.instance.client.storage
        .from('avatars')
        .uploadBinary(
          storagePath,
          bytes,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/png',
          ),
        );

    final publicUrl = Supabase.instance.client.storage
        .from('avatars')
        .getPublicUrl(storagePath);

    setState(
      () =>
          _avatarUrl = '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}',
    );
    // cache-busting query param so the new photo shows immediately, since
    // the file path/URL itself doesn't change between uploads
  }

  Future<void> _pickDob(AppColors colors) async {
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: colors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: _CustomDatePicker(
            colors: colors,
            initialDate: _dob ?? DateTime(2000, 1, 1),
          ),
        ),
      ),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _handleSave() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await Supabase.instance.client.from('profiles').upsert({
        'id': userId, // REQUIRED for upsert — this is what it matches on
        'display_name': _nicknameController.text.trim(),
        'full_name': _fullNameController.text.trim(),
        'gender': _gender,
        'date_of_birth': _dob?.toIso8601String().split('T').first,
        'location': _locationController.text.trim(),
        'bio': _bioController.text.trim(),
        if (_avatarUrl != null) 'avatar_url': _avatarUrl,
      });
      invalidateProfileCache(); // added — tell the router this user's profile is now complete
      if (mounted)
        context.go('/home'); // added — leave the form now that saving succeeded
    } catch (e) {
      setState(() => _errorMessage = 'Failed to save profile');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemes.of(ref.watch(themeProvider));

    if (_isLoadingProfile) {
      return Scaffold(
        backgroundColor: colors.background,
        body: Center(child: CircularProgressIndicator(color: colors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 900;
            final maxWidth = isDesktop ? 820.0 : constraints.maxWidth;

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: AppSpacing.lg * 2.0,
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  bottom: AppSpacing.lg,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(colors: colors),
                      const SizedBox(height: AppSpacing.xl),
                      if (isDesktop)
                        _DesktopBody(
                          colors: colors,
                          avatar: _AvatarPicker(
                            colors: colors,
                            avatarUrl: _avatarUrl,
                            pickedFile: _pickedAvatarFile,
                            isUploading: _isUploadingAvatar,
                            onTap: _pickAndCropAvatar,
                            size: 180,
                          ),
                          nicknameField: _field(
                            colors,
                            'Nickname',
                            _nicknameController,
                          ),
                          fullNameField: _field(
                            colors,
                            'Full name',
                            _fullNameController,
                          ),
                          genderField: _GenderField(
                            colors: colors,
                            value: _gender,
                            options: _genderOptions,
                            onChanged: (v) => setState(() => _gender = v),
                          ),
                          dobField: _DobField(
                            colors: colors,
                            value: _dob,
                            onTap: () => _pickDob(colors),
                          ),
                          locationField: _field(
                            colors,
                            'Location',
                            _locationController,
                          ),
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: _AvatarPicker(
                                colors: colors,
                                avatarUrl: _avatarUrl,
                                pickedFile: _pickedAvatarFile,
                                isUploading: _isUploadingAvatar,
                                onTap: _pickAndCropAvatar,
                                size: 168,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _field(colors, 'Nickname', _nicknameController),
                            const SizedBox(height: AppSpacing.md),
                            _field(colors, 'Full name', _fullNameController),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Expanded(
                                  child: _GenderField(
                                    colors: colors,
                                    value: _gender,
                                    options: _genderOptions,
                                    onChanged: (v) =>
                                        setState(() => _gender = v),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: _DobField(
                                    colors: colors,
                                    value: _dob,
                                    onTap: () => _pickDob(colors),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _field(colors, 'Location', _locationController),
                          ],
                        ),
                      const SizedBox(height: AppSpacing.md),
                      _field(colors, 'Bio', _bioController, maxLines: 4),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          _errorMessage!,
                          style: TextStyle(color: colors.error),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _handleSave,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: colors.primary,
                            foregroundColor: colors.background,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: _isSaving
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: colors.background,
                                  ),
                                )
                              : const Text(
                                  'Save',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _field(
    AppColors colors,
    String hint,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return AppTextField(hint: hint, controller: controller, maxLines: maxLines);
  }
}

/// Header: icon + "Spotlight Manager" title, no settings gear (removed per spec)
class _Header extends StatelessWidget {
  final AppColors colors;
  const _Header({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(colors.logoPath, width: 36, height: 36),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'Spotlight\nManager',
          style: AppTypography.heading2.copyWith(
            color: colors.textTitle,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

/// Desktop layout: avatar left, fields stacked right (nickname/full name/gender+dob/location)
class _DesktopBody extends StatelessWidget {
  final AppColors colors;
  final Widget avatar;
  final Widget nicknameField;
  final Widget fullNameField;
  final Widget genderField;
  final Widget dobField;
  final Widget locationField;

  const _DesktopBody({
    required this.colors,
    required this.avatar,
    required this.nicknameField,
    required this.fullNameField,
    required this.genderField,
    required this.dobField,
    required this.locationField,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        avatar,
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            children: [
              nicknameField,
              const SizedBox(height: AppSpacing.sm),
              fullNameField,
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(child: genderField),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: dobField),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              locationField,
            ],
          ),
        ),
      ],
    );
  }
}

/// Circular avatar with camera-style tap target; shows local preview while
/// uploading, falls back to remote URL, falls back to a placeholder icon.
class _AvatarPicker extends StatelessWidget {
  final AppColors colors;
  final String? avatarUrl;
  final File? pickedFile;
  final bool isUploading;
  final VoidCallback onTap;
  final double size;

  const _AvatarPicker({
    required this.colors,
    required this.avatarUrl,
    required this.pickedFile,
    required this.isUploading,
    required this.onTap,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final scale = 1.1;
    final scaledSize = size * scale;
    ImageProvider? image;
    if (pickedFile != null) {
      image = FileImage(pickedFile!);
    } else if (avatarUrl != null) {
      image = NetworkImage(avatarUrl!);
    }

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: scaledSize,
            height: scaledSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.primary,
              image: image != null
                  ? DecorationImage(image: image, fit: BoxFit.cover)
                  : null,
            ),
            child: image == null
                ? Icon(
                    Icons.person,
                    color: colors.background,
                    size: scaledSize * 0.4,
                  )
                : null,
          ),
          if (isUploading)
            Container(
              width: scaledSize,
              height: scaledSize,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black38,
              ),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          Positioned(
            bottom: 4 * scale,
            right: 4 * scale,
            child: Container(
              padding: EdgeInsets.all(6 * scale),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.background,
              ),
              child: Icon(Icons.edit, size: 16 * scale, color: colors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _GenderField extends StatelessWidget {
  final AppColors colors;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const _GenderField({
    required this.colors,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  Future<void> _openPicker(BuildContext context) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: colors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Gender',
              style: AppTypography.body.copyWith(
                color: colors.textTitle,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...options.map(
              (g) => ListTile(
                title: Text(g, style: TextStyle(color: colors.textTitle)),
                trailing: g == value
                    ? Icon(Icons.check, color: colors.primary)
                    : null,
                onTap: () => Navigator.pop(context, g),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final scale = 1.1;
    return InkWell(
      onTap: () => _openPicker(context),
      borderRadius: BorderRadius.circular(24 * scale),
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md * scale,
          vertical: AppSpacing.sm * scale,
        ),
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(24 * scale),
        ),
        child: Text(
          value ?? 'Gender',
          style: TextStyle(
            color: value == null
                ? colors.textSecondary.withOpacity(0.7)
                : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _DobField extends StatelessWidget {
  final AppColors colors;
  final DateTime? value;
  final VoidCallback onTap;

  const _DobField({
    required this.colors,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final label = value == null
        ? 'DOB'
        : '${value!.day.toString().padLeft(2, '0')}/'
              '${value!.month.toString().padLeft(2, '0')}/${value!.year}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: value == null
                ? colors.textSecondary.withOpacity(0.7)
                : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _CustomDatePicker extends StatefulWidget {
  final AppColors colors;
  final DateTime initialDate;
  const _CustomDatePicker({required this.colors, required this.initialDate});

  @override
  State<_CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<_CustomDatePicker> {
  late int _day, _month, _year;
  late FixedExtentScrollController _dayCtrl, _monthCtrl, _yearCtrl;
  late final List<int> _years;

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  int get _daysInMonth => DateTime(_year, _month + 1, 0).day;

  @override
  void initState() {
    super.initState();
    _day = widget.initialDate.day;
    _month = widget.initialDate.month;
    _year = widget.initialDate.year;
    _years = List.generate(100, (i) => DateTime.now().year - i);

    _dayCtrl = FixedExtentScrollController(initialItem: _day - 1);
    _monthCtrl = FixedExtentScrollController(initialItem: _month - 1);
    _yearCtrl = FixedExtentScrollController(
      initialItem: DateTime.now().year - _year,
    );
  }

  @override
  void dispose() {
    _dayCtrl.dispose();
    _monthCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  Widget _wheel({
    required FixedExtentScrollController controller,
    required int itemCount,
    required String Function(int) label,
    required ValueChanged<int> onChanged,
  }) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 40,
      perspective: 0.003,
      diameterRatio: 1.4,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: onChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: itemCount,
        builder: (context, i) => Center(
          child: Text(
            label(i),
            style: TextStyle(color: widget.colors.textTitle, fontSize: 16),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: widget.colors.textSecondary),
              ),
            ),
            Text(
              'Date of birth',
              style: AppTypography.body.copyWith(
                color: widget.colors.textTitle,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {
                final safeDay = _day > _daysInMonth ? _daysInMonth : _day;
                Navigator.pop(context, DateTime(_year, _month, safeDay));
              },
              child: Text(
                'Done',
                style: TextStyle(
                  color: widget.colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 220,
          child: Stack(
            children: [
              Center(
                child: Container(
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: widget.colors.primary.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: _wheel(
                      controller: _dayCtrl,
                      itemCount: _daysInMonth,
                      label: (i) => '${i + 1}',
                      onChanged: (i) => setState(() => _day = i + 1),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: _wheel(
                      controller: _monthCtrl,
                      itemCount: 12,
                      label: (i) => _months[i],
                      onChanged: (i) => setState(() => _month = i + 1),
                    ),
                  ),
                  Expanded(
                    child: _wheel(
                      controller: _yearCtrl,
                      itemCount: _years.length,
                      label: (i) => '${_years[i]}',
                      onChanged: (i) => setState(() => _year = _years[i]),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
