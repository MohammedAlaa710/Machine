import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scanner_machine/Metro/Route.dart';

// ignore: camel_case_types
class metroService {
  final List<String> transitStation12 = const ['Sadat', 'Al-Shohada'];
  final String transitStation23 = 'Attaba';
  final String transitStation13 = 'Gamal Abd Al-Naser';
  static final metroService _instance = metroService._(); 
  static List<QueryDocumentSnapshot> stations = [];

  factory metroService() {
    return _instance;
  }

  metroService._(); 

  Future<void> getStations() async {
    if (stations.isEmpty) {
      try {
        QuerySnapshot metroLine1 = await FirebaseFirestore.instance
            .collection('Metro_Line_1')
            .orderBy('number')
            .get();
        QuerySnapshot metroLine2 = await FirebaseFirestore.instance
            .collection('Metro_Line_2')
            .orderBy('number')
            .get();
        QuerySnapshot metroLine3 = await FirebaseFirestore.instance
            .collection('Metro_Line_3')
            .orderBy('number')
            .get();
        stations.addAll(metroLine1.docs);
        stations.addAll(metroLine2.docs);
        stations.addAll(metroLine3.docs);
      } catch (e) {
        print('Error fetching stations: $e');
      }
    }
  }

  List<String> getStationNames() {
    return stations.map((station) => station['name'] as String).toList();
  }

  String calculatePrice(String from, String to) {
    try {
      int routeLength = getRoute(from, to).routeStations.length - 1;
      if (routeLength < 10) return '6.0 egp';
      if (routeLength < 17) return '8.0 egp';
      if (routeLength < 24) return '12.0 egp';
      return '15.0 egp';
    } catch (e) {
      return 'Error'; // Return an error message if an exception occurs
    }
  }

  int getStationIndex(String stationName) {
    for (int i = 0; i < stations.length; i++) {
      if (stations[i]['name'] == stationName) {
        return i;
      }
    }
    return -1;
  }

