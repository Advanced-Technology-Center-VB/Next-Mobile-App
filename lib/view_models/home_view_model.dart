import 'package:atc_mobile_app/contracts/api_service_contract.dart';
import 'package:atc_mobile_app/models/event_model.dart';
import 'package:atc_mobile_app/provider/base_model.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';

class HomeViewModel extends BaseModel {
  List<EventModel> events = List.empty();
  List<Image> headlineImageCache = List.empty(growable: true);

  bool isReady = false;
  bool error = false;

  var api = GetIt.instance.get<ApiServiceContract>();

  HomeViewModel() {
    fetchData();
  }

  Future<void> fetchData() async {
    isReady = false;
    error = false;

    try {
      events = await api.fetchEvents();

      print(events);

      for (var event in events.where((event) => event.headline)) {
        headlineImageCache.add(Image.memory(
          await readBytes(Uri.parse(event.imageUrl ?? "")),
          fit: BoxFit.cover,
        ));
      }

      isReady = true;
      error = false;
    } catch (ex) {
      error = true;
      throw Exception(ex);
    }

    notifyListeners();
  }
}