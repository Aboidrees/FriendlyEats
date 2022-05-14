// Copyright 2020 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:friendlyeats/src/model/values.dart';

typedef RestaurantPressedCallback = void Function(String restaurantId);

typedef CloseRestaurantPressedCallback = void Function();

class Restaurant {
  final String id;
  final String name;
  final String category;
  final String city;
  final double avgRating;
  final int numRatings;
  final int price;
  final String photo;
  final DocumentReference reference;

  Map<String, dynamic> toMap() => {
        'name': name,
        'category': category,
        'city': city,
        'numRatings': numRatings,
        'price': price,
        'photo': photo,
        'avgRating': avgRating,
      };

  Restaurant._({this.name, this.category, this.city, this.price, this.photo})
      : id = null,
        numRatings = 0,
        avgRating = 0,
        reference = null;

  Restaurant.fromSnapshot(DocumentSnapshot snapshot)
      : assert(snapshot != null),
        id = snapshot.id,
        name = (snapshot.data() as dynamic)['name'],
        category = (snapshot.data() as dynamic)['category'],
        city = (snapshot.data() as dynamic)['city'],
        avgRating = (snapshot.data() as dynamic)['avgRating'].toDouble(),
        numRatings = (snapshot.data() as dynamic)['numRatings'],
        price = (snapshot.data() as dynamic)['price'],
        photo = (snapshot.data() as dynamic)['photo'],
        reference = snapshot.reference;

  factory Restaurant.random() {
    return Restaurant._(
      category: getRandomCategory(),
      city: getRandomCity(),
      name: getRandomName(),
      price: Random().nextInt(3) + 1,
      photo: getRandomPhoto(),
    );
  }
}
