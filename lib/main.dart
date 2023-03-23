import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AwaitBindings().dependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'My Awesome Test',
      getPages: getPages,
      initialRoute: Routes.items,
      initialBinding: AwaitBindings(),
      defaultTransition: Transition.fadeIn,
    );
  }
}

class AwaitBindings extends Bindings {
  @override
  Future<void> dependencies() async {
    await Get.putAsync(() async => AppController(), permanent: true);
  }
}

class Routes {
  static const items = '/items';
  static const item = '/item';
  static const signup = '/sign-up';
  static const forgotPassword = '/forgot-password';
}

final getPages = [
  GetPage(name: Routes.item, page: () => ItemScreen()),
  GetPage(name: Routes.items, page: () => const ItemListScreen()),
  GetPage(
      name: Routes.forgotPassword, page: () => const ForgotPasswordScreen()),
  GetPage(name: Routes.signup, page: () => const SignUpScreen()),
];

enum AuthenticationStatus {
  none,
  authenticated,
}

class AppController extends GetxController {
  final Rx<AuthenticationStatus> _auth = AuthenticationStatus.none.obs;
  AuthenticationStatus get auth => _auth.value;

  Future<void> doLogin(
      {required String username, required String password}) async {
    // do stuff
    await Future.delayed(const Duration(seconds: 1));
    _auth.value = AuthenticationStatus.authenticated;
    update();
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(seconds: 1));
    _auth.value = AuthenticationStatus.none;
    update();
  }
}

class LoginWidget extends StatelessWidget {
  LoginWidget({super.key});
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AppController appController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: usernameController,
          decoration: const InputDecoration(
              labelText: "Username", hintText: "Type your username"),
        ),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
              labelText: "Password", hintText: "Type your password"),
        ),
        ElevatedButton(
          child: const Text("Login"),
          onPressed: () async {
            String username = usernameController.text;
            String password = passwordController.text;
            if (username.isNotEmpty && password.isNotEmpty) {
              await appController.doLogin(
                  username: username, password: password);
            } else {
              print("//FIXME: alert user: cannot send empty field");
            }
          },
        ),
      ],
    );
  }
}

class ItemListWidget extends StatelessWidget {
  const ItemListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        title: Text("Item #$index"),
        subtitle: Text("Description of the item $index in a couple words."),
        onTap: () => Get.toNamed(Routes.item, parameters: {'id': '$index'}),
      ),
      itemCount: 10,
    );
  }
}

class ItemDetailWidget extends StatelessWidget {
  final String id;
  const ItemDetailWidget({
    super.key,
    this.id = '',
  });

  @override
  Widget build(BuildContext context) {
    return id.isEmpty
        ? const Placeholder()
        : SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Detail of item $id here"),
                Text("Detail of item $id here"),
                Text("Detail of item $id here"),
                Text("Detail of item $id here"),
              ],
            ),
          );
  }
}

class ItemListScreen extends StatelessWidget {
  const ItemListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (app) => Scaffold(
        appBar: AppBar(
          title: Text("Items"),
          actions: [
            if (app.auth == AuthenticationStatus.authenticated)
              ElevatedButton(
                child: Text("Logout"),
                onPressed: () => app.logout(),
              ),
          ],
        ),
        body: app.auth != AuthenticationStatus.authenticated
            ? LoginWidget()
            : const ItemListWidget(),
      ),
    );
  }
}

class ItemScreen extends StatelessWidget {
  ItemScreen({super.key});
  final String id = Get.parameters['id'] ?? '';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => GetBuilder<AppController>(
        builder: (app) => Scaffold(
          appBar: AppBar(
            title: Text("Detail"),
            actions: [
              if (app.auth == AuthenticationStatus.authenticated)
                ElevatedButton(
                  child: Text("Logout"),
                  onPressed: () => app.logout(),
                ),
            ],
          ),
          body: app.auth != AuthenticationStatus.authenticated
              ? LoginWidget()
              : constraints.maxWidth > 720
                  ? Row(
                      children: [
                        const Expanded(
                          flex: 1,
                          child: ItemListWidget(),
                        ),
                        Expanded(
                          flex: 3,
                          child: ItemDetailWidget(id: id),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        ElevatedButton(
                          child: const Text("Back to Item List"),
                          onPressed: () => Get.offAllNamed(Routes.items),
                        ),
                        Expanded(
                          child: ItemDetailWidget(id: id),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => Get.back(),
          child: const Text("Do stuff and go back"),
        ),
      ),
    );
  }
}

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => Get.back(),
          child: const Text("Register an account and go back"),
        ),
      ),
    );
  }
}
