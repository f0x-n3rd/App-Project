// lib/services/unit_conversion_service.dart
enum UnitCategory { length, weight, temperature, volume }

enum LengthUnit { meter, kilometer, centimeter, millimeter }

enum WeightUnit { kilogram, gram, pound }

enum TemperatureUnit { celsius, fahrenheit }

enum VolumeUnit { liter, milliliter }

class UnitConversionService {
  // ----------------------------------------------------------
  // LENGTH
  // ----------------------------------------------------------
  static double convertLength(double value, LengthUnit from, LengthUnit to) {
    // convert to meters first
    double meters = switch (from) {
      LengthUnit.meter => value,
      LengthUnit.kilometer => value * 1000,
      LengthUnit.centimeter => value / 100,
      LengthUnit.millimeter => value / 1000,
    };

    // convert meters to target
    return switch (to) {
      LengthUnit.meter => meters,
      LengthUnit.kilometer => meters / 1000,
      LengthUnit.centimeter => meters * 100,
      LengthUnit.millimeter => meters * 1000,
    };
  }

  // ----------------------------------------------------------
  // WEIGHT
  // ----------------------------------------------------------
  static double convertWeight(double value, WeightUnit from, WeightUnit to) {
    // convert to kilograms first
    double kg = switch (from) {
      WeightUnit.kilogram => value,
      WeightUnit.gram => value / 1000,
      WeightUnit.pound => value * 0.453592,
    };

    // convert kg to target
    return switch (to) {
      WeightUnit.kilogram => kg,
      WeightUnit.gram => kg * 1000,
      WeightUnit.pound => kg / 0.453592,
    };
  }

  // ----------------------------------------------------------
  // TEMPERATURE
  // ----------------------------------------------------------
  static double convertTemperature(
    double value,
    TemperatureUnit from,
    TemperatureUnit to,
  ) {
    if (from == to) return value;

    if (from == TemperatureUnit.celsius && to == TemperatureUnit.fahrenheit) {
      return (value * 9 / 5) + 32;
    }

    if (from == TemperatureUnit.fahrenheit && to == TemperatureUnit.celsius) {
      return (value - 32) * 5 / 9;
    }

    return value;
  }

  // ----------------------------------------------------------
  // VOLUME
  // ----------------------------------------------------------
  static double convertVolume(double value, VolumeUnit from, VolumeUnit to) {
    // convert to liters first
    double liters = switch (from) {
      VolumeUnit.liter => value,
      VolumeUnit.milliliter => value / 1000,
    };

    // convert liters to target
    return switch (to) {
      VolumeUnit.liter => liters,
      VolumeUnit.milliliter => liters * 1000,
    };
  }
}
