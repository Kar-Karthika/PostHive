import 'package:flutter/material.dart';

class Chatscreen extends StatefulWidget {
  const Chatscreen({super.key});

  @override
  State<Chatscreen> createState() => _ChatscreenState();
}

class _ChatscreenState extends State<Chatscreen> {
  final List<Map<String, String>> messages = [
    {'sender': 'AI', 'message': 'Hello! How can I assist you today?'},
  ];

  final TextEditingController messageController = TextEditingController();

  void _sendMessage() {
    if (messageController.text.isNotEmpty) {
      setState(() {
        // User message
        messages.add({
          'sender': 'You',
          'message': messageController.text,
        });

        // AI response (simulating an AI message)
        messages.add({
          'sender': 'AI',
          'message':
              'You said: "${messageController.text}" - How can I help you further?',
        });

        messageController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 103, 89, 94),
        title: Text(
          'Chat with AI',
          style: TextStyle(color: const Color.fromARGB(180, 255, 255, 255)),
        ),
        iconTheme:
            IconThemeData(color: const Color.fromARGB(179, 255, 255, 255)),
      ),
      backgroundColor: Color.fromARGB(255, 164, 147, 147),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isSender = message['sender'] == 'You';

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  child: Align(
                    alignment:
                        isSender ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      decoration: BoxDecoration(
                        color: isSender
                            ? const Color.fromARGB(255, 90, 80, 84)
                            : const Color.fromARGB(255, 206, 205, 205),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        message['message'] ?? '',
                        style: TextStyle(
                          fontSize: 15,
                          color: isSender ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                  style: TextStyle(color: Colors.black),
                  cursorColor: Colors.black,
                  controller: messageController,
                  decoration: InputDecoration(
                    hintStyle: TextStyle(color: Colors.black),
                    hintText: 'Ask something...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    // Set the border color when the TextField is not focused
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: const Color.fromARGB(255, 0, 0, 0)),
                      borderRadius: BorderRadius.circular(20),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: const Color.fromARGB(255, 0, 0, 0)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                )),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    size: 30,
                    color: Colors.black,
                  ),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
