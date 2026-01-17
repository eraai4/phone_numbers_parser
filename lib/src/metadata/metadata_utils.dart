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
  bool validatePattern(String national, [PhoneNumberType? type]) {
    return Validator.validateWithPattern(isoCode, national, type);
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
