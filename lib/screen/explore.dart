import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_1/screen/profilescreen.dart';
import 'package:instagram_1/util/cacheimage.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final search = TextEditingController();
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  bool show = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color.fromARGB(255, 164, 147, 147),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SearchBox(),
            if (show)
              StreamBuilder(
                stream: _databaseRef.child('posts').onValue,
                builder: (context, snapshot) {
                  if (!snapshot.hasData ||
                      snapshot.data!.snapshot.value == null) {
                    return const SliverToBoxAdapter(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final data =
                      (snapshot.data!.snapshot.value as Map<dynamic, dynamic>)
                          .values
                          .toList();
                  return SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final post = data[index];
                        return GestureDetector(
                          onTap: () {
                            // Navigate to PostScreen with post data
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey,
                            ),
                            child: CachedImage(
                              post[
                                  'postImage'], // Ensure the data structure matches
                            ),
                          ),
                        );
                      },
                      childCount: data.length,
                    ),
                    gridDelegate: SliverQuiltedGridDelegate(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 2,
                      pattern: const [
                        QuiltedGridTile(1, 1),
                        QuiltedGridTile(2, 1),
                        QuiltedGridTile(1, 1),
                        QuiltedGridTile(1, 1),
                        QuiltedGridTile(1, 1),
                        QuiltedGridTile(1, 1),
                        QuiltedGridTile(1, 1),
                      ],
                    ),
                  );
                },
              ),
            if (!show)
              StreamBuilder(
                stream: _databaseRef
                    .child('users')
                    .orderByChild('username')
                    .startAt(search.text)
                    .onValue,
                builder: (context, snapshot) {
                  if (!snapshot.hasData ||
                      snapshot.data!.snapshot.value == null) {
                    return const SliverToBoxAdapter(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final data =
                      (snapshot.data!.snapshot.value as Map<dynamic, dynamic>)
                          .values
                          .toList();
                  return SliverPadding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final user = data[index];
                          return Column(
                            children: [
                              SizedBox(height: 10.h),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        ProfileScreen(uid: user['uid'] ?? ''),
                                  ));
                                },
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 23.r,
                                      backgroundImage: NetworkImage(
                                        user['profileImage'] ?? '',
                                      ),
                                    ),
                                    SizedBox(width: 15.w),
                                    Text(
                                      user['username'] ?? '',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 15),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                        childCount: data.length,
                      ),
                    ),
                  );
                },
              )
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter SearchBox() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        child: Container(
          width: double.infinity,
          height: 36.h,
          decoration: BoxDecoration(
            color: const Color.fromARGB(194, 238, 238, 238),
            borderRadius: BorderRadius.all(
              Radius.circular(10.r),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Row(
              children: [
                const Icon(
                  Icons.search,
                  color: Colors.black,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        show = value.isEmpty;
                      });
                    },
                    controller: search,
                    decoration: const InputDecoration(
                      hintText: 'Search User',
                      hintStyle: TextStyle(color: Colors.black),
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
