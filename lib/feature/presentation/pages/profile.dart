import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroman/authentication/login_service.dart';
import 'package:heroman/feature/presentation/bloc/mechanic_bloc.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? userId;
  static const primaryColor = Color(0xFF014565);

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final fetchUserId = await LoginService.getUserId();
    if (fetchUserId != null && mounted) {
      setState(() {
        userId = fetchUserId;
      });
      context.read<MechanicBloc>().add(LoadMechanicById(id: fetchUserId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: BlocBuilder<MechanicBloc, MechanicState>(
        builder: (context, state) {
          if (state is MechanicLoading || state is MechanicInitial) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: primaryColor,
              ),
            );
          }

          if (state is MechanicError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: InkWell(
                  onTap: () {
                    if (userId != null) {
                      context.read<MechanicBloc>().add(
                        LoadMechanicById(id: userId!),
                      );
                    } else {
                      loadUserData();
                    }
                  },
                  child: Container(
                    height: 58,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh, color: Colors.red),
                        SizedBox(width: 10),
                        Text(
                          'ໂຫລດຂໍ້ມູນບໍ່ໄດ້ ແຕະເພື່ອລອງໃໝ່',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          if (state is MechanicLoaded) {
            return buildContent(state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget buildContent(MechanicState state) {
    if (state is! MechanicLoaded) {
      return const SizedBox.shrink();
    }

    final mechanic = state.mechanic;
    if (mechanic == null) {
      return const Center(child: Text('ບໍ່ພົບຂໍ້ມູນຊ່າງ'));
    }

    // ດຶງຂໍ້ມູນທີ່ຢູ່ແບບປ້ອງກັນ null
    final village = mechanic.village ?? '';
    final district = mechanic.district ?? '';
    final province = mechanic.province ?? '';
    final fullAddress = 'ບ້ານ $village, ເມືອງ $district, ແຂວງ $province';

    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(top: 15),
                height: 180,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 204, 203, 203),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(30),
                    top: Radius.circular(30),
                  ),
                ),
              ),
              Positioned(
                top: 100,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage:
                        (mechanic.profile != null &&
                            mechanic.profile!.isNotEmpty)
                        ? NetworkImage(mechanic.profile!)
                        : null,
                    child:
                        (mechanic.profile == null || mechanic.profile!.isEmpty)
                        ? const Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 50)),

        // Name & Job
        SliverToBoxAdapter(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${mechanic.name ?? ''} ${mechanic.lastname ?? ''}'.trim(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  if (mechanic.isActive == true) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.verified, color: Colors.blue, size: 20),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Chip(
                avatar: const Icon(Icons.build, size: 16, color: primaryColor),
                label: Text(
                  mechanic.job ?? 'ຊ່າງທົ່ວໄປ',
                  style: const TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: primaryColor.withValues(alpha: 0.1),
                side: BorderSide.none,
              ),
            ],
          ),
        ),

        // Stats
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    buildStatItem(
                      'ປະສົບການ',
                      '${mechanic.experienceYears ?? 0} ປີ',
                    ),
                    Container(
                      height: 30,
                      width: 1,
                      color: Colors.grey.shade300,
                    ),
                    buildStatItem('ເພດ', mechanic.gender),
                    Container(
                      height: 30,
                      width: 1,
                      color: Colors.grey.shade300,
                    ),
                    buildStatItem(
                      'ສະຖານະ',
                      mechanic.isActive == true ? 'ພ້ອມຮັບງານ' : 'ປິດຮັບງານ',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Contact Info
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  buildProfileInfoTile(
                    Icons.phone,
                    'ເບີໂທລະສັບ',
                    mechanic.phone,
                  ),
                  const Divider(height: 1, indent: 50),
                  buildProfileInfoTile(Icons.email, 'ອີເມວ', mechanic.email),
                  const Divider(height: 1, indent: 50),
                  buildProfileInfoTile(
                    Icons.location_on,
                    'ທີ່ຢູ່',
                    fullAddress,
                  ),
                  const Divider(height: 1, indent: 50),
                  buildProfileInfoTile(
                    Icons.map,
                    'ພື້ນທີ່ບໍລິການ',
                    mechanic.serviceArea,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (mechanic.specialties != null && mechanic.specialties!.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ຄວາມຊ່ຽວຊານ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      mechanic.specialties!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Achievements
        if (mechanic.chievements != null && mechanic.chievements!.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ຜົນງານທີ່ຜ່ານມາ (${mechanic.chievements!.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: mechanic.chievements!.length,
                      itemBuilder: (context, index) {
                        final imageUrl = mechanic.chievements![index]
                            .toString();
                        return Container(
                          margin: const EdgeInsets.only(right: 10),
                          width: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget buildStatItem(String label, String? value) {
    return Column(
      children: [
        Text(
          (value != null && value.isNotEmpty) ? value : '-',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget buildProfileInfoTile(IconData icon, String title, String? value) {
    final displayValue = (value != null && value.trim().isNotEmpty)
        ? value
        : 'ບໍ່ມີຂໍ້ມູນ';

    return ListTile(
      leading: Icon(icon, color: primaryColor),
      title: Text(
        title,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      subtitle: Text(
        displayValue,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}
