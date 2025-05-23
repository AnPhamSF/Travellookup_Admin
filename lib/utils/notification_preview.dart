import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

showNotificationPreview(context, title, description) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          contentPadding: const EdgeInsets.all(80),
          elevation: 0,
          children: <Widget>[

            const Text('Xem trước', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: Colors.deepPurpleAccent),),

            const SizedBox(height: 20,),
            Text(title,

                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w700)),
            const SizedBox(
              height: 5,
            ),
            Html(
                    data: '''$description''',
                    style: {
                      "html": Style(
                        fontSize: FontSize(16.0),
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    },
                    // onLinkTap: (url, _, __, ___){
                    //   launchUrl(url as Uri);
                    // },
                  ),
            const SizedBox(
              height: 30,
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                        ),
                        child: const Text(
                          'Đóng',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                ],
              ),
            ),


          ],
        );
      });
}