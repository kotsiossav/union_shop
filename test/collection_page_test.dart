import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:union_shop/views/collection_page.dart';

void main() {
  group('CollectionPage Widget', () {
    test('CollectionPage can be instantiated with slug', () {
      const page = CollectionPage(slug: 'essential-range');
      expect(page, isNotNull);
      expect(page.slug, 'essential-range');
    });

    test('CollectionPage can be instantiated without slug', () {
      const page = CollectionPage();
      expect(page, isNotNull);
      expect(page.slug, '');
    });

    test('CollectionPage is a StatefulWidget', () {
      const page = CollectionPage(slug: 'test');
      expect(page, isA<StatefulWidget>());
    });

    test('CollectionPage with key can be instantiated', () {
      const page = CollectionPage(
        key: Key('collection-page'),
        slug: 'graduation',
      );
      expect(page, isNotNull);
      expect(page.key, isA<Key>());
      expect(page.slug, 'graduation');
    });

    test('CollectionPage slug property is accessible', () {
      const page1 = CollectionPage(slug: 'essential-range');
      const page2 = CollectionPage(slug: 'signature-range');
      const page3 = CollectionPage(slug: 'graduation');
      
      expect(page1.slug, 'essential-range');
      expect(page2.slug, 'signature-range');
      expect(page3.slug, 'graduation');
    });

    test('CollectionPage widget type is correct', () {
      const page = CollectionPage(slug: 'test');
      expect(page.runtimeType.toString(), 'CollectionPage');
    });
  });
}
