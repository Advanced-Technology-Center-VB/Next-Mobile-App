import 'dart:convert';

import 'package:atc_mobile_app/contracts/api_service_contract.dart';
import 'package:atc_mobile_app/models/category_model.dart';
import 'package:atc_mobile_app/models/event_model.dart';
import 'package:atc_mobile_app/models/information_model.dart';
import 'package:atc_mobile_app/models/program_model.dart';
import 'package:atc_mobile_app/models/testimony_model.dart';
import 'package:http/http.dart' as http;

class AzureApiService extends ApiServiceContract {
  @override
  Future<InformationModel> fetchAtcInformation() {
    // TODO: implement fetchAtcInformation
    throw UnimplementedError();
  }

  @override
  Future<List<CategoryModel>> fetchCategories() async {
    final response = await http.get(Uri.parse("http://192.168.50.151:5025/api/v1/categories"));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as List<dynamic>;

      List<CategoryModel> categoryList = List.empty(growable: true);

      for (var i = 0; i < json.length; i++) {
        categoryList.add(CategoryModel.fromJson(json[i] as Map<String, dynamic>));
      }

      return categoryList;
    } else {
      throw Exception("Failed to load categories.");
    }
  }

  @override
  Future<ProgramModel> fetchClass(int id) {
    // TODO: implement fetchClass
    throw UnimplementedError();
  }

  @override
  Future<List<ProgramModel>> fetchClasses(int mask) async {
    final response = await http.get(Uri.parse("http://192.168.50.151:5025/api/v1/classes"));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as List<dynamic>;

      List<ProgramModel> classList = List.empty(growable: true);

      for (var i = 0; i < json.length; i++) {
        classList.add(ProgramModel.fromJson(json[i] as Map<String, dynamic>));
      }

      return classList;
    } else {
      throw Exception("Failed to load classes.");
    }
  }

  @override
  Future<List<EventModel>> fetchEvents() async {
    final response = await http.get(Uri.parse("http://192.168.50.151:5025/api/v1/events"));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as List<dynamic>;

      List<EventModel> eventList = List.empty(growable: true);

      for (var i = 0; i < json.length; i++) {
        var date = DateTime.parse((json[i] as Map<String, dynamic>)["startTimestamp"]);

        if (date.isBefore(DateTime.now())) {
          continue;
        }

        eventList.add(EventModel.fromJson(json[i] as Map<String, dynamic>));
      }

      return eventList;
    } else {
      throw Exception("Failed to load events.");
    }
  }

  @override
  Future<List<String>> fetchImages(int classId) async {
    final response = await http.get(Uri.parse("https://api.nextiswhatwedo.org/api/images?classId=$classId"));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as List<dynamic>;

      List<String> imageList = List.empty(growable: true);

      for (var i = 0; i < json.length; i++) {
        String url = switch (json[i] as Map<String, dynamic>) {
          {
            'url' : String mapUrl,
          } => mapUrl,
          _ => throw Exception()
        };

        imageList.add(url);
      }

      return imageList;
    } else {
      throw Exception("Failed to load images.");
    }
  }

  @override
  Future<List<TestimonyModel>> fetchTestimonies(int classId) async {
    final response = await http.get(Uri.parse("https://api.nextiswhatwedo.org/api/testimonies?classId=$classId"));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as List<dynamic>;

      List<TestimonyModel> testimonyList = List.empty(growable: true);

      for (var i = 0; i < json.length; i++) {
        testimonyList.add(TestimonyModel.fromJson(json[i] as Map<String, dynamic>));
      }

      return testimonyList;
    } else {
      throw Exception("Failed to load testimonies.");
    }
  }

}