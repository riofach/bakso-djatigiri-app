// Halaman Kelola User - Menampilkan daftar user yang ada
// Hanya dapat diakses oleh owner
// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../core/theme/color_pallete.dart';
import '../../../core/animation/page_transitions.dart';
import '../bloc/profile_bloc.dart';

class ManageUsersPage extends StatelessWidget {
  const ManageUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          GetIt.instance<ProfileBloc>()..add(LoadAllUsersExceptCurrentEvent()),
      child: const _ManageUsersView(),
    );
  }
}

class _ManageUsersView extends StatefulWidget {
  const _ManageUsersView();

  @override
  State<_ManageUsersView> createState() => _ManageUsersViewState();
}

class _ManageUsersViewState extends State<_ManageUsersView> {
  // URL default untuk avatar profile dari ShadCDN
  final String _defaultAvatarUrl =
      'https://github.com/shadcn-ui/ui/blob/main/apps/www/public/avatars/01.png?raw=true';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Text(
          'Kelola User',
          style: TextStyle(
            color: dark900,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: dark900),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Tombol Add User di pojok kanan atas
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed('/register').then((_) {
                  // Refresh data setelah kembali dari halaman register
                  context
                      .read<ProfileBloc>()
                      .add(LoadAllUsersExceptCurrentEvent());
                });
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: white900,
                  borderRadius: BorderRadius.all(Radius.circular(100)),
                ),
                child: Center(
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: white900,
                    ),
                    child: Stack(
                      children: [
                        // Horizontal line
                        Positioned(
                          left: 6.19,
                          top: 9.24,
                          child: Container(
                            width: 7.61,
                            height: 1.5,
                            color: dark900,
                          ),
                        ),
                        // Vertical line
                        Positioned(
                          left: 9.25,
                          top: 6.19,
                          child: Container(
                            width: 1.5,
                            height: 7.61,
                            color: dark900,
                          ),
                        ),
                        // Border
                        Positioned(
                          left: 0.92,
                          top: 0.92,
                          child: Container(
                            width: 18.17,
                            height: 18.17,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: dark900,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            // Tampilkan error dengan snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: errorColor,
              ),
            );
          } else if (state is StatusUpdateSuccess) {
            // Tampilkan snackbar sukses saat status berhasil diubah
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Status user berhasil diperbarui'),
                backgroundColor: successColor,
              ),
            );
            // Refresh data setelah update
            context.read<ProfileBloc>().add(LoadAllUsersExceptCurrentEvent());
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primary950),
              ),
            );
          }

          if (state is AllUsersLoaded) {
            final users = state.users;

            if (users.isEmpty) {
              return const Center(
                child: Text('Tidak ada user lain yang ditemukan'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return _buildUserCard(user);
              },
            );
          }

          return const Center(
            child: Text('Tidak dapat memuat data user'),
          );
        },
      ),
    );
  }

  Widget _buildUserCard(dynamic user) {
    // Current status untuk switch
    bool isActive = user.isActive;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: white900,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.network(
                    _defaultAvatarUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        color: gray600,
                        child: const Icon(
                          Icons.person,
                          color: dark900,
                          size: 30,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),

                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: dark900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          color: gray950,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Role dan Status
                      Row(
                        children: [
                          // Role Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: user.isOwner ? primary100 : gray300,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              user.role.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                                color: user.isOwner ? primary950 : dark900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? successColor.withOpacity(0.2)
                                  : errorColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isActive ? 'ACTIVE' : 'INACTIVE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                                color: isActive ? successColor : errorColor,
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
            // Status switch row
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Status Akun:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                      color: dark900,
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        'Inactive',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          color: gray950,
                        ),
                      ),
                      Switch(
                        value: isActive,
                        activeColor: successColor,
                        inactiveThumbColor: errorColor,
                        onChanged: (value) {
                          // Panggil event untuk mengubah status user
                          context.read<ProfileBloc>().add(
                                UpdateUserStatusEvent(
                                  userId: user.uid,
                                  isActive: value,
                                ),
                              );
                        },
                      ),
                      const Text(
                        'Active',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          color: gray950,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