  int getCollection(int index) {
    if (index < 35) return 1;
    if (index < 55) return 2;
    return 3;
  }

//t3alaa
  MetroRoute getRoute(String from, String to) {
    MetroRoute route = MetroRoute();
    int fromIndx = getStationIndex(from);
    int toIndx = getStationIndex(to);
    int fromCollection = getCollection(fromIndx);
    int toCollection = getCollection(toIndx);
    if ((from == transitStation12[0] ||
            from == transitStation12[1] ||
            from == transitStation13 ||
            from == transitStation23 ||
            from == 'Mohamed Naguib') &&
        (to == transitStation12[0] ||
            to == transitStation12[1] ||
            to == transitStation13 ||
            to == transitStation23 ||
            to == 'Mohamed Naguib')) {
      fromCollection = getTransitIndices(from, to)[0];
      toCollection = getTransitIndices(from, to)[0];
      fromIndx = getTransitIndices(from, to)[1];
      toIndx = getTransitIndices(from, to)[2];
    }
    if (fromCollection == toCollection) {
      for (int i = fromIndx;
          fromIndx < toIndx ? i < toIndx + 1 : i > toIndx - 1;
          fromIndx < toIndx ? i++ : i--) {
        route.routeStations.add(stations[i]['name']);
        route.direction.add(getDirection(fromIndx, toIndx, toCollection));
        route.line.add(toCollection);
      }
    } else {
      if ((fromCollection == 1 && toCollection == 3) ||
          (fromCollection == 3 && toCollection == 1)) {
        List<int> naser = [];
        if (fromCollection == 1) {
          naser.add(19);
          naser.add(74);
        } else {
          naser.add(74);
          naser.add(19);
        }
        for (int i = fromIndx;
            fromIndx < naser[0]
                ? (stations[i]['name'] != transitStation13 && i < naser[0])
                : (stations[i]['name'] != transitStation13 && i > naser[0]);
            fromIndx < naser[0] ? i++ : i--) {
          route.routeStations.add(stations[i]['name']);
        }
        route.direction
            .add(getDirection(fromIndx, naser[0], getCollection(naser[0])));
        route.line.add(getCollection(naser[0]));
        route.routeStations.add(stations[naser[0]]['name']);
        route.transit = stations[naser[0]]['name'];
        int inc = naser[1] < toIndx ? 1 : -1;

        for (int i = naser[1] + inc;
            naser[1] < toIndx ? (i <= toIndx) : (i >= toIndx);
            naser[1] < toIndx ? i++ : i--) {
          route.routeStations.add(stations[i]['name']);
        }
        route.direction
            .add(getDirection(naser[1], toIndx, getCollection(toIndx)));
        route.line.add(getCollection(toIndx));
      }
      else if ((fromCollection == 2 && toCollection == 3) ||
          (fromCollection == 3 && toCollection == 2)) {
        List<int> ataba = [];
        if (fromCollection == 2) {
          ataba.add(46);
          ataba.add(73);
        } else {
          ataba.add(73);
          ataba.add(46);
        }
        for (int i = fromIndx;
            fromIndx < ataba[0]
                ? (stations[i]['name'] != transitStation13 && i < ataba[0])
                : (stations[i]['name'] != transitStation13 && i > ataba[0]);
            fromIndx < ataba[0] ? i++ : i--) {
          route.routeStations.add(stations[i]['name']);
        }
        route.direction
            .add(getDirection(fromIndx, ataba[0], getCollection(ataba[0])));
        route.line.add(getCollection(ataba[0]));
        route.routeStations.add(stations[ataba[0]]['name']);
        route.transit = stations[ataba[0]]['name'];
        int inc = ataba[1] < toIndx ? 1 : -1;

        for (int i = ataba[1] + inc;
            ataba[1] < toIndx ? (i <= toIndx) : (i >= toIndx);
            ataba[1] < toIndx ? i++ : i--) {
          route.routeStations.add(stations[i]['name']);
        }
        route.direction
            .add(getDirection(ataba[1], toIndx, getCollection(toIndx)));
        route.line.add(getCollection(toIndx));
      }
      
      else if ((fromCollection == 1 && toCollection == 2) ||
          (fromCollection == 2 && toCollection == 1)) {
        List<int> sadat = [];
        List<int> shohada = [];
        if (fromCollection == 2 && fromIndx < 44) {
          sadat.add(44);
          sadat.add(18);
        } else if (fromCollection == 1 && fromIndx < 18) {
          sadat.add(18);
          sadat.add(44);
        }
        if (fromCollection == 2 && fromIndx > 47) {
          shohada.add(47);
          shohada.add(21);
        } else if (fromCollection == 1 && fromIndx > 21) {
          shohada.add(21);
          shohada.add(47);
        }
        if (sadat.isNotEmpty) {
          for (int i = fromIndx;
              fromIndx < sadat[0]
                  ? (stations[i]['name'] != transitStation13 && i < sadat[0])
                  : (stations[i]['name'] != transitStation13 && i > sadat[0]);
              fromIndx < sadat[0] ? i++ : i--) {
            route.routeStations.add(stations[i]['name']);
          }
          route.direction
              .add(getDirection(fromIndx, sadat[0], getCollection(sadat[0])));
          route.line.add(getCollection(sadat[0]));
          route.routeStations.add(stations[sadat[0]]['name']);
          route.transit = stations[sadat[0]]['name'];
          int inc = sadat[1] < toIndx ? 1 : -1;
          for (int i = sadat[1] + inc;
              sadat[1] < toIndx ? (i <= toIndx) : (i >= toIndx);
              sadat[1] < toIndx ? i++ : i--) {
            route.routeStations.add(stations[i]['name']);
          }
          route.direction
              .add(getDirection(sadat[1], toIndx, getCollection(toIndx)));
          route.line.add(getCollection(toIndx));
        }
        else if (shohada.isNotEmpty) {
          for (int i = fromIndx;
              fromIndx < shohada[0]
                  ? (stations[i]['name'] != transitStation13 && i < shohada[0])
                  : (stations[i]['name'] != transitStation13 && i > shohada[0]);
              fromIndx < shohada[0] ? i++ : i--) {
            route.routeStations.add(stations[i]['name']);
          }
          route.direction.add(
              getDirection(fromIndx, shohada[0], getCollection(shohada[0])));
          route.line.add(getCollection(shohada[0]));
          route.routeStations.add(stations[shohada[0]]['name']);
          route.transit = stations[shohada[0]]['name'];
          int inc1 = shohada[1] < toIndx ? 1 : -1;
          for (int i = shohada[1] + inc1;
              shohada[1] < toIndx ? (i <= toIndx) : (i >= toIndx);
              shohada[1] < toIndx ? i++ : i--) {
            route.routeStations.add(stations[i]['name']);
          }
          route.direction
              .add(getDirection(shohada[1], toIndx, getCollection(toIndx)));
          route.line.add(getCollection(toIndx));
        }
        else {
          if ((from == 'Gamal Abd Al-Naser' || from == 'Orabi') &&
              (to == 'Mohamed Naguib' || toIndx < 44)) {
            for (int i = fromIndx;
                fromIndx < 18
                    ? (stations[i]['name'] != transitStation12[0] && i < 18)
                    : (stations[i]['name'] != transitStation12[0] && i > 18);
                fromIndx < 18 ? i++ : i--) {
              route.routeStations.add(stations[i]['name']);
            }
            route.direction.add(getDirection(fromIndx, 18, getCollection(18)));
            route.line.add(getCollection(18));
            route.routeStations.add(stations[18]['name']);
            route.transit = stations[18]['name'];
            int inc = 44 < toIndx ? 1 : -1;
            for (int i = 44 + inc;
                44 < toIndx ? (i <= toIndx) : (i >= toIndx);
                44 < toIndx ? i++ : i--) {
              route.routeStations.add(stations[i]['name']);
            }
            route.direction
                .add(getDirection(44, toIndx, getCollection(toIndx)));
            route.line.add(getCollection(toIndx));
          } else if ((from == 'Gamal Abd Al-Naser' || from == 'Orabi') &&
              (to == 'Attaba' || toIndx > 47)) {
            for (int i = fromIndx;
                fromIndx < 21
                    ? (stations[i]['name'] != transitStation12[1] && i < 21)
                    : (stations[i]['name'] != transitStation12[1] && i > 21);
                fromIndx < 21 ? i++ : i--) {
              route.routeStations.add(stations[i]['name']);
            }
            route.direction.add(getDirection(fromIndx, 21, getCollection(21)));
            route.line.add(getCollection(21));
            route.routeStations.add(stations[21]['name']);
            route.transit = stations[21]['name'];
            int inc1 = 47 < toIndx ? 1 : -1;
            for (int i = 47 + inc1;
                47 < toIndx ? (i <= toIndx) : (i >= toIndx);
                47 < toIndx ? i++ : i--) {
              route.routeStations.add(stations[i]['name']);
            }
            route.direction
                .add(getDirection(47, toIndx, getCollection(toIndx)));
            route.line.add(getCollection(toIndx));
          }
          else if ((from == 'Mohamed Naguib') &&
              (to == 'Gamal Abd Al-Naser' || toIndx < 18)) {
            for (int i = fromIndx;
                fromIndx < 44
                    ? (stations[i]['name'] != transitStation12[0] && i < 44)
                    : (stations[i]['name'] != transitStation12[0] && i > 44);
                fromIndx < 44 ? i++ : i--) {
              route.routeStations.add(stations[i]['name']);
            }
            route.direction.add(getDirection(fromIndx, 44, getCollection(44)));
            route.line.add(getCollection(44));
            route.routeStations.add(stations[44]['name']);
            route.transit = stations[44]['name'];
            int inc = 18 < toIndx ? 1 : -1;
            for (int i = 18 + inc;
                18 < toIndx ? (i <= toIndx) : (i >= toIndx);
                18 < toIndx ? i++ : i--) {
              route.routeStations.add(stations[i]['name']);
            }
            route.direction
                .add(getDirection(18, toIndx, getCollection(toIndx)));
            route.line.add(getCollection(toIndx));
          } else if ((from == 'Mohamed Naguib') &&
              (to == 'Orabi' || toIndx > 21)) {
            for (int i = fromIndx;
                fromIndx < 47
                    ? (stations[i]['name'] != transitStation12[1] && i < 47)
                    : (stations[i]['name'] != transitStation12[1] && i > 47);
                fromIndx < 47 ? i++ : i--) {
              route.routeStations.add(stations[i]['name']);
            }
            route.direction.add(getDirection(fromIndx, 47, getCollection(47)));
            route.line.add(getCollection(47));
            route.routeStations.add(stations[47]['name']);
            route.transit = stations[47]['name'];
            int inc1 = 21 < toIndx ? 1 : -1;
            for (int i = 21 + inc1;
                21 < toIndx ? (i <= toIndx) : (i >= toIndx);
                21 < toIndx ? i++ : i--) {
              route.routeStations.add(stations[i]['name']);
            }
            route.direction
                .add(getDirection(21, toIndx, getCollection(toIndx)));
            route.line.add(getCollection(toIndx));
          }
          else if ((from == 'Attaba') && (toIndx < 18)) {
            for (int i = fromIndx;
                fromIndx < 44
                    ? (stations[i]['name'] != transitStation12[0] && i < 44)
                    : (stations[i]['name'] != transitStation12[0] && i > 44);
                fromIndx < 44 ? i++ : i--) {
              route.routeStations.add(stations[i]['name']);
            }
            route.direction.add(getDirection(fromIndx, 44, getCollection(44)));
            route.line.add(getCollection(44));
            route.routeStations.add(stations[44]['name']);
            route.transit = stations[44]['name'];
            int inc = 18 < toIndx ? 1 : -1;
            for (int i = 18 + inc;
                18 < toIndx ? (i <= toIndx) : (i >= toIndx);
                18 < toIndx ? i++ : i--) {
              route.routeStations.add(stations[i]['name']);
            }
            route.direction
                .add(getDirection(18, toIndx, getCollection(toIndx)));
            route.line.add(getCollection(18));
          } else if ((from == 'Attaba') &&
              (to == 'Gamal Abd Al-Naser' || to == 'Orabi' || toIndx > 21)) {
            for (int i = fromIndx;
                fromIndx < 47
                    ? (stations[i]['name'] != transitStation12[1] && i < 47)
                    : (stations[i]['name'] != transitStation12[1] && i > 47);
                fromIndx < 47 ? i++ : i--) {
              route.routeStations.add(stations[i]['name']);
            }
            route.direction.add(getDirection(fromIndx, 47, getCollection(47)));
            route.line.add(getCollection(47));
            route.routeStations.add(stations[47]['name']);
            route.transit = stations[47]['name'];
            int inc1 = 21 < toIndx ? 1 : -1;
            for (int i = 21 + inc1;
                21 < toIndx ? (i <= toIndx) : (i >= toIndx);
                21 < toIndx ? i++ : i--) {
              route.routeStations.add(stations[i]['name']);
            }
            route.direction
                .add(getDirection(21, toIndx, getCollection(toIndx)));
            route.line.add(getCollection(toIndx));
          }
        }
      }
    }

    return route;
  }

