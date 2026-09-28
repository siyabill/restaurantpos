class ChatMessage {
  final String sender;
  final String content;
  final DateTime timestamp;
  final String? senderName;

  ChatMessage({
    required this.sender,
    required this.content,
    required this.timestamp,
    this.senderName,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    sender: json['sender'] as String? ?? '',
    content: json['message'] as String? ?? json['content'] as String? ?? '',
    senderName: json['senderName'] as String? ?? json['sender_name'] as String?,
    timestamp: json['timestamp'] != null 
        ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
        : DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'sender': sender,
    'message': content,
    'content': content,
    if (senderName != null) 'senderName': senderName,
    'timestamp': timestamp.toUtc().toIso8601String(),
  };
}

class TicketModel {
  final String id;
  final String? appUserId;
  final String? restaurantCode;
  final String? restaurantName;
  final String? category;
  final String subject;
  final String description;
  final String? priority;
  final String status;
  final List<ChatMessage> replies;
  final DateTime createdAt;
  final DateTime updatedAt;

  TicketModel({
    required this.id,
    this.appUserId,
    this.restaurantCode,
    String? restaurantName,
    String? customerName,
    this.category,
    required this.subject,
    this.description = '',
    this.priority,
    required this.status,
    List<ChatMessage>? replies,
    List<ChatMessage>? messages,
    required this.createdAt,
    DateTime? updatedAt,
  })  : restaurantName = restaurantName ?? customerName,
        replies = replies ?? messages ?? const [],
        updatedAt = updatedAt ?? createdAt;

  // Getter aliases for backward compatibility with UI
  String get customerName => restaurantName ?? '';
  List<ChatMessage> get messages => replies;

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    var rawReplies = json['replies'] as List? ?? json['messages'] as List?;
    List<ChatMessage> parsedReplies = rawReplies != null
        ? rawReplies.map((m) => ChatMessage.fromJson(m as Map<String, dynamic>)).toList()
        : [];
    return TicketModel(
      id: json['id'] as String? ?? '',
      appUserId: json['app_user_id'] as String?,
      restaurantCode: json['restaurant_code'] as String?,
      restaurantName: json['restaurant_name'] as String? ?? json['customer_name'] as String? ?? '',
      category: json['category'] as String?,
      subject: json['subject'] as String? ?? '',
      description: json['description'] as String? ?? '',
      priority: json['priority'] as String?,
      status: json['status'] as String? ?? 'open',
      replies: parsedReplies,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'app_user_id': appUserId,
    'restaurant_code': restaurantCode,
    'restaurant_name': restaurantName,
    'category': category,
    'subject': subject,
    'description': description,
    'priority': priority,
    'status': status,
    'replies': replies.map((m) => m.toJson()).toList(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
