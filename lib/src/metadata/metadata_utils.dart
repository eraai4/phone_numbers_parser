import '../iso_codes/iso_code.dart';
import '../metadata/metadata_finder.dart';
import '../metadata/models/phone_metadata_lengths.dart';
import '../metadata/models/phone_metadata_patterns.dart';
import '../validation/phone_number_type.dart';
import '../validation/validator.dart';

/// Utility class to access phone number metadata for a specific country
class PhoneNumberMetadataUtils {
  final IsoCode isoCode;
  final PhoneMetadataLengths _lengthMetadata;
  final PhoneMetadataPatterns _patternMetadata;

  /// Create metadata utils from 2-letter country code ('US', 'CA', 'BD', etc.)
  ///
  /// Example:
  /// ```dart
  /// final utils = PhoneNumberMetadataUtils('CA');
  /// final maxLength = utils.getMaxLength(PhoneNumberType.mobile);
  /// ```
  PhoneNumberMetadataUtils(String countryCode)
      : isoCode = IsoCode.values.byName(countryCode.toUpperCase()),
        _lengthMetadata = MetadataFinder.findMetadataLengthForIsoCode(
            IsoCode.values.byName(countryCode.toUpperCase())),
        _patternMetadata = MetadataFinder.findMetadataPatternsForIsoCode(
            IsoCode.values.byName(countryCode.toUpperCase()));

  /// Get all possible valid lengths for this country
  Set<int> getValidLengths([PhoneNumberType? type]) {
    return Set.from(_getLengths(_lengthMetadata, type));
  }

  /// Get maximum valid length for this country
  int? getMaxLength([PhoneNumberType? type]) {
    final lengths = getValidLengths(type);
    return lengths.isEmpty ? null : lengths.reduce((a, b) => a > b ? a : b);
  }

  /// Get minimum valid length for this country
  int? getMinLength([PhoneNumberType? type]) {
    final lengths = getValidLengths(type);
    return lengths.isEmpty ? null : lengths.reduce((a, b) => a < b ? a : b);
  }

  /// Validate if a national number matches valid patterns
  ///
  /// For partial input (shorter than minimum length), this validates
  /// whether the input could be a valid prefix of a complete number.
  /// For complete input, this validates the full pattern.
  bool validatePattern(String national, [PhoneNumberType? type]) {
    final minLength = getMinLength(type);

    // For partial input, check if it's a valid prefix
    if (minLength != null && national.length < minLength) {
      return _validatePrefix(national, type);
    }

    // For full-length input, use standard pattern validation
    return Validator.validateWithPattern(isoCode, national, type);
  }

  /// Validate if partial input could lead to a valid number
  bool _validatePrefix(String partial, PhoneNumberType? type) {
    final patterns = <String>[];

    if (type != null) {
      final pattern = _getPattern(_patternMetadata, type);
      if (pattern.isNotEmpty) {
        patterns.add(pattern);
      }
    } else {
      // Check both mobile and fixed line patterns
      final mobilePattern =
          _getPattern(_patternMetadata, PhoneNumberType.mobile);
      final fixedLinePattern =
          _getPattern(_patternMetadata, PhoneNumberType.fixedLine);
      if (mobilePattern.isNotEmpty) patterns.add(mobilePattern);
      if (fixedLinePattern.isNotEmpty) patterns.add(fixedLinePattern);
    }

    // Check if the partial input could be the start of any valid pattern
    return patterns.any((patternStr) {
      final maxLen = getMaxLength(type) ?? 15;
      // Create regex with anchors to match entire string
      final pattern = RegExp('^$patternStr\$');

      // Test if padding with any single digit could lead to a valid number
      for (int digit = 0; digit <= 9; digit++) {
        final testNumber = partial + ('$digit' * (maxLen - partial.length));
        if (pattern.hasMatch(testNumber)) {
          return true;
        }
      }
      return false;
    });
  }

  static String _getPattern(
    PhoneMetadataPatterns patternMetadata,
    PhoneNumberType type,
  ) {
    switch (type) {
      case PhoneNumberType.mobile:
        return patternMetadata.mobile;
      case PhoneNumberType.fixedLine:
        return patternMetadata.fixedLine;
      case PhoneNumberType.voip:
        return patternMetadata.voip;
      case PhoneNumberType.tollFree:
        return patternMetadata.tollFree;
      case PhoneNumberType.premiumRate:
        return patternMetadata.premiumRate;
      case PhoneNumberType.sharedCost:
        return patternMetadata.sharedCost;
      case PhoneNumberType.personalNumber:
        return patternMetadata.personalNumber;
      case PhoneNumberType.uan:
        return patternMetadata.uan;
      case PhoneNumberType.pager:
        return patternMetadata.pager;
      case PhoneNumberType.voiceMail:
        return patternMetadata.voiceMail;
      default:
        return patternMetadata.general;
    }
  }

  /// Validate if a national number has valid length
  bool validateLength(String national, [PhoneNumberType? type]) {
    return getValidLengths(type).contains(national.length);
  }

  static List<int> _getLengths(
    PhoneMetadataLengths lengthMetadatas,
    PhoneNumberType? type,
  ) {
    if (type != null) {
      switch (type) {
        case PhoneNumberType.mobile:
          return lengthMetadatas.mobile;
        case PhoneNumberType.fixedLine:
          return lengthMetadatas.fixedLine;
        case PhoneNumberType.voip:
          return lengthMetadatas.voip;
        case PhoneNumberType.tollFree:
          return lengthMetadatas.tollFree;
        case PhoneNumberType.premiumRate:
          return lengthMetadatas.premiumRate;
        case PhoneNumberType.sharedCost:
          return lengthMetadatas.sharedCost;
        case PhoneNumberType.personalNumber:
          return lengthMetadatas.personalNumber;
        case PhoneNumberType.uan:
          return lengthMetadatas.uan;
        case PhoneNumberType.pager:
          return lengthMetadatas.pager;
        case PhoneNumberType.voiceMail:
          return lengthMetadatas.voiceMail;
        default:
          return lengthMetadatas.general;
      }
    } else {
      // Return all possible lengths if no type specified
      return [
        ...lengthMetadatas.mobile,
        ...lengthMetadatas.fixedLine,
        ...lengthMetadatas.voip,
        ...lengthMetadatas.tollFree,
        ...lengthMetadatas.premiumRate,
        ...lengthMetadatas.sharedCost,
        ...lengthMetadatas.personalNumber,
        ...lengthMetadatas.uan,
        ...lengthMetadatas.pager,
        ...lengthMetadatas.voiceMail,
      ];
    }
  }
}
