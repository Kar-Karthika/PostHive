import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

class ReelScreen extends StatefulWidget {
  const ReelScreen({super.key});

  @override
  State<ReelScreen> createState() => _ReelScreenState();
}

class _ReelScreenState extends State<ReelScreen> {
  final DatabaseReference _reelsRef =
      FirebaseDatabase.instance.ref().child('reels');

  Future<bool> _onWillPop() async {
    Navigator.pop(context); // Navigate to the previous (home) page
    return false; // Prevent default back button behavior
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 164, 147, 147),
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: StreamBuilder(
            stream: _reelsRef.orderByChild('posttime').onValue,
            builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                return const Center(child: Text('No Reels Found'));
              }

              // Parse the data into a list
              final Map<dynamic, dynamic> data =
                  snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
              final List reels = data.values.toList();

              return PageView.builder(
                scrollDirection: Axis.vertical,
                controller: PageController(initialPage: 0, viewportFraction: 1),
                itemCount: reels.length,
                itemBuilder: (context, index) {
                  final reel = reels[index];
                  return ReelsItem(reel);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class ReelsItem extends StatefulWidget {
  final Map<dynamic, dynamic> reel;

  const ReelsItem(this.reel, {super.key});

  @override
  State<ReelsItem> createState() => _ReelsItemState();
}

class _ReelsItemState extends State<ReelsItem> {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.network(widget.reel['reelsvideo'])
      ..initialize().then((_) {
        setState(() {});
        _videoController.play();
        _videoController.setLooping(true);
      });
  }

  @override
  void dispose() {
    _videoController.dispose(); // Dispose of the video controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            _videoController.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _videoController.value.aspectRatio,
                    child: VideoPlayer(_videoController),
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage:
                            NetworkImage(widget.reel['profileImage']),
                        radius: 20.r,
                      ),
                      SizedBox(width: 10),
                      Text(
                        widget.reel['username'],
                        style: TextStyle(
                          fontSize: 20.sp,
                          color: const Color.fromARGB(255, 253, 253, 253),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.reel['caption'] ?? 'No Description',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
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
