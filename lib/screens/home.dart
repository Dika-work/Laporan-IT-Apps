import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laporan/providers/auth_provider.dart';
import 'package:laporan/providers/user_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userDataProvider);

    return Scaffold(
        appBar: AppBar(
          title: const Text("Riverpod Flutter"),
          actions: [
            IconButton(
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                  context.go('/login');
                },
                icon: const Icon(Icons.logout))
          ],
        ),
        body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userDataProvider);
            },
            child: userData.when(
              data: (users) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      child: Card(
                        color: Theme.of(context).primaryColor,
                        child: ListTile(
                          title: Text(
                            'Type: ${user.typeUser}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            'Username: ${user.username}\nHash: ${user.usernameHash}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              error: (error, stackTrace) => Center(
                child: Text(
                  'Error: $error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
            )));
  }
}
