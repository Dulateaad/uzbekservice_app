class Country {
  final String code;
  final String name;
  final String flag;
  final String phoneCode;
  final List<Operator> operators;

  const Country({
    required this.code,
    required this.name,
    required this.flag,
    required this.phoneCode,
    required this.operators,
  });
}

class Operator {
  final String code;
  final String name;
  final String countryCode;
  final List<String> prefixes;

  const Operator({
    required this.code,
    required this.name,
    required this.countryCode,
    required this.prefixes,
  });
}

class CountryOperatorData {
  static const List<Country> countries = [
    Country(
      code: 'UZ',
      name: 'Узбекистан',
      flag: '🇺🇿',
      phoneCode: '+998',
      operators: [
        Operator(
          code: 'UCELL',
          name: 'Ucell',
          countryCode: 'UZ',
          prefixes: ['90', '91', '92', '93', '94', '95'],
        ),
        Operator(
          code: 'BEELINE',
          name: 'Beeline',
          countryCode: 'UZ',
          prefixes: ['88', '89', '90', '91', '92', '93', '94', '95'],
        ),
        Operator(
          code: 'UZMOBILE',
          name: 'UzMobile',
          countryCode: 'UZ',
          prefixes: ['97', '98', '99'],
        ),
        Operator(
          code: 'MOBIUZ',
          name: 'MobiUz',
          countryCode: 'UZ',
          prefixes: ['88', '89', '90', '91', '92', '93', '94', '95'],
        ),
      ],
    ),
    Country(
      code: 'KZ',
      name: 'Казахстан',
      flag: '🇰🇿',
      phoneCode: '+7',
      operators: [
        Operator(
          code: 'BEELINE_KZ',
          name: 'Beeline',
          countryCode: 'KZ',
          prefixes: ['705', '706', '707', '708', '747', '750', '751', '760', '761', '762', '763', '764', '771', '775', '776', '777', '778'],
        ),
        Operator(
          code: 'KCELL',
          name: 'Kcell',
          countryCode: 'KZ',
          prefixes: ['700', '701', '702', '703', '704', '705', '706', '707', '708', '747', '750', '751', '760', '761', '762', '763', '764', '771', '775', '776', '777', '778'],
        ),
        Operator(
          code: 'TELE2',
          name: 'Tele2',
          countryCode: 'KZ',
          prefixes: ['700', '701', '702', '703', '704', '705', '706', '707', '708', '747', '750', '751', '760', '761', '762', '763', '764', '771', '775', '776', '777', '778'],
        ),
        Operator(
          code: 'ALTEL',
          name: 'Altel',
          countryCode: 'KZ',
          prefixes: ['700', '701', '702', '703', '704', '705', '706', '707', '708', '747', '750', '751', '760', '761', '762', '763', '764', '771', '775', '776', '777', '778'],
        ),
      ],
    ),
  ];

  static Country getCountryByCode(String code) {
    return countries.firstWhere(
      (country) => country.code == code,
      orElse: () => countries.first, // По умолчанию Узбекистан
    );
  }

  static Operator? getOperatorByPrefix(String countryCode, String prefix) {
    final country = getCountryByCode(countryCode);
    for (final operator in country.operators) {
      if (operator.prefixes.contains(prefix)) {
        return operator;
      }
    }
    return null;
  }

  static List<String> getPhoneNumberExamples(String countryCode) {
    final country = getCountryByCode(countryCode);
    final examples = <String>[];
    
    for (final operator in country.operators) {
      if (operator.prefixes.isNotEmpty) {
        final prefix = operator.prefixes.first;
        final example = '${country.phoneCode} $prefix 123 45 67';
        examples.add(example);
        if (examples.length >= 2) break; // Максимум 2 примера
      }
    }
    
    return examples;
  }
}
