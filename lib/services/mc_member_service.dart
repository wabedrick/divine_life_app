import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import '../models/mc_member_model.dart';

class McMemberServices {
  static const String baseUrl = 'http://127.0.0.1:8000/mcMembers/mc_members.php';

  // Get all members
  static Future<List<MCMember>> getMembers({bool? activeOnly, String? mcName}) async {
    try {
      String url = '$baseUrl?action=get_members';
      if (activeOnly == true) url += '&active=1';
      if (mcName != null && mcName.isNotEmpty) url += '&mcName=${Uri.encodeComponent(mcName)}';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((e) => MCMember.fromMap(e)).toList();
      } else {
        throw Exception('Failed to load members');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get a single member by ID
  static Future<MCMember?> getMemberById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl?action=get_member&id=$id'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return MCMember.fromMap(data);
    }
    return null;
  }

  // Add a new member
  static Future<String> addMember(MCMember member) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      body: {'action': 'add_member', ...member.toMap(), 'mcName': member.mcName},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['id'];
    } else {
      throw Exception('Failed to add member');
    }
  }

  // Update a member
  static Future<void> updateMember(MCMember member) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      body: {'action': 'update_member', 'id': member.id, ...member.toMap(), 'mcName': member.mcName},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update member');
    }
  }

  // Delete a member
  static Future<void> deleteMember(String id) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      body: {'action': 'delete_member', 'id': id},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete member');
    }
  }

  // Search members
  static Future<List<MCMember>> searchMembers(String searchTerm) async {
    final response = await http.get(
      Uri.parse('$baseUrl?action=search_members&query=$searchTerm'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((e) => MCMember.fromMap(e)).toList();
    } else {
      throw Exception('Search failed');
    }
  }

  // Get new members (joined within 30 days)
  static Future<List<MCMember>> getNewMembers() async {
    final response = await http.get(
      Uri.parse('$baseUrl?action=get_new_members'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((e) => MCMember.fromMap(e)).toList();
    } else {
      throw Exception('Failed to get new members');
    }
  }

  // Get member statistics
  static Future<Map<String, dynamic>> getMemberStats() async {
    final response = await http.get(Uri.parse('$baseUrl?action=get_stats'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get stats');
    }
  }
}
