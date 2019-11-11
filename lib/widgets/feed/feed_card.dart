import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_provider_app/exports.dart';
import 'package:flutter_provider_app/models/postsfeed/posts_feed_entity.dart';
import 'package:flutter_provider_app/widgets/feed/post_controls.dart';
import 'package:html_unescape/html_unescape.dart';

class FeedCardImage extends StatefulWidget {
  final PostsFeedDataChildrenData _data;

  FeedCardImage(this._data);

  @override
  _FeedCardImageState createState() => _FeedCardImageState();
}

class _FeedCardImageState extends State<FeedCardImage> {
  final HtmlUnescape _htmlUnescape = new HtmlUnescape();

  @override
  Widget build(BuildContext context) {
    print("Build Image Feed Card");
    final mq = MediaQuery.of(context).size;
    double ratio;
    String url;
    if (widget._data.preview != null) {
      ratio = (mq.width - 16) / widget._data.preview.images.first.source.width;
      url = _htmlUnescape.convert(widget._data.preview.images.first.source.url);
    }

    return Consumer(builder: (BuildContext context, FeedProvider model, _) {
      return Card(
        elevation: 10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            StickyTag(widget._data.stickied),
            Padding(
              padding:
                  const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _htmlUnescape.convert(widget._data.title),
                    style: Theme.of(context).textTheme.title,
                  ),
                ],
              ),
            ),
            widget._data.preview != null
                ? Center(
                    child: Image(
                      image: CachedNetworkImageProvider(
                        url,
                      ),
                      fit: BoxFit.fitWidth,
                      height: widget._data.preview.images.first.source.height
                              .toDouble() *
                          ratio,
                    ),
                  )
                : Container(),
            PostControls(widget._data),
          ],
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      );
    });
  }
}

class FeedCardSelfText extends StatefulWidget {
  final PostsFeedDataChildrenData _data;

  FeedCardSelfText(this._data);

  @override
  _FeedCardSelfTextState createState() => _FeedCardSelfTextState();
}

class _FeedCardSelfTextState extends State<FeedCardSelfText> {
  final HtmlUnescape unescape = new HtmlUnescape();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          StickyTag(widget._data.stickied),
          Padding(
            padding: const EdgeInsets.only(
                top: 0.0, left: 16.0, right: 16.0, bottom: 8.0),
            child: Text(
              unescape.convert(widget._data.title),
              style: Theme.of(context).textTheme.title,
            ),
          ),
          widget._data.selftext != ""
              ? Padding(
                  padding: const EdgeInsets.only(
                    top: 8.0,
                    bottom: 4.0,
                    left: 16.0,
                    right: 16.0,
                  ),
                  child: Html(
                    defaultTextStyle: Theme.of(context).textTheme.body1,
                    linkStyle: Theme.of(context)
                        .textTheme
                        .body1
                        .copyWith(color: Theme.of(context).accentColor),
                    padding: EdgeInsets.all(0),
                    data: """${unescape.convert(widget._data.selftextHtml)}""",
                    useRichText: true,
                    onLinkTap: (url) {
                      if (url.startsWith("/r/") || url.startsWith("r/")) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return SubredditFeedPage(
                                  subreddit: url.startsWith("/r/")
                                      ? url.replaceFirst("/r/", "")
                                      : url.replaceFirst("r/", ""));
                            },
                          ),
                        );
                      } else if (url.startsWith("/u/") ||
                          url.startsWith("u/")) {
                      } else {
                        print("launching web view");

                        launchURL(context, url);
                      }
                    },
                  ),
                )
              : Container(),
          PostControls(widget._data),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

class StickyTag extends StatelessWidget {
  final bool _isStickied;

  StickyTag(this._isStickied);

  @override
  Widget build(BuildContext context) {
    return _isStickied
        ? Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 16, bottom: 12.0),
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text('Stickied'),
              ),
              color: Colors.green,
            ),
          )
        : Padding(
            padding: EdgeInsets.only(top: 24.0),
          );
  }
}
