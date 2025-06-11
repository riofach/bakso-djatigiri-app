// Halaman Profile - Menampilkan data user yang login
// Mengikuti desain Figma Bakso Djatigiri
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../core/theme/color_pallete.dart';
import '../../../core/widgets/custom_navbar.dart';
import '../../../core/animation/page_transitions.dart';
import '../bloc/profile_bloc.dart';
import 'manage_users_page.dart';

class PageProfile extends StatelessWidget {
  const PageProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<ProfileBloc>()..add(LoadProfileEvent()),
      child: const _PageProfileView(),
    );
  }
}

class _PageProfileView extends StatefulWidget {
  const _PageProfileView();

  @override
  State<_PageProfileView> createState() => _PageProfileViewState();
}

class _PageProfileViewState extends State<_PageProfileView> {
  final int _selectedIndex = 4; // Profile di index ke-4

  final navBarItems = [
    CustomNavBarItem(
      icon: Icons.bar_chart,
      label: 'History',
      route: '/history',
    ),
    CustomNavBarItem(icon: Icons.menu_book, label: 'Menu', route: '/menu'),
    CustomNavBarItem(icon: Icons.description, label: 'Home', route: '/home'),
    CustomNavBarItem(icon: Icons.shopping_bag, label: 'Stock', route: '/stock'),
    CustomNavBarItem(icon: Icons.person, label: 'Profile', route: '/profile'),
  ];

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
          'Profile',
          style: TextStyle(
            color: dark900,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is SignOutSuccess) {
            // Navigasi ke login page saat berhasil sign out
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/login',
              (route) => false,
            );
          } else if (state is ProfileError) {
            // Tampilkan error dengan snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: errorColor,
              ),
            );
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

          if (state is ProfileLoaded) {
            final user = state.user;
            return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Avatar
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primary950,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: Image.network(
                            _defaultAvatarUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(primary950),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: gray600,
                                child: const Icon(
                                  Icons.person,
                                  color: dark900,
                                  size: 60,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Nama User
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: dark900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      // Role User
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: user.isOwner ? primary100 : gray300,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user.role.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            color: user.isOwner ? primary950 : dark900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Email User
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          color: gray950,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),

                      // Buttons
                      // Kelola User Button (hanya untuk owner)
                      if (user.isOwner) ...[
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              FadeInPageRoute(
                                page: const ManageUsersPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: white900,
                            foregroundColor: dark900,
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: gray600),
                            ),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people),
                              SizedBox(width: 8),
                              Text(
                                'Kelola User',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Logout Button
                      ElevatedButton(
                        onPressed: () {
                          context.read<ProfileBloc>().add(SignOutEvent());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: errorColor,
                          foregroundColor: white900,
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout),
                            SizedBox(width: 8),
                            Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
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

          return const Center(
            child: Text('Tidak dapat memuat data profil'),
          );
        },
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: _selectedIndex,
        items: navBarItems,
        onTap: (index) {
          if (index != _selectedIndex) {
            Navigator.pushReplacementNamed(
              context,
              navBarItems[index].route,
            );
          }
        },
      ),
    );
  }
}