  List<int> getTransitIndices(String from, String to) {
    if ((from == transitStation23 || from == transitStation13) &&
        (to == transitStation23 || to == transitStation13)) {
      if (from == transitStation23) {
        return [3, 73, 74];
      } else {
        return [3, 74, 73];
      }
    } else if ((from == transitStation23 || from == transitStation12[0]) &&
        (to == transitStation23 || to == transitStation12[0])) {
      if (from == transitStation23) {
        return [2, 46, 44];
      } else {
        return [2, 44, 46];
      }
    } else if ((from == transitStation23 || from == transitStation12[1]) &&
        (to == transitStation23 || to == transitStation12[1])) {
      if (from == transitStation23) {
        return [2, 46, 47];
      } else {
        return [2, 47, 46];
      }
    } else if ((from == 'Mohamed Naguib' || from == transitStation12[0]) &&
        (to == 'Mohamed Naguib' || to == transitStation12[0])) {
      if (from == 'Mohamed Naguib') {
        return [2, 45, 44];
      } else {
        return [2, 44, 45];
      }
    } else if ((from == 'Mohamed Naguib' || from == transitStation12[1]) &&
        (to == 'Mohamed Naguib' || to == transitStation12[1])) {
      if (from == 'Mohamed Naguib') {
        return [2, 45, 47];
      } else {
        return [2, 47, 45];
      }
    }
    return [
      getCollection(getStationIndex(from)),
      getStationIndex(from),
      getStationIndex(to)
    ];
  }

  String getDirection(int fromIndx, int toIndx, int toCollection) {
    if (fromIndx > toIndx) {
      switch (toCollection) {
        case 1:
          return 'Helwan Direction';

        case 2:
          return 'El-Monib Direction';
        case 3:
          return 'Adli Mansour Direction';
        default:
          return 'Unknown destination line';
      }
    } else {
      switch (toCollection) {
        case 1:
          return 'El-Marg Direction';

        case 2:
          return 'Shoubra El-Kheima Direction';

        case 3:
          return 'Rod El Farag Corridor Direction';

        default:
          return 'Unknown destination line';
      }
    }
  }
}
