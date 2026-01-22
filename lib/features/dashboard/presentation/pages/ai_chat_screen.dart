import 'package:flutter/material.dart';
import 'package:fitzee_new/core/constants/app_colors.dart';
import 'package:fitzee_new/core/services/openai_service.dart';
import 'package:fitzee_new/core/services/user_profile_service.dart';
import 'package:fitzee_new/core/services/local_storage_service.dart';
import 'package:fitzee_new/core/services/daily_data_service.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    _messages.add(ChatMessage(
      text:
          'Hello! I\'m your AI fitness coach. I can help you with:\n\n• Workout plans and exercises\n• Diet and nutrition advice\n• Health and fitness questions\n• Progress tracking\n\nWhat would you like to know?',
      isUser: false,
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _messageController.clear();
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      // Get user context
      final userId = await LocalStorageService.getUserId();
      final profile = await UserProfileService.getUserProfile(userId);
      final yesterdayData = await DailyDataService.getYesterdayData();
      final averageData = await DailyDataService.getAverageData(7);

      String contextPrompt = '';
      if (profile != null) {
        contextPrompt = '''
User Profile:
- Name: ${profile.name ?? 'User'}
- Goal: ${profile.goal ?? 'Not set'}
- Age: ${profile.age ?? 'Not set'}
- Height: ${profile.height ?? 'Not set'} cm
- Weight: ${profile.weight ?? 'Not set'} kg
- Exercise Frequency: ${profile.exerciseFrequencyPerWeek ?? 0} days/week
- Sleep: ${profile.averageSleepHours ?? 0} hours average
- Stress Level: ${profile.stressLevel ?? 0}/10

Recent Activity (Yesterday):
- Steps: ${yesterdayData?['steps'] ?? 0}
- Calories: ${yesterdayData?['calories'] ?? 0}
- Sleep: ${yesterdayData?['sleepHours'] ?? 0} hours

7-Day Average:
- Steps: ${averageData['steps']}
- Calories: ${averageData['calories']}
- Sleep: ${averageData['sleepHours']} hours
''';
      }

      final systemPrompt = '''You are a professional AI fitness and health coach for FITZEE AI app. 
Provide helpful, personalized advice about workouts, diet, nutrition, and health based on the user's profile and activity data.
Be encouraging, supportive, and provide actionable advice. Keep responses concise but informative.''';

      final userPrompt = '$contextPrompt\n\nUser Question: $text';

      print('AIChatScreen: Sending message to OpenAI API');
      final response = await OpenAIService.makeChatRequest(systemPrompt, userPrompt);

      print('AIChatScreen: Successfully received response from OpenAI');
      setState(() {
        _messages.add(ChatMessage(text: response, isUser: false));
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      print('AIChatScreen: ERROR sending message: $e');
      print('AIChatScreen: Stack trace: $stackTrace');
      
      // Provide more helpful error messages based on error type
      String errorMessage = 'Sorry, I encountered an error. Please try again.';
      
      if (e is QuotaExceededException) {
        errorMessage = '⚠️ API quota exceeded. The OpenAI API key has reached its usage limit. Please check your billing and plan details, or contact support to update your API key.';
      } else if (e is RateLimitException) {
        errorMessage = '⏱️ Too many requests. Please wait a moment and try again.';
      } else if (e is AuthenticationException) {
        errorMessage = '🔐 API authentication failed. The API key may be invalid. Please contact support.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = '⏱️ Request timed out. Please check your internet connection and try again.';
      } else if (e.toString().contains('401') || e.toString().contains('unauthorized')) {
        errorMessage = '🔐 API authentication failed. Please contact support.';
      } else if (e.toString().contains('429') || e.toString().contains('rate limit')) {
        errorMessage = '⏱️ Too many requests. Please wait a moment and try again.';
      } else if (e.toString().contains('quota') || e.toString().contains('insufficient_quota')) {
        errorMessage = '⚠️ API quota exceeded. Please check your OpenAI account billing and plan details.';
      } else if (e.toString().contains('network') || e.toString().contains('connection')) {
        errorMessage = '🌐 Network error. Please check your internet connection and try again.';
      } else {
        // For debugging, show the actual error in development
        errorMessage = '❌ Error: ${e.toString().length > 150 ? e.toString().substring(0, 150) + "..." : e.toString()}';
      }
      
      setState(() {
        _messages.add(ChatMessage(
          text: errorMessage,
          isUser: false,
        ));
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDarkBlueGreen,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDarkBlueGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: AppColors.primaryGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'AI Coach',
              style: TextStyle(
                color: AppColors.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  );
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundDarkLight,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: AppColors.textWhite),
                      decoration: InputDecoration(
                        hintText: 'Ask about workouts, diet, or health...',
                        hintStyle: const TextStyle(color: AppColors.textGray),
                        filled: true,
                        fillColor: AppColors.backgroundDarkBlueGreen,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: AppColors.textBlack,
                      ),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: AppColors.primaryGreen,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppColors.primaryGreen
                    : AppColors.backgroundDarkLight,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight: message.isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                  bottomLeft: message.isUser
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser
                      ? AppColors.textBlack
                      : AppColors.textWhite,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: AppColors.primaryGreen,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}
