module.exports = function () {
  return {
    // Variables are NODE_ID and NODE_NAME (only a-z0-9\- other chars are replaced with _)
//    'nodeInfos': [
//      {
//        'name': 'Clientstatistik',
//        'href': 'https://regensburg.freifunk.net/netz/statistik/node/{NODE_ID}/',
//        'image': 'https://grafana.regensburg.freifunk.net/render/d-solo/000000026/node?panelId=1&var-node={NODE_ID}&from=now-7d&width=650&height=350&theme=light&_t={TIME}',
//        'title': 'Knoten {NODE_ID} - weiteren Statistiken'
//      },
//      {
//        'name': 'Trafficstatistik',
//        'href': 'https://regensburg.freifunk.net/netz/statistik/node/{NODE_ID}/',
//        'image': 'https://grafana.regensburg.freifunk.net/render/d-solo/000000026/node?panelId=2&from=now-7d&var-node={NODE_ID}&width=650&height=350&theme=light&_t={TIME}',
//        'title': 'Knoten {NODE_ID} - weiteren Statistiken'
//      },
//      {
//        'name': 'Airtime',
//        'href': 'https://regensburg.freifunk.net/netz/statistik/node/{NODE_ID}/',
//        'image': 'https://grafana.regensburg.freifunk.net/render/d-solo/000000026/node?panelId=5&from=now-7d&var-node={NODE_ID}&width=650&height=350&theme=light&_t={TIME}',
//        'title': 'Knoten {NODE_ID} - weiteren Statistiken'
//      }
//    ],
//    'linkInfos': [
//      {
//        'name': 'Statistik für alle Links zwischen diese Knoten',
//        'image': 'https://grafana.regensburg.freifunk.net/render/d-solo/000000026/node?panelId=7&var-node={SOURCE_ID}&var-nodetolink={TARGET_ID}&from=now-7d&&width=650&height=350&theme=light&_t={TIME}',
//        'title': 'Linkstatistik des letzten Tages, min und max aller Links zwischen diesen Knoten'
//     }
//    ],
    // Array of data provider are supported
    'dataPath': [
      '../data/'
    ],
    'siteName': 'Freifunk Ulm',
    'mapLayers': [
      {
        'name': 'Freifunk',
        'url': 'https://tile30.freifunk-ulm.de/map/{z}/{x}/{y}.png',
        'config': {
          'maxZoom': 20,
          //'subdomains': '1234',
          'attribution': '<a href="http://www.openmaptiles.org/" target="_blank">&copy; OpenMapTiles</a> <a href="http://www.openstreetmap.org/about/" target="_blank">&copy; OpenStreetMap contributors</a>',
          'start': 6
        }
      },
      //{
      //  'name': 'Freifunk Regensburg Night',
      //  // Please ask Freifunk Regensburg before using its tile server - example with retina and dark tiles
      //  'url': 'https://{s}.tiles.ffrgb.net/n/{z}/{x}/{y}{retina}.png',
      //  'config': {
      //    'maxZoom': 20,
      //    'subdomains': '1234',
      //    'attribution': ' <a href="http://www.openmaptiles.org/" target="_blank">&copy; OpenMapTiles</a> <a href="http://www.openstreetmap.org/about/" target="_blank">&copy; OpenStreetMap contributors</a>',
      //    'mode': 'night',
      //    'start': 19,
      //    'end': 7
      //  }
      //},
      {
        'name': 'OpenStreetMap.HOT',
        'url': 'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
        'config': {
          'maxZoom': 19,
          'attribution': '&copy; Openstreetmap France | &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
        }
      },
      {
        'name': 'Esri.WorldImagery',
        'url': '//server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
        'config': {
          'maxZoom': 20,
          'attribution': 'Tiles &copy; Esri &mdash; Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community'
        }
      }
    ],
    // Set a visible frame
    'fixedCenter': [
      // Northwest
      [
        48.7,
        8.5
      ],
      // Southeast
      [
        47.3,
        10.75
      ]
    ],
    'siteNames': [
      {
        'site': 'ulm',
        'name': 'Ulm',
        'link': 'http://www.freifunk-ulm.de'
      },
      {
        'site': 'ostallgaeu',
        'name': 'Ostallgäu',
        'link': 'http://freifunk-ostallgaeu.de'
      }
    ],
    'linkList': [
      {
        'title': 'Impressum',
        'href': 'http://freifunk-unterstuetzungsverein.de/Impressum.html'
      },
      {
        'title': 'Datenschutz',
        'href': 'http://freifunk-unterstuetzungsverein.de/datenschutzerklaerung.html'
      }
    ]
  };
};
