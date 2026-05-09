import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'explore_screen.dart';
import 'favorites_screen.dart';
import 'about_screen.dart';
import 'login_screen.dart';
import 'explore_map_screen.dart';
import 'add_place_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  final supabase = Supabase.instance.client;

  String userName = "Visitor";

  late AnimationController fadeController;

  @override
  void initState() {
    super.initState();

    getUserName();

    fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  Future<void> getUserName() async {
    final user = supabase.auth.currentUser;

    if (user != null) {
      setState(() {
        userName = user.email ?? "Visitor";
      });
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  @override
  void dispose() {
    fadeController.dispose();
    super.dispose();
  }

  Widget quickCard(
    String title,
    IconData icon,
    Widget screen,
    int index,
  ) {
    return FadeTransition(
      opacity: Tween<double>(
        begin: 0,
        end: 1,
      ).animate(
        CurvedAnimation(
          parent: fadeController,
          curve: Interval(0.1 * index, 1),
        ),
      ),

      child: InkWell(
        borderRadius: BorderRadius.circular(20),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => screen,
            ),
          );
        },

        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Colors.teal,
                Colors.tealAccent,
              ],
            ),

            borderRadius: BorderRadius.circular(20),

            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
              ),
            ],
          ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Icon(
                icon,
                size: 45,
                color: Colors.white,
              ),

              const SizedBox(height: 10),

              Text(
                title,
                textAlign: TextAlign.center,

                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cards = [
      {
        "title": "Explore Heritage",
        "icon": Icons.account_balance,
        "screen": ExploreScreen(),
      },

      {
        "title": "Map Search",
        "icon": Icons.map,
        "screen": ExploreMapScreen(),
      },

      {
        "title": "Favorites",
        "icon": Icons.favorite,
        "screen": FavoritesScreen(),
      },

      {
        "title": "Add Place",
        "icon": Icons.add_location,
        "screen": AddPlaceScreen(),
      },

      {
        "title": "About",
        "icon": Icons.info,
        "screen": AboutScreen(),
      },
    ];

    final crossAxisCount =
        MediaQuery.of(context).size.width < 600 ? 2 : 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Oman Legacy"),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),

      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.teal,
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,

                children: [
                  const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 45,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    userName,

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () => Navigator.pop(context),
            ),

            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text("Favorites"),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FavoritesScreen(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.add_location),
              title: const Text("Add Place"),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddPlaceScreen(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.info),
              title: const Text("About"),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AboutScreen(),
                  ),
                );
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.red,
              ),

              title: const Text("Logout"),

              onTap: logout,
            ),
          ],
        ),
      ),

      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              height: 220,

              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/banner.Png"),
                  fit: BoxFit.cover,
                ),
              ),

              child: Container(
                color: Colors.black54,

                child: const Center(
                  child: Text(
                    "Discover Oman Heritage",

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),

            sliver: SliverGrid(
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),

              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = cards[index];

                  return quickCard(
                    item["title"] as String,
                    item["icon"] as IconData,
                    item["screen"] as Widget,
                    index,
                  );
                },

                childCount: cards.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}    