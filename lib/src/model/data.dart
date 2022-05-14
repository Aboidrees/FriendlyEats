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

import 'package:cloud_firestore/cloud_firestore.dart';

import './filter.dart';
import './restaurant.dart';
import './review.dart';

//* Reference for the restaurants collection
final resRef = FirebaseFirestore.instance.collection('restaurants');

//* This function convert Restaurant Snapshot to Restaurant Object
Restaurant toRestaurant(DocumentSnapshot doc) => Restaurant.fromSnapshot(doc);

Future<void> addRestaurant(Restaurant restaurant) {
  return resRef.add(restaurant.toMap());
}

Stream<QuerySnapshot> loadAllRestaurants() {
  return resRef.orderBy('avgRating', descending: true).limit(50).snapshots();
}

List<Restaurant> getRestaurantsFromQuery(QuerySnapshot snapshot) {
  return snapshot.docs.map(toRestaurant).toList();
}

Future<Restaurant> getRestaurant(String restaurantId) {
  return resRef.doc(restaurantId).get().then(toRestaurant);
}

Future<void> addReview({String restaurantId, Review review}) {
  final oneResRef = resRef.doc(restaurantId);
  final reviewsRef = oneResRef.collection('reviews').doc();

  return FirebaseFirestore.instance.runTransaction(
    (Transaction transaction) => transaction.get(oneResRef).then(toRestaurant).then(
      (Restaurant fresh) {
        final numRatings = fresh.numRatings + 1;
        final avgRating = ((fresh.numRatings * fresh.avgRating) + review.rating) / numRatings;
        transaction.update(oneResRef, {'numRatings': numRatings, 'avgRating': avgRating});
        transaction.set(reviewsRef, review.toMap());
      },
    ),
  );
}

Stream<QuerySnapshot> loadFilteredRestaurants(Filter filter) {
  Query collection = resRef;

  // filters
  //
  if (filter.category != null) {
    collection = collection.where('category', isEqualTo: filter.category);
  }
  //
  if (filter.city != null) {
    collection = collection.where('city', isEqualTo: filter.city);
  }
  //
  if (filter.price != null) {
    collection = collection.where('price', isEqualTo: filter.price);
  }
  //
  return collection.orderBy(filter.sort ?? 'avgRating', descending: true).limit(50).snapshots();
}

void addRestaurantsBatch(List<Restaurant> restaurants) => restaurants.forEach(addRestaurant);
//? this commented code is done better in the previous line
// {
// restaurants.forEach((Restaurant restaurant) => addRestaurant(restaurant));
// }
