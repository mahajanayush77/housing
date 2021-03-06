import 'package:flutter/cupertino.dart';
import '../models/property.dart';
import '../utilities/api-response.dart';
import '../utilities/api_endpoints.dart';
import '../utilities/api_helper.dart';
import '../utilities/http_exception.dart';

// My properties provider for a particular user
class MyProperties with ChangeNotifier {
  List<Property> _myProp = [];
  List<Property> get myProp {
    return [..._myProp];
  }

  Future<ApiResponse> fetchProducts() async {
    ApiResponse response;
    response =await ApiHelper().getRequest(
      endpoint: eMyProperties,
    );

    _myProp.clear();
    if(!response.error){
      List<Property> list = response.data.map<Property>((e)=> Property.fromJson(e)).toList();
      _myProp.addAll(list);
    }
    return response;
  }

  // remove a property from list of added properties
  void deleteProperty(int id) async {
    //Remove from the list
    final existingIndex = _myProp.indexWhere((prod) => prod.id == id);
    var existingProp = _myProp[existingIndex];
    _myProp.removeWhere((prod) => prod.id == id);
    notifyListeners();

    try{
      ApiResponse response = await ApiHelper().deleteRequest(
        endpoint: eProperties + id.toString() + "/",
      );
      if(response.error){
        _myProp.insert(existingIndex, existingProp);
        notifyListeners();
      }
    }catch(error){
      _myProp.insert(existingIndex, existingProp);
      notifyListeners();
      throw HttpException(message: 'Deleting property failed');
    }
    notifyListeners(); // change UI everywhere there are listeners to object
  }

  Property findById(int id) {
    return _myProp.firstWhere((element) {
      return element.id == id;
    }, orElse: () => Property());
  }
}
