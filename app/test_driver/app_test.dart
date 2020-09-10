import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

///Must await this function. Used to create delay between UI actions
Future<void> delay([int milliseconds = 250]) async {
  await Future<void>.delayed(Duration(milliseconds: milliseconds));
}

/// Fill out the form with the necessary information for a finesse
/// Parameters to require the name and location.
/// Optional parameters for location duration and picture taking
Future<void> addEvent(FlutterDriver driver, nameText, locationText,
    {String descriptionText = "Integration Test Description",
    String durationText = "Integration Test Duration",
    bool takePic: false,
    bool uploadPic: false}) async {
  nameText = "Integration Test " + nameText;
  await driver.tap(find.byValueKey('add event'));

  await driver.tap(find.byValueKey('name'));
  await driver.enterText(nameText);
  await driver.waitFor(find.text(nameText));

  await driver.tap(find.byValueKey('location'));
  await driver.enterText(locationText);
  await driver.waitFor(find.text(locationText));

  await driver.tap(find.byValueKey('description'));
  await driver.enterText(descriptionText);
  await driver.waitFor(find.text(descriptionText));

  await driver.tap(find.byValueKey('duration'));
  await driver.enterText(durationText);
  await driver.waitFor(find.text(durationText));
  if (takePic) {
    await driver.tap(find.byValueKey('Upload'));

    await driver.waitFor(find.text("Upload Image From Camera"));

    await driver.tap(find.text("OK"));
  }
  await delay(200);
  if (uploadPic) {
    await driver.tap(find.byValueKey('Upload'));

    await driver.waitFor(find.text("Upload Image From Gallery"));

    await driver.tap(find.text("OK"));
  }

  await driver.tap(find.byValueKey('submit'));
  if (locationText != '') {
    await delay(1000);
    await driver.waitFor(find.text("now"));
  }
}

/// Login a user by entering a username and password
/// Signup parameter to specify if the user should be signed up instead.
Future<void> login(FlutterDriver driver,
    {email: 'test@test.com', password: 'test123', signUp: false}) async {
  await driver.tap(find.byValueKey('emailField'));
  await driver.enterText(email);
  await driver.tap(find.byValueKey("passwordField"));
  await driver.enterText(password);
  if (signUp) {
    await driver.tap(find.byValueKey('switchButton'));
    await driver.tap(find.byValueKey("confirmField"));
    await driver.enterText(password);
  }
  await driver.tap(find.byValueKey("loginButton"));
}

/// Goes to the settings menu and logs out the user
Future<void> logout(FlutterDriver driver) async {
  await gotoSettings(driver);
  await driver.tap(find.byValueKey("logoutButton"));
}

/// Opens up the settings menu from the home page
Future gotoSettings(FlutterDriver driver) async {
  await driver.tap(find.byValueKey("dropdownButton"));
  await driver.tap(find.byValueKey("settingsButton"));
}

/// Marks a post as inactive on the finesse page
Future<void> markAsEnded(FlutterDriver driver, String locationText) async {
  await driver.tap(find.text(locationText));
  await driver.tap(find.byValueKey("threeDotButton"));
  await driver.tap(find.byValueKey("markAsEndedButton"));
  await driver.tap(find.pageBack());
}

///Generate a unique string for location based on the timestamp
String generateUniqueLocationText() {
  var now = DateTime.now();
  String locationText = 'Location: ' + now.toString();
  return locationText;
}

