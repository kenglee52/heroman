import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroman/feature/domain/entities/mechanic.dart';
import 'package:heroman/feature/presentation/bloc/job_bloc.dart';
import 'package:heroman/feature/presentation/bloc/mechanic_bloc.dart';
import 'package:heroman/utils/address.dart';
import 'package:heroman/utils/cloudinary_upload.dart';
import 'package:image_picker/image_picker.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  static const primary = Color.fromARGB(255, 1, 90, 131);
  static const dark = Color.fromARGB(255, 8, 34, 80);

  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  final _name = TextEditingController();
  final _lastname = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _experience = TextEditingController();
  final _specialty = TextEditingController();
  final _village = TextEditingController();
  final _documentId = TextEditingController();
  final _serviceArea = TextEditingController();

  static const _genders = ['ຊາຍ', 'ຍິງ'];
  static const _documentTypes = ['ບັດປະຈຳຕົວ', 'ໜັງສືຜ່ານແດນ', 'ສຳມະໂນຄົວ'];

  String? _gender;
  DateTime? _birth;
  String? _province;
  String? _district;
  String? _job;
  String? _documentType;
  DateTime? _issue;
  DateTime? _expiry;

  XFile? _profile;
  XFile? _certificate;
  final List<XFile> _achievements = [];
  final List<XFile> _documents = [];

  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  @override
  void dispose() {
    for (final c in [
      _name,
      _lastname,
      _phone,
      _email,
      _password,
      _confirm,
      _experience,
      _specialty,
      _village,
      _documentId,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  List<String> get _districts {
    if (_province == null) return [];
    final p = Address.addresses.firstWhere((e) => e['province'] == _province);
    return (p['district'] as List).map((d) => d['name'] as String).toList();
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _snack(String msg, {bool error = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: error ? Colors.red : Colors.green,
        content: Text(msg),
      ),
    );
  }

  Future<void> _pickBirth() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _birth ?? DateTime(now.year - 25),
      firstDate: DateTime(1940),
      lastDate: now,
    );
    if (d != null) setState(() => _birth = d);
  }

  /// ເລືອກວັນທີອອກເອກະສານ (ບໍ່ເກີນມື້ນີ້)
  Future<void> _pickIssue() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _issue ?? now,
      firstDate: DateTime(1990),
      lastDate: now,
      helpText: 'ວັນທີອອກເອກະສານ',
    );
    if (d == null) return;
    setState(() {
      _issue = d;
      // ຖ້າວັນໝົດອາຍຸບໍ່ຢູ່ຫຼັງວັນອອກ ໃຫ້ເລືອກໃໝ່
      if (_expiry != null && !_expiry!.isAfter(d)) _expiry = null;
    });
  }

  /// ເລືອກວັນທີໝົດອາຍຸ (ຕ້ອງຢູ່ຫຼັງວັນທີອອກ)
  Future<void> _pickExpiry() async {
    final now = DateTime.now();
    final first = (_issue ?? now).add(const Duration(days: 1));
    final d = await showDatePicker(
      context: context,
      initialDate: _expiry ?? first,
      firstDate: first,
      lastDate: DateTime(now.year + 50),
      helpText: 'ວັນທີເອກະສານໝົດອາຍຸ',
    );
    if (d != null) setState(() => _expiry = d);
  }

  bool _picking = false;

  Future<void> _guardPick(Future<void> Function() action) async {
    if (_picking) return;
    _picking = true;
    try {
      await action();
    } on PlatformException catch (e) {
      if (e.code != 'already_active') _snack('ເລືອກຮູບບໍ່ໄດ້: ${e.message}');
    } catch (e) {
      _snack('ເລືອກຮູບບໍ່ໄດ້: $e');
    } finally {
      _picking = false;
    }
  }

  Future<void> _pickSingle(bool isProfile) => _guardPick(() async {
    final f = await _picker.pickImage(source: ImageSource.gallery);
    if (f == null || !mounted) return;
    setState(() => isProfile ? _profile = f : _certificate = f);
  });

  Future<void> _pickMulti(List<XFile> target) => _guardPick(() async {
    final files = await _picker.pickMultiImage();
    if (files.isEmpty || !mounted) return;
    setState(() => target.addAll(files));
  });

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_profile == null) return _snack('ກະລຸນາເລືອກຮູບໂປຣໄຟລ໌');
    if (_birth == null) return _snack('ກະລຸນາເລືອກວັນເກີດ');
    if (_issue == null) return _snack('ກະລຸນາເລືອກວັນທີອອກເອກະສານ');
    if (_expiry == null) return _snack('ກະລຸນາເລືອກວັນທີເອກະສານໝົດອາຍຸ');
    if (!_expiry!.isAfter(_issue!)) {
      return _snack('ວັນໝົດອາຍຸຕ້ອງຢູ່ຫຼັງວັນທີອອກເອກະສານ');
    }
    if (!_expiry!.isAfter(DateTime.now())) {
      return _snack('ເອກະສານນີ້ໝົດອາຍຸແລ້ວ');
    }
    if (_documents.isEmpty) return _snack('ກະລຸນາອັບໂຫລດເອກະສານ');

    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        CloudinaryUpload.uploadImage(_profile!),
        _certificate != null
            ? CloudinaryUpload.uploadImage(_certificate!)
            : Future.value(''),
        CloudinaryUpload.uploadImages(_achievements),
        CloudinaryUpload.uploadImages(_documents),
      ]);

      final certificateUrl = results[1] as String;

      final mechanic = Mechanic(
        name: _name.text.trim(),
        lastname: _lastname.text.trim(),
        gender: _gender!,
        birth: _fmt(_birth!),
        phone: _phone.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
        experienceYears: int.tryParse(_experience.text.trim()) ?? 0,
        specialties: _specialty.text.trim(),
        isActive: true,
        profile: results[0] as String,
        province: _province!,
        district: _district!,
        village: _village.text.trim(),
        certificate: certificateUrl.isEmpty ? null : certificateUrl,
        job: _job!,
        chievements: results[2] as List<String>,
        serviceArea: _serviceArea.text,
        documentType: _documentType!,
        documentId: _documentId.text.trim(),
        issue: _fmt(_issue!),
        expiry: _fmt(_expiry!),
        documentImage: results[3] as List<String>,
      );

      if (!mounted) return;
      context.read<MechanicBloc>().add(CreateMechanicEvent(mechanic: mechanic));
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        _snack(e.toString());
      }
    }
  }

  InputDecoration _dec({
    required String label,
    IconData? icon,
    Widget? suffix,
  }) {
    OutlineInputBorder b(Color c, double w) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: c, width: w),
    );
    return InputDecoration(
      hintText: label,
      prefixIcon: icon == null ? null : Icon(icon, color: primary),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF3F6F9),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      border: b(Colors.grey, 0.2),
      enabledBorder: b(Colors.grey, 0.2),
      focusedBorder: b(primary, 1.5),
      errorBorder: b(Colors.red, 0.8),
      focusedErrorBorder: b(Colors.red, 1.5),
    );
  }

  Widget _section(IconData icon, String title) => Padding(
    padding: const EdgeInsets.only(top: 28, bottom: 14),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: primary, size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: dark,
          ),
        ),
      ],
    ),
  );

  Widget _label(String t, {bool optional = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      optional ? '$t (ບໍ່ບັງຄັບ)' : t,
      style: TextStyle(color: Colors.grey.shade700, fontSize: 13.5),
    ),
  );

  Widget _text(
    TextEditingController c,
    String label,
    IconData icon, {
    TextInputType? type,
    String? Function(String?)? validator,
    bool required = true,
    String? requiredMsg,
  }) {
    return TextFormField(
      controller: c,
      keyboardType: type,
      decoration: _dec(label: label, icon: icon),
      validator:
          validator ??
          (required
              ? (v) => (v == null || v.trim().isEmpty)
                    ? (requiredMsg ?? 'ກະລຸນາປ້ອນ$label')
                    : null
              : null),
    );
  }

  Widget _dateField({
    required String hint,
    required IconData icon,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F6F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey, width: 0.2),
        ),
        child: Row(
          children: [
            Icon(icon, color: primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value == null ? hint : _fmt(value),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: value == null ? Colors.grey.shade600 : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdown({
    required String hint,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? errorMsg,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: _dec(label: hint, icon: icon),
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: primary),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? (errorMsg ?? 'ກະລຸນາເລືອກ$hint') : null,
    );
  }

  Widget _singleImage({
    required XFile? file,
    required VoidCallback onPick,
    required VoidCallback onRemove,
    bool circle = false,
    required String hint,
  }) {
    final size = circle ? 110.0 : null;
    final shape = circle ? BoxShape.circle : BoxShape.rectangle;
    final radius = circle ? null : BorderRadius.circular(14);

    final content = file == null
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                circle ? Icons.person_add_alt_1 : Icons.add_photo_alternate,
                color: primary,
                size: circle ? 34 : 30,
              ),
              const SizedBox(height: 6),
              Text(hint, style: TextStyle(color: Colors.grey.shade600)),
            ],
          )
        : null;

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: onPick,
            child: Container(
              width: size ?? double.infinity,
              height: size ?? 130,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F6F9),
                shape: shape,
                borderRadius: radius,
                border: Border.all(
                  color: primary.withValues(alpha: 0.4),
                  width: 1.2,
                ),
                image: file == null
                    ? null
                    : DecorationImage(
                        image: FileImage(File(file.path)),
                        fit: BoxFit.cover,
                      ),
              ),
              child: content,
            ),
          ),
          if (file != null)
            Positioned(
              right: circle ? -2 : 6,
              top: circle ? -2 : 6,
              child: _removeBadge(onRemove),
            ),
          if (circle && file == null)
            const SizedBox.shrink()
          else if (circle)
            Positioned(
              right: 0,
              bottom: 0,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: primary,
                child: const Icon(Icons.edit, size: 16, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _removeBadge(VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.close, size: 14, color: Colors.white),
    ),
  );

  Widget _multiImage(List<XFile> files, String hint) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (int i = 0; i < files.length; i++)
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(files[i].path),
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                right: -6,
                top: -6,
                child: _removeBadge(() => setState(() => files.removeAt(i))),
              ),
            ],
          ),
        GestureDetector(
          onTap: () => _pickMulti(files),
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F6F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primary.withValues(alpha: 0.4)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_a_photo_outlined, color: primary),
                const SizedBox(height: 4),
                Text(
                  hint,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BlocListener<MechanicBloc, MechanicState>(
            listener: (context, state) {
              if (state is MechanicCreated) {
                setState(() => _loading = false);
                _snack('ສະໝັກສະມາຊິກສຳເລັດ', error: false);
                Navigator.pop(context);
              } else if (state is MechanicError) {
                setState(() => _loading = false);
                _snack(state.message);
              }
            },
            child: const SizedBox.shrink(),
          ),
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color.fromARGB(255, 1, 90, 131),
                  Color.fromARGB(255, 1, 66, 96),
                  Color.fromARGB(255, 2, 43, 112),
                  Color.fromARGB(255, 8, 34, 80),
                ],
              ),
            ),
            child: Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 20, 22),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'HERO MAN',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  letterSpacing: 3,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'ສະໝັກສະມາຊິກ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.shield_rounded,
                            size: 28,
                            color: primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _formChildren(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_loading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: primary),
                        SizedBox(height: 16),
                        Text('ກຳລັງອັບໂຫລດ ແລະ ສະໝັກ...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _formChildren() {
    return [
      _section(Icons.person_outline, 'ຂໍ້ມູນສ່ວນຕົວ'),
      _singleImage(
        file: _profile,
        circle: true,
        hint: 'ຮູບໂປຣໄຟລ໌',
        onPick: () => _pickSingle(true),
        onRemove: () => setState(() => _profile = null),
      ),
      const SizedBox(height: 18),
      _text(_name, 'ຊື່', Icons.badge_outlined),
      const SizedBox(height: 14),
      _text(_lastname, 'ນາມສະກຸນ', Icons.badge_outlined, required: false),
      const SizedBox(height: 14),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _dropdown(
              hint: 'ເພດ',
              icon: Icons.wc,
              value: _gender,
              items: _genders,
              onChanged: (v) => setState(() => _gender = v),
              errorMsg: 'ກະລຸນາເລືອກເພດ',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: _pickBirth,
              child: Container(
                height: 58,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F6F9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey, width: 0.2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cake_outlined, color: primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _birth == null ? 'ວັນເກີດ' : _fmt(_birth!),
                        style: TextStyle(
                          color: _birth == null
                              ? Colors.grey.shade600
                              : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      _section(Icons.lock_outline, 'ຂໍ້ມູນບັນຊີ'),
      _text(
        _phone,
        'ເບີໂທລະສັບ',
        Icons.call,
        type: TextInputType.phone,
        requiredMsg: 'ກະລຸນາປ້ອນເບີໂທ',
      ),
      const SizedBox(height: 14),
      _text(
        _email,
        'Email',
        Icons.email_outlined,
        type: TextInputType.emailAddress,
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'ກະລຸນາປ້ອນ Email';
          if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
            return 'Email ບໍ່ຖືກຕ້ອງ';
          }
          return null;
        },
      ),
      const SizedBox(height: 14),
      TextFormField(
        controller: _password,
        obscureText: _obscure,
        decoration: _dec(
          label: 'ລະຫັດຜ່ານ',
          icon: Icons.lock_outline,
          suffix: IconButton(
            icon: Icon(
              _obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
        validator: (v) => (v == null || v.length < 6)
            ? 'ລະຫັດຜ່ານຕ້ອງມີຢ່າງໜ້ອຍ 6 ຕົວ'
            : null,
      ),
      const SizedBox(height: 14),
      TextFormField(
        controller: _confirm,
        obscureText: _obscureConfirm,
        decoration: _dec(
          label: 'ຢືນຢັນລະຫັດຜ່ານ',
          icon: Icons.lock_reset,
          suffix: IconButton(
            icon: Icon(
              _obscureConfirm
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
          ),
        ),
        validator: (v) => v != _password.text ? 'ລະຫັດຜ່ານບໍ່ກົງກັນ' : null,
      ),
      _section(Icons.location_on_outlined, 'ທີ່ຢູ່'),
      _dropdown(
        hint: 'ແຂວງ',
        icon: Icons.map_outlined,
        value: _province,
        items: Address.addresses.map((e) => e['province'] as String).toList(),
        onChanged: (v) => setState(() {
          _province = v;
          _district = null;
        }),
      ),
      const SizedBox(height: 14),
      _dropdown(
        hint: _province == null ? 'ເລືອກແຂວງກ່ອນ' : 'ເມືອງ',
        icon: Icons.location_city,
        value: _district,
        items: _districts,
        onChanged: (v) => setState(() => _district = v),
        errorMsg: 'ກະລຸນາເລືອກເມືອງ',
      ),
      const SizedBox(height: 14),
      _text(_village, 'ບ້ານ', Icons.home_outlined),
      _section(Icons.build_circle_outlined, 'ຂໍ້ມູນວິຊາຊີບ'),
      BlocBuilder<JobBloc, JobState>(
        builder: (context, state) {
          if (state is JobLoading || state is JobInitial) {
            return Container(
              height: 58,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F6F9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }
          if (state is JobError) {
            return InkWell(
              onTap: () => context.read<JobBloc>().add(LoadJobs()),
              child: Container(
                height: 58,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.refresh, color: Colors.red),
                    SizedBox(width: 10),
                    Expanded(child: Text('ໂຫລດອາຊີບບໍ່ໄດ້ ແຕະເພື່ອລອງໃໝ່')),
                  ],
                ),
              ),
            );
          }
          final jobs = (state as JobLoaded).jobs.map((e) => e.job).toList();
          return _dropdown(
            hint: 'ອາຊີບ',
            icon: Icons.work_outline,
            value: jobs.contains(_job) ? _job : null,
            items: jobs,
            onChanged: (v) => setState(() => _job = v),
          );
        },
      ),
      const SizedBox(height: 14),
      _text(
        _experience,
        'ປະສົບການ (ປີ)',
        Icons.timeline,
        type: TextInputType.number,
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'ກະລຸນາປ້ອນປະສົບການ';
          return int.tryParse(v.trim()) == null ? 'ຕ້ອງເປັນຕົວເລກ' : null;
        },
      ),
      const SizedBox(height: 14),
      _text(
        _specialty,
        'ຄວາມຊ່ຽວຊານ',
        Icons.star_outline,
        requiredMsg: 'ກະລຸນາປ້ອນຄວາມຊ່ຽວຊານ',
      ),
      const SizedBox(height: 18),
      _label('ໃບຢັ້ງຢືນ / Certificate', optional: true),
      _singleImage(
        file: _certificate,
        hint: 'ເລືອກຮູບໃບຢັ້ງຢືນ',
        onPick: () => _pickSingle(false),
        onRemove: () => setState(() => _certificate = null),
      ),
      const SizedBox(height: 18),
      _label('ຜົນງານ / ຜົນສຳເລັດ', optional: true),
      _multiImage(_achievements, 'ເພີ່ມຮູບ'),

      const SizedBox(height: 14,),
       _text(
        _serviceArea,
        'ເຂດບໍລິການ ຕົວຢ່າງ: ບໍລິການທົ່ວນະຄອນຫຼວງ',
        Icons.design_services,
        requiredMsg: 'ກະລຸນາປ້ອນເຂດບໍລິການ',
      ),

      const SizedBox(height: 18,),

      // ── ເອກະສານ ──
      _section(Icons.verified_user_outlined, 'ຢືນຢັນຕົວຕົນ'),
      _dropdown(
        hint: 'ປະເພດເອກະສານ',
        icon: Icons.description_outlined,
        value: _documentType,
        items: _documentTypes,
        onChanged: (v) => setState(() => _documentType = v),
        errorMsg: 'ກະລຸນາເລືອກປະເພດເອກະສານ',
      ),
      const SizedBox(height: 14),
      _text(
        _documentId,
        'ເລກທີເອກະສານ',
        Icons.numbers,
        requiredMsg: 'ກະລຸນາປ້ອນເລກທີເອກະສານ',
      ),
      const SizedBox(height: 14),
      Row(
        children: [
          Expanded(
            child: _dateField(
              hint: 'ວັນທີອອກ',
              icon: Icons.event_available_outlined,
              value: _issue,
              onTap: _pickIssue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _dateField(
              hint: 'ວັນໝົດອາຍຸ',
              icon: Icons.event_busy_outlined,
              value: _expiry,
              onTap: _pickExpiry,
            ),
          ),
        ],
      ),
      const SizedBox(height: 18),
      _label('ຮູບເອກະສານ (ໜ້າ-ຫຼັງ)'),
      _multiImage(_documents, 'ເພີ່ມຮູບ'),

      // ── ປຸ່ມ ──
      const SizedBox(height: 32),
      SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: _loading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.how_to_reg, size: 22),
              SizedBox(width: 6),
              Text(
                'ສະໝັກສະມາຊິກ',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('ມີບັນຊີແລ້ວ?', style: TextStyle(color: Colors.grey.shade600)),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'ເຂົ້າສູ່ລະບົບ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    ];
  }
}
