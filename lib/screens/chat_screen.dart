import '../models/user_model.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // For date formatting
import 'package:flutter/widgets.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.user});
  final User user;

  @override
  // ignore: library_private_types_in_public_api
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<dynamic> _messages = [];
  final Map<String, bool> _expandedComments = {};
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    final response = await http.get(
      Uri.parse(
        'http://divinelifeministriesinternational.org/messages/fetch_message.php',
      ),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _messages = data['messages'];
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      final response = await http.post(
        Uri.parse(
          'http://divinelifeministriesinternational.org/messages/send_message.php',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'sender_username': widget.user.username,
          'message': _messageController.text,
        }),
      );

      if (response.statusCode == 200) {
        _messageController.clear();
        await _fetchMessages(); // Refresh the messages
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    final response = await http.post(
      Uri.parse(
        'http://divinelifeministriesinternational.org/messages/delete_message.php',
      ),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'message_id': messageId}),
    );

    if (response.statusCode == 200) {
      _fetchMessages(); // Refresh the messages
    }
  }

  Future<void> _addComment(String messageId, String comment) async {
    final response = await http.post(
      Uri.parse(
        'http://divinelifeministriesinternational.org/messages/add_comment.php',
      ),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'message_id': messageId,
        'comment': comment,
        'commenter_username': widget.user.username,
      }),
    );

    if (response.statusCode == 200) {
      _fetchMessages(); // Refresh the messages
    }
  }

  String _convertToLocalTime(String utcTimestamp) {
    try {
      final utcDate = DateTime.parse(utcTimestamp).toUtc();
      final localDate = utcDate.toLocal();
      // Only show time in 24-hour format (e.g., 15:30)
      return DateFormat('HH:mm').format(localDate);
    } catch (e) {
      debugPrint('Error converting time: $e');
      return utcTimestamp; // Return original timestamp if conversion fails
    }
  }

  Map<String, List<dynamic>> _groupMessagesByDate(List<dynamic> messages) {
    Map<String, List<dynamic>> groupedMessages = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));

    for (var message in messages) {
      final timestamp = DateTime.parse(message['timestamp']);
      final messageDate = DateTime(
        timestamp.year,
        timestamp.month,
        timestamp.day,
      );

      String dateLabel;
      if (messageDate.isAtSameMomentAs(today)) {
        dateLabel = 'Today';
      } else if (messageDate.isAtSameMomentAs(yesterday)) {
        dateLabel = 'Yesterday';
      } else {
        dateLabel =
            '${timestamp.day} ${_getMonthName(timestamp.month)} ${timestamp.year}';
      }

      if (!groupedMessages.containsKey(dateLabel)) {
        groupedMessages[dateLabel] = [];
      }
      groupedMessages[dateLabel]!.add(message);
    }
    return groupedMessages;
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }

  void _showCommentDialog(String messageId) {
    TextEditingController commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add a Comment'),
          content: TextField(
            controller: commentController,
            decoration: InputDecoration(hintText: 'Type a comment...'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (commentController.text.isNotEmpty) {
                  _addComment(messageId, commentController.text);
                  Navigator.pop(context);
                }
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(String messageId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Message'),
          content: Text('Are you sure you want to delete this message?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteMessage(messageId); // Delete the message
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupedMessages = _groupMessagesByDate(_messages);

    return Scaffold(
      appBar: AppBar(
        title: Text('Divine Life Church Chat'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16.0),
              itemCount: groupedMessages.length,
              itemBuilder: (context, index) {
                String date = groupedMessages.keys.elementAt(index);
                List<dynamic> messagesForDate = groupedMessages[date]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Center(
                        child: Text(
                          date,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                    ...messagesForDate.map((message) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 8.0),
                        padding: EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Message sender and timestamp
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  message['sender_username'] ?? 'Unknown',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                                Text(
                                  _convertToLocalTime(message['timestamp']),
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12.0,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.0),
                            // Message content
                            Text(
                              message['message'],
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                            // Comments section
                            if (message['comments'] != null &&
                                message['comments'].isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 8.0),
                                  // Show the latest comment
                                  Text(
                                    '${message['comments'].last['commenter_username']}: ${message['comments'].last['comment']}',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                  // Show "More" button if there are more than 1 comment
                                  if (message['comments'].length > 1)
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          // Toggle expanded state for this message
                                          _expandedComments[message['id']] =
                                              !(_expandedComments[message['id']] ??
                                                  false);
                                        });
                                      },
                                      child: Text(
                                        _expandedComments[message['id']] ??
                                                false
                                            ? 'Hide'
                                            : 'More....',
                                        style: TextStyle(
                                          color: Colors.blue.shade800,
                                          fontSize: 12.0,
                                        ),
                                      ),
                                    ),
                                  // Show all comments if expanded
                                  if (_expandedComments[message['id']] ?? false)
                                    ...message['comments'].map((comment) {
                                      return Padding(
                                        padding: EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          '${comment['commenter_username']}: ${comment['comment']}',
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 12.0,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                ],
                              ),
                            // Comment and delete buttons
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.comment, size: 16.0),
                                  onPressed:
                                      () => _showCommentDialog(message['id']),
                                ),
                                if (message['sender_username'] ==
                                    widget.user.username)
                                  IconButton(
                                    icon: Icon(Icons.delete, size: 16.0),
                                    onPressed:
                                        () => _showDeleteConfirmationDialog(
                                          message['id'],
                                        ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      hintMaxLines: null,
                    ),
                  ),
                ),

                SizedBox(width: 8.0),

                IconButton(
                  icon: Icon(Icons.send),
                  color: Colors.blue.shade800,
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