void main() {
  group('Login:', () {
    FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });
    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    ///Login a user
    test('Successful login', () async {
      await login(driver);
      await logout(driver);
    });

    ///Register a user
    test('Successful registration', () async {
      String uniqueEmail =
          DateTime.now().millisecondsSinceEpoch.toString() + '@test.com';
      await login(driver, email: uniqueEmail, signUp: true);
      await logout(driver);
      await login(driver, email: uniqueEmail);
      await logout(driver);
    });

    ///Check for missing information
    test('Missing information', () async {
      String badEmail = "Email can't be empty",
          badPass = "Password must be at least 6 characters";

      await login(driver, email: '', password: '');
      await driver.getText(find.text(badEmail));
      await driver.getText(find.text(badPass));
    });

    ///Try logging in with an invalid email
    test('Invalid email', () async {
      String errorText = "Invalid email address";

      await login(driver, email: 'invalidemail.com');
      await driver.getText(find.text(errorText));
    });
  });

  group('Add Event:', () {
    FlutterDriver driver;
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });
    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    /// Tries to add an event but should be stopped by a form validation.
    test('Add event form fail test', () async {
      await login(driver);
      String testName = 'Add event form fail test';
      String locationText = '';

      await addEvent(driver, testName, locationText);

      expect(await driver.getText(find.text("Please enter a location")),
          "Please enter a location");

      await driver.tap(find.byTooltip('Back'));
    });

    /// This Test only checks if the gallery button is there.
    /// Currently flutter drive is not able to have control over the interface outside our app.
    test('Add Event with Gallery Image Test', () async {
      String nameText = 'Integration Test Image from Gallery';
      String locationText = generateUniqueLocationText();

      await addEvent(driver, nameText, locationText, uploadPic: true);
      await delay(1000);

      expect(await driver.getText(find.text(locationText)), locationText);
      await delay(1000);
      await markAsEnded(driver, locationText);
    });

    /// Add a finesse through the normal entry methods.
    test('Add a finesse', () async {
      String testName = 'Add a finesse';
      String locationText = generateUniqueLocationText();

      await addEvent(driver, testName, locationText);

      expect(await driver.getText(find.text(locationText)), locationText);
      await delay(1000);
      await markAsEnded(driver, locationText);
    });
  });

  group('Filters:', () {
    FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    /// Switch the filter button
    test('Filter active', () async {
      await driver.tap(find.byValueKey("Filter"));
      await driver.tap(find.byValueKey("activeFilter"));
      await driver.tap(find.byValueKey("FilterOK"));
    });

    /// Switch the filter button
    test('Filter Other', () async {
      await driver.tap(find.byValueKey("Filter"));
      await driver.tap(find.byValueKey("typeFilter"));
      await driver.tap(find.byValueKey("FilterOK"));
    });
  });

  group('Settings Page:', () {
    FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    /// Go to the settings page and toggle the notifications.
    test('Settings Page ', () async {
      // Build our app and trigger a frame.
      await gotoSettings(driver);
      await driver.tap(find.byValueKey("Notification Toggle"));
      await driver.tap(find.pageBack());
      await gotoSettings(driver);
      await driver.tap(find.byValueKey("Notification Toggle"));
      await driver.tap(find.pageBack());
    });
  });

  group('Finesse Page:', () {
    FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    ///Check that when a finesse is clicked on, the proper information is displayed
    test('View finesse info', () async {
      // Build our app and trigger a frame.
      String testName = 'View finesse info';
      String locationText = generateUniqueLocationText();

      await addEvent(driver, testName, locationText);

      await driver.tap(find.text(locationText));
      await delay(1000);
      await driver.getText(find.text(locationText));
      await driver.tap(find.pageBack());
      await delay(5000);
      await markAsEnded(driver, locationText);
    });
  });

  /// Mark an event as inactive
  group('Mark as Inactive:', () {
    FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    /// Simple adding an event through the form and marking it inactive
    test('Add event then mark as expired', () async {
      String testName = 'Add event then mark as expired';
      String locationText = generateUniqueLocationText();
      await addEvent(driver, testName, locationText);
      await markAsEnded(driver, locationText);
    });
  });

  group('Maps Link:', () {
    FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    /// Click on the google maps link and google maps will open up.
    test('View Map Test', () async {
      // Build our app and trigger a frame.
      var now = DateTime.now();
      String nameText = 'Maps Test ${now.toString()}';
      String locationText = 'Siebel Center';
      await addEvent(driver, nameText, locationText);
      await driver.tap(find.text('Integration Test ' + nameText));
      await delay(1000);
      await driver.tap(find.byValueKey("threeDotButton"));
      await delay(1000);
      await driver.tap(find.byValueKey("markAsEndedButton"));
      await delay(1000);
      await driver.tap(find.text(locationText));
      await delay(1000);
      await driver.tap(find.text(locationText));
      await delay(1000);
    });
  });
}
