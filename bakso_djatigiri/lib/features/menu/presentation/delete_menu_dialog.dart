// Dialog konfirmasi untuk menghapus menu
// File ini berisi widget dialog untuk konfirmasi delete menu
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mie_bakso_djatigiri/core/animation/page_transitions.dart';
import 'package:mie_bakso_djatigiri/features/menu/presentation/page_menu.dart';
import '../../../core/theme/color_pallete.dart';
import '../bloc/delete_menu_bloc.dart';

class DeleteMenuDialog extends StatelessWidget {
  final String id;
  final String name;

  const DeleteMenuDialog({
    super.key,
    required this.id,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<DeleteMenuBloc>(),
      child: _DeleteMenuDialogContent(
        menuId: id,
        menuName: name,
      ),
    );
  }
}

class _DeleteMenuDialogContent extends StatelessWidget {
  final String menuId;
  final String menuName;

  const _DeleteMenuDialogContent({
    required this.menuId,
    required this.menuName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeleteMenuBloc, DeleteMenuState>(
      listener: (context, state) {
        if (state is DeleteMenuSuccess) {
          Navigator.of(context).pop(); // Tutup dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Menu berhasil dihapus!')),
          );
          Navigator.of(context).pushAndRemoveUntil(
            FadeInPageRoute(page: const PageMenu()),
            (route) => false,
          );
        } else if (state is DeleteMenuError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(color: dark900, fontFamily: 'Poppins'),
            children: [
              const TextSpan(text: 'Apakah Anda yakin ingin menghapus menu '),
              TextSpan(
                text: menuName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: '?'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          BlocBuilder<DeleteMenuBloc, DeleteMenuState>(
            builder: (context, state) {
              return ElevatedButton(
                onPressed: state is DeleteMenuLoading
                    ? null
                    : () {
                        context.read<DeleteMenuBloc>().add(
                              DeleteMenuItemEvent(
                                id: menuId,
                              ),
                            );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: errorColor,
                  foregroundColor: white900,
                ),
                child: state is DeleteMenuLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: white900,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Hapus'),
              );
            },
          ),
        ],
      ),
    );
  }
}
