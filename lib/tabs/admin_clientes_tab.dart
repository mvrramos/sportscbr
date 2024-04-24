import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:sportscbr/blocs/admin_users_bloc.dart';
import 'package:sportscbr/tiles/admin_user_tile.dart';

class AdminClientsTab extends StatelessWidget {
  const AdminClientsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final adminUsersBloc = BlocProvider.getBloc<AdminUsersBloc>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Pesquisar",
                hintStyle: TextStyle(color: Colors.white),
                icon: Icon(Icons.search),
                border: InputBorder.none,
              ),
              onChanged: adminUsersBloc.onChangedSearch),
        ),
        Expanded(
          child: StreamBuilder<List>(
              stream: adminUsersBloc.outUsers,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Color.fromARGB(100, 73, 5, 182)),
                    ),
                  );
                } else if (snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "Nenhum usuário encontrado",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                } else {
                  return ListView.separated(
                    itemBuilder: (context, index) {
                      return AdminUserTile(snapshot.data?[index]); // Correção aqui
                    },
                    separatorBuilder: (context, index) {
                      return const Divider();
                    },
                    itemCount: snapshot.data!.length,
                  );
                }
              }),
        ),
      ],
    );
  }
}
