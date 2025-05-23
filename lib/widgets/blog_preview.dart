import '/utils/cached_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';




Future showBlogPreview(context, String title, String description, String thumbnailUrl, int loves, String source, String date) async {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SizedBox(
            
            width: MediaQuery.of(context).size.width * 0.50,
            child: ListView(
              
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Container(
                  height: 350,
                  width: MediaQuery.of(context).size.width,
                  child: CustomCacheImage(imageUrl: thumbnailUrl, radius: 0.0)
                      //Image(fit: BoxFit.cover, image: NetworkImage(thumbnailUrl)),
                ),

                Positioned(
                  top: 10,
                  right: 20,
                  child: CircleAvatar(
                    child: IconButton(icon: const Icon(Icons.close), onPressed:() => Navigator.pop(context) ),
                  ),
                )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),

                

                
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [

                        TextButton.icon(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)
                            )
                          ),
                          onPressed: ()async{
                            await launchUrl(source as Uri);
                          }, 
                          icon: Icon(Icons.link, color: Colors.grey[900],), 
                          label: Text('Source Url', style: TextStyle(color: Colors.grey[900]),)
                        )
                      ],
                    ),

                    const SizedBox(height: 20,),

                    Text(
                    title,
                    style: const TextStyle(
                        fontSize: 25,
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
                      const Icon(Icons.favorite, size: 16, color: Colors.grey),
                      Text(loves.toString(), style: const TextStyle(color: Colors.grey, fontSize: 13),),
                      const SizedBox(width: 15,),
                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                      Text(date, style: const TextStyle(color: Colors.grey, fontSize: 13),),
                      

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
                        color: Colors.grey[900]
                      ),
                      "h1": Style(
                        fontSize: FontSize(20),
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[900]
                      ),
                      "h2": Style(
                        fontSize: FontSize(18),
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[900]
                      ),
                      "h3": Style(
                        fontSize: FontSize(16),
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[900]
                      ),
                      "h4": Style(
                        fontSize: FontSize(14),
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[900]
                      ),
                      "h5": Style(
                        fontSize: FontSize(12),
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[900]
                      ),
                      "h6": Style(
                        fontSize: FontSize(10),
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[900]
                      ),
                    },
                    data: description,
                    // onLinkTap: (url, _, __, ___) async {
                    //   await launchUrl(Uri.parse(url!));
                    // },
                    // onImageTap: (url, _, __, ___) async {
                    //   await launchUrl(Uri.parse(url!));
                    // },
                  ),


                  ],
                  ),
                ),
                const SizedBox(height: 20,),
                
              ],
            ),
          ),
        );
      });
}
