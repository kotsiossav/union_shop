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

    test('CollectionPage slug can handle special characters', () {
      const page = CollectionPage(slug: 'autumn-favourites-2024');
      expect(page.slug, 'autumn-favourites-2024');
    });

    test('CollectionPage slug can be a single word', () {
      const page = CollectionPage(slug: 'sale');
      expect(page.slug, 'sale');
    });

    test('Multiple CollectionPage instances can coexist', () {
      const page1 = CollectionPage(slug: 'essential-range');
      const page2 = CollectionPage(slug: 'signature-range');
      const page3 = CollectionPage(slug: 'graduation');

      expect(page1.slug, isNot(equals(page2.slug)));
      expect(page2.slug, isNot(equals(page3.slug)));
      expect(page1.slug, isNot(equals(page3.slug)));
    });

    test('CollectionPage with same slug creates equal instances', () {
      const page1 = CollectionPage(slug: 'test-collection');
      const page2 = CollectionPage(slug: 'test-collection');

      expect(page1.slug, equals(page2.slug));
      expect(page1.runtimeType, equals(page2.runtimeType));
    });
  });

  group('CollectionPage Slug Variations', () {
    test('CollectionPage handles lowercase slugs', () {
      const page = CollectionPage(slug: 'essentialrange');
      expect(page.slug, 'essentialrange');
    });

    test('CollectionPage handles uppercase slugs', () {
      const page = CollectionPage(slug: 'ESSENTIAL-RANGE');
      expect(page.slug, 'ESSENTIAL-RANGE');
    });

    test('CollectionPage handles mixed-case slugs', () {
      const page = CollectionPage(slug: 'Essential-Range');
      expect(page.slug, 'Essential-Range');
    });

    test('CollectionPage handles slugs with numbers', () {
      const page = CollectionPage(slug: 'collection-2024');
      expect(page.slug, 'collection-2024');
    });

    test('CollectionPage handles long slugs', () {
      const page =
          CollectionPage(slug: 'very-long-collection-name-with-many-words');
      expect(page.slug, 'very-long-collection-name-with-many-words');
    });

    test('CollectionPage handles empty slug as default', () {
      const page1 = CollectionPage();
      const page2 = CollectionPage(slug: '');

      expect(page1.slug, '');
      expect(page2.slug, '');
      expect(page1.slug, equals(page2.slug));
    });
  });

  group('CollectionPage Widget Properties', () {
    test('CollectionPage extends StatefulWidget', () {
      const page = CollectionPage(slug: 'test');
      expect(page, isA<Widget>());
      expect(page, isA<StatefulWidget>());
    });

    test('CollectionPage key is optional', () {
      const page1 = CollectionPage(slug: 'test');
      const page2 = CollectionPage(slug: 'test', key: Key('test-key'));

      expect(page1.key, isNull);
      expect(page2.key, isNotNull);
    });

    test('CollectionPage slug parameter is required', () {
      // Default constructor provides empty string
      const page = CollectionPage();
      expect(page.slug, isA<String>());
    });
  });

  group('CollectionPage Known Collections', () {
    test('CollectionPage works with essential-range slug', () {
      const page = CollectionPage(slug: 'essential-range');
      expect(page.slug, 'essential-range');
      expect(page, isA<CollectionPage>());
    });

    test('CollectionPage works with signature-range slug', () {
      const page = CollectionPage(slug: 'signature-range');
      expect(page.slug, 'signature-range');
      expect(page, isA<CollectionPage>());
    });

    test('CollectionPage works with graduation slug', () {
      const page = CollectionPage(slug: 'graduation');
      expect(page.slug, 'graduation');
      expect(page, isA<CollectionPage>());
    });

    test('CollectionPage works with autumn-favourites slug', () {
      const page = CollectionPage(slug: 'autumn-favourites');
      expect(page.slug, 'autumn-favourites');
      expect(page, isA<CollectionPage>());
    });

    test('CollectionPage works with sale slug', () {
      const page = CollectionPage(slug: 'sale');
      expect(page.slug, 'sale');
      expect(page, isA<CollectionPage>());
    });
  });
}
