import '/utils/cached_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

showPlacePreview(
    context,
    String name,
    String location,
    String imageUrl_1,
    String description,
    double lat,
    double lng,
    String startpointName,
    String endpointName,
    double startpointLat,
    double startpointLng,
    double endpointLat,
    double endpointLng,
    String price,
    List paths) {

  showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.50,
            child: ListView(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    SizedBox(
                      height: 350,
                      width: MediaQuery.of(context).size.width,
                      child: CustomCacheImage(imageUrl: imageUrl_1, radius: 0.0)
                      
                      // Image(
                      //     fit: BoxFit.cover, image: NetworkImage(imageUrl_1)),
                    ),
                    Positioned(
                      top: 10,
                      right: 20,
                      child: CircleAvatar(
                        child: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context)),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        name,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 5, bottom: 10),
                        height: 3,
                        width: 100,
                        decoration: BoxDecoration(
                            color: Colors.indigoAccent,
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                          Text(
                            location,
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          RichText(
                              text: TextSpan(
                                  text: 'Latitude: ',
                                  style: const TextStyle(color: Colors.grey),
                                  children: <TextSpan>[
                                TextSpan(
                                    text: lat.toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.grey[700])),
                              ])),
                          const SizedBox(
                            width: 5,
                          ),
                          RichText(
                              text: TextSpan(
                                  text: 'Longitude: ',
                                  style: const TextStyle(color: Colors.grey),
                                  children: <TextSpan>[
                                TextSpan(
                                    text: lng.toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.grey[700])),
                              ])),
                        ],
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Html(
                          style: {
                            "p": Style(
                                fontSize: FontSize(16),
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[900]),
                            "h1": Style(
                                fontSize: FontSize(20),
                                fontWeight: FontWeight.w700,
                                color: Colors.grey[900]),
                            "h2": Style(
                                fontSize: FontSize(18),
                                fontWeight: FontWeight.w700,
                                color: Colors.grey[900]),
                            "h3": Style(
                                fontSize: FontSize(16),
                                fontWeight: FontWeight.w700,
                                color: Colors.grey[900]),
                            "h4": Style(
                                fontSize: FontSize(14),
                                fontWeight: FontWeight.w700,
                                color: Colors.grey[900]),
                            "h5": Style(
                                fontSize: FontSize(12),
                                fontWeight: FontWeight.w700,
                                color: Colors.grey[900]),
                            "h6": Style(
                                fontSize: FontSize(10),
                                fontWeight: FontWeight.w700,
                                color: Colors.grey[900]),
                          },
                          data: description),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text('Guide Details',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.w800)),
                      Container(
                        margin: const EdgeInsets.only(top: 5, bottom: 10),
                        height: 3,
                        width: 50,
                        decoration: BoxDecoration(
                            color: Colors.indigoAccent,
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          RichText(
                              text: TextSpan(
                                  text: 'Startpoint Name: ',
                                  style: const TextStyle(color: Colors.grey),
                                  children: <TextSpan>[
                                TextSpan(
                                    text: startpointName,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.grey[700])),
                              ])),
                          const Spacer(),
                          RichText(
                              text: TextSpan(
                                  text: 'Endpoint Name: ',
                                  style: const TextStyle(color: Colors.grey),
                                  children: <TextSpan>[
                                TextSpan(
                                    text: endpointName,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.grey[700])),
                              ])),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          RichText(
                              text: TextSpan(
                                  text: 'Startpoint Latitude: ',
                                  style: const TextStyle(color: Colors.grey),
                                  children: <TextSpan>[
                                TextSpan(
                                    text: startpointLat.toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.grey[700])),
                              ])),
                          const Spacer(),
                          RichText(
                              text: TextSpan(
                                  text: 'Startpoint Longitude: ',
                                  style: const TextStyle(color: Colors.grey),
                                  children: <TextSpan>[
                                TextSpan(
                                    text: startpointLng.toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.grey[700])),
                              ])),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          RichText(
                              text: TextSpan(
                                  text: 'Endpoint Latitude: ',
                                  style: const TextStyle(color: Colors.grey),
                                  children: <TextSpan>[
                                TextSpan(
                                    text: endpointLat.toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.grey[700])),
                              ])),
                          const Spacer(),
                          RichText(
                              text: TextSpan(
                                  text: 'Endpoint Longitude: ',
                                  style: const TextStyle(color: Colors.grey),
                                  children: <TextSpan>[
                                TextSpan(
                                    text: endpointLng.toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.grey[700])),
                              ])),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      RichText(
                          text: TextSpan(
                              text: 'Estimated Cost: ',
                              style: const TextStyle(color: Colors.grey),
                              children: <TextSpan>[
                            TextSpan(
                                text: price,
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey[700])),
                          ])),
                      const SizedBox(
                        height: 15,
                      ),
                      const Text('Paths',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.w800)),
                      Container(
                        margin: const EdgeInsets.only(top: 5, bottom: 10),
                        height: 2,
                        width: 20,
                        decoration: BoxDecoration(
                            color: Colors.indigoAccent,
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      Container(
                        child: paths.length == 0
                            ? const Center(
                                child: Text('No path list were added'),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: paths.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return ListTile(
                                    leading: CircleAvatar(
                                      child: Text(index.toString()),
                                    ),
                                    title: Text(paths[index]),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        );
      });
}
