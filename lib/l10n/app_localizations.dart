import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @hourlyForecast.
  ///
  /// In en, this message translates to:
  /// **'Hourly Forecast'**
  String get hourlyForecast;

  /// No description provided for @dailyForecast.
  ///
  /// In en, this message translates to:
  /// **'5-Day Forecast'**
  String get dailyForecast;

  /// No description provided for @weatherDetails.
  ///
  /// In en, this message translates to:
  /// **'Weather Details'**
  String get weatherDetails;

  /// No description provided for @temperatureUnit.
  ///
  /// In en, this message translates to:
  /// **'Temperature Unit'**
  String get temperatureUnit;

  /// No description provided for @tempUnitChanged.
  ///
  /// In en, this message translates to:
  /// **'Temperature unit updated'**
  String get tempUnitChanged;

  /// No description provided for @windSpeedUnit.
  ///
  /// In en, this message translates to:
  /// **'Wind Speed Unit'**
  String get windSpeedUnit;

  /// No description provided for @windUnitChanged.
  ///
  /// In en, this message translates to:
  /// **'Wind speed unit updated'**
  String get windUnitChanged;

  /// No description provided for @timeFormat.
  ///
  /// In en, this message translates to:
  /// **'Time Format'**
  String get timeFormat;

  /// No description provided for @time24h.
  ///
  /// In en, this message translates to:
  /// **'24-hour format'**
  String get time24h;

  /// No description provided for @time12h.
  ///
  /// In en, this message translates to:
  /// **'12-hour format'**
  String get time12h;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language updated'**
  String get languageChanged;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @useLocation.
  ///
  /// In en, this message translates to:
  /// **'Use Current Location'**
  String get useLocation;

  /// No description provided for @autoDetectLocation.
  ///
  /// In en, this message translates to:
  /// **'Auto detect location'**
  String get autoDetectLocation;

  /// No description provided for @automaticallyDetectLocation.
  ///
  /// In en, this message translates to:
  /// **'Automatically detect your location'**
  String get automaticallyDetectLocation;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @weatherNotifications.
  ///
  /// In en, this message translates to:
  /// **'Weather Notifications'**
  String get weatherNotifications;

  /// No description provided for @receiveAlerts.
  ///
  /// In en, this message translates to:
  /// **'Receive alerts'**
  String get receiveAlerts;

  /// No description provided for @receiveWeatherAlerts.
  ///
  /// In en, this message translates to:
  /// **'Receive weather alerts'**
  String get receiveWeatherAlerts;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// No description provided for @cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared'**
  String get cacheCleared;

  /// No description provided for @removeCachedWeatherData.
  ///
  /// In en, this message translates to:
  /// **'Remove cached weather data'**
  String get removeCachedWeatherData;

  /// No description provided for @clearSearchHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear Search History'**
  String get clearSearchHistory;

  /// No description provided for @historyCleared.
  ///
  /// In en, this message translates to:
  /// **'Search history cleared'**
  String get historyCleared;

  /// No description provided for @removeRecentSearches.
  ///
  /// In en, this message translates to:
  /// **'Remove recent searches'**
  String get removeRecentSearches;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @yourWeatherCompanion.
  ///
  /// In en, this message translates to:
  /// **'Your weather companion'**
  String get yourWeatherCompanion;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get units;

  /// No description provided for @wind.
  ///
  /// In en, this message translates to:
  /// **'Wind'**
  String get wind;

  /// No description provided for @humidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get humidity;

  /// No description provided for @pressure.
  ///
  /// In en, this message translates to:
  /// **'Pressure'**
  String get pressure;

  /// No description provided for @visibility.
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get visibility;

  /// No description provided for @windSpeed.
  ///
  /// In en, this message translates to:
  /// **'Wind Speed'**
  String get windSpeed;

  /// No description provided for @direction.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get direction;

  /// No description provided for @cloudiness.
  ///
  /// In en, this message translates to:
  /// **'Cloudiness'**
  String get cloudiness;

  /// No description provided for @sunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get sunrise;

  /// No description provided for @sunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get sunset;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @weatherForecast.
  ///
  /// In en, this message translates to:
  /// **'Weather Forecast'**
  String get weatherForecast;

  /// No description provided for @hourly.
  ///
  /// In en, this message translates to:
  /// **'Hourly'**
  String get hourly;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @noForecastData.
  ///
  /// In en, this message translates to:
  /// **'No forecast data available'**
  String get noForecastData;

  /// No description provided for @noWeatherData.
  ///
  /// In en, this message translates to:
  /// **'No weather data available'**
  String get noWeatherData;

  /// No description provided for @getWeather.
  ///
  /// In en, this message translates to:
  /// **'Get Weather'**
  String get getWeather;

  /// No description provided for @useCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use Current Location'**
  String get useCurrentLocation;

  /// No description provided for @searchCity.
  ///
  /// In en, this message translates to:
  /// **'Search City'**
  String get searchCity;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @locationServiceDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled. Please enable them in settings.'**
  String get locationServiceDisabled;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied.'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required to get weather for your location.'**
  String get locationPermissionRequired;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @removeCache.
  ///
  /// In en, this message translates to:
  /// **'Remove cache'**
  String get removeCache;

  /// No description provided for @removeSearchHistory.
  ///
  /// In en, this message translates to:
  /// **'Remove search history'**
  String get removeSearchHistory;

  /// No description provided for @offlineCachedData.
  ///
  /// In en, this message translates to:
  /// **'Offline - Cached Data'**
  String get offlineCachedData;

  /// No description provided for @airQuality.
  ///
  /// In en, this message translates to:
  /// **'Air Quality'**
  String get airQuality;

  /// No description provided for @airQualityIndex.
  ///
  /// In en, this message translates to:
  /// **'Air Quality Index'**
  String get airQualityIndex;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// No description provided for @weatherAlerts.
  ///
  /// In en, this message translates to:
  /// **'Weather Alerts'**
  String get weatherAlerts;

  /// No description provided for @compare.
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get compare;

  /// No description provided for @compareCities.
  ///
  /// In en, this message translates to:
  /// **'Compare Cities'**
  String get compareCities;

  /// No description provided for @maps.
  ///
  /// In en, this message translates to:
  /// **'Maps'**
  String get maps;

  /// No description provided for @weatherMaps.
  ///
  /// In en, this message translates to:
  /// **'Weather Maps'**
  String get weatherMaps;

  /// No description provided for @loadingLocationData.
  ///
  /// In en, this message translates to:
  /// **'Loading location data...'**
  String get loadingLocationData;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @failedToLoadAirQuality.
  ///
  /// In en, this message translates to:
  /// **'Failed to load air quality data'**
  String get failedToLoadAirQuality;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// No description provided for @healthRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Health Recommendation'**
  String get healthRecommendation;

  /// No description provided for @pollutantLevels.
  ///
  /// In en, this message translates to:
  /// **'Pollutant Levels (μg/m³)'**
  String get pollutantLevels;

  /// No description provided for @mainPollutant.
  ///
  /// In en, this message translates to:
  /// **'Main Pollutant'**
  String get mainPollutant;

  /// No description provided for @aqiForecast.
  ///
  /// In en, this message translates to:
  /// **'AQI Forecast'**
  String get aqiForecast;

  /// No description provided for @noActiveAlerts.
  ///
  /// In en, this message translates to:
  /// **'No Active Alerts'**
  String get noActiveAlerts;

  /// No description provided for @allClearNoWarnings.
  ///
  /// In en, this message translates to:
  /// **'All clear! No weather warnings for your area.'**
  String get allClearNoWarnings;

  /// No description provided for @activeAlerts.
  ///
  /// In en, this message translates to:
  /// **'Active Alerts'**
  String get activeAlerts;

  /// No description provided for @upcomingAlerts.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Alerts'**
  String get upcomingAlerts;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get active;

  /// No description provided for @timeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Time remaining'**
  String get timeRemaining;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'to'**
  String get to;

  /// No description provided for @selectAtLeast2Cities.
  ///
  /// In en, this message translates to:
  /// **'Select at least 2 cities to compare'**
  String get selectAtLeast2Cities;

  /// No description provided for @selectedCities.
  ///
  /// In en, this message translates to:
  /// **'Selected Cities'**
  String get selectedCities;

  /// No description provided for @maximum4Cities.
  ///
  /// In en, this message translates to:
  /// **'Maximum 4 cities can be compared'**
  String get maximum4Cities;

  /// No description provided for @quickOverview.
  ///
  /// In en, this message translates to:
  /// **'Quick Overview'**
  String get quickOverview;

  /// No description provided for @detailedComparison.
  ///
  /// In en, this message translates to:
  /// **'Detailed Comparison'**
  String get detailedComparison;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @feelsLike.
  ///
  /// In en, this message translates to:
  /// **'Feels Like'**
  String get feelsLike;

  /// No description provided for @failedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load'**
  String get failedToLoad;

  /// No description provided for @enterCityName.
  ///
  /// In en, this message translates to:
  /// **'Enter city name...'**
  String get enterCityName;

  /// No description provided for @favoriteCities.
  ///
  /// In en, this message translates to:
  /// **'Favorite Cities'**
  String get favoriteCities;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get recentSearches;

  /// No description provided for @popularCities.
  ///
  /// In en, this message translates to:
  /// **'Popular Cities'**
  String get popularCities;

  /// No description provided for @maximum5FavoriteCities.
  ///
  /// In en, this message translates to:
  /// **'Maximum 5 favorite cities allowed'**
  String get maximum5FavoriteCities;

  /// No description provided for @cloudCoverage.
  ///
  /// In en, this message translates to:
  /// **'Cloud Coverage'**
  String get cloudCoverage;

  /// No description provided for @precipitation.
  ///
  /// In en, this message translates to:
  /// **'Precipitation'**
  String get precipitation;

  /// No description provided for @overlayOpacity.
  ///
  /// In en, this message translates to:
  /// **'Overlay Opacity'**
  String get overlayOpacity;

  /// No description provided for @windEffect.
  ///
  /// In en, this message translates to:
  /// **'Wind'**
  String get windEffect;

  /// No description provided for @temperatureGlow.
  ///
  /// In en, this message translates to:
  /// **'Temperature Glow'**
  String get temperatureGlow;

  /// No description provided for @rainEffect.
  ///
  /// In en, this message translates to:
  /// **'Rain Effect'**
  String get rainEffect;

  /// No description provided for @heavy.
  ///
  /// In en, this message translates to:
  /// **'Heavy'**
  String get heavy;

  /// No description provided for @moderate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get moderate;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @cloudLayers.
  ///
  /// In en, this message translates to:
  /// **'Cloud layers'**
  String get cloudLayers;

  /// No description provided for @condition.
  ///
  /// In en, this message translates to:
  /// **'Cond'**
  String get condition;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'vi': return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
