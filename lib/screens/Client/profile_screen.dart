import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sportscbr/blocs/Client/profile_bloc.dart';
import 'package:sportscbr/screens/Client/home_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileBloc = Provider.of<ProfileBloc>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Meu perfil"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<bool>(
          stream: profileBloc.outLoading,
          initialData: false,
          builder: (context, snapshot) {
            bool isLoading = snapshot.data ?? false;

            return isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        StreamBuilder<String>(
                          stream: profileBloc.outName,
                          builder: (context, snapshot) {
                            return TextFormField(
                              initialValue: snapshot.data,
                              onChanged: profileBloc.changeName,
                              decoration: const InputDecoration(
                                labelText: 'Nome',
                                labelStyle: TextStyle(color: Colors.white),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.name,
                              textInputAction: TextInputAction.next,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        StreamBuilder<String>(
                          stream: profileBloc.outEmail,
                          builder: (context, snapshot) {
                            return TextFormField(
                              initialValue: snapshot.data,
                              onChanged: profileBloc.changeEmail,
                              decoration: const InputDecoration(
                                labelText: 'E-mail',
                                labelStyle: TextStyle(color: Colors.white),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        StreamBuilder<String>(
                          stream: profileBloc.outAddress,
                          builder: (context, snapshot) {
                            return TextFormField(
                              initialValue: snapshot.data,
                              onChanged: profileBloc.changeAddress,
                              decoration: const InputDecoration(
                                labelText: 'Endereço',
                                labelStyle: TextStyle(color: Colors.white),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.streetAddress,
                              textInputAction: TextInputAction.done,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              await profileBloc.saveProfile();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Perfil atualizado com sucesso')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erro ao atualizar perfil: $e')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                          child: const Text('Salvar', style: TextStyle(color: Colors.black)),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () async {
                            bool confirmDelete = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Excluir Conta"),
                                content: const Text("Tem certeza de que deseja excluir sua conta? Esta ação não pode ser desfeita."),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text("Cancelar"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text("Excluir"),
                                  ),
                                ],
                              ),
                            );
                            if (confirmDelete) {
                              try {
                                await profileBloc.deleteAccount();
                                Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomeScreen()));
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao excluir conta: $e')));
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text('Excluir Conta', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
          },
        ),
      ),
    );
  }
}
