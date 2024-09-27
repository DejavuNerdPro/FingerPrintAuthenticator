import 'package:finger_print_auth/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class FingerprintCheckPage extends StatefulWidget {
  const FingerprintCheckPage({super.key});

  @override
  State<FingerprintCheckPage> createState() => _FingerprintCheckPageState();
}

class _FingerprintCheckPageState extends State<FingerprintCheckPage> {
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  bool _canCheckBiometrics = false;
  List<BiometricType> _availableBiometrics = [];
  bool _fingerprintAvailable = false;
  bool _didAuthenticate=false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    // Check if biometric authentication is available
    bool canCheckBiometrics = await _localAuthentication.canCheckBiometrics;

    // Get a list of biometric types (fingerprint, face, iris)
    List<BiometricType> availableBiometrics = await _localAuthentication.getAvailableBiometrics();

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
      _availableBiometrics = availableBiometrics;

      // Check if fingerprint is available
      _fingerprintAvailable = _availableBiometrics.contains(BiometricType.fingerprint);
    });
  }

  Future<void> _authenticate() async {
  bool didAuthenticate = false;

  try {
    didAuthenticate = await _localAuthentication.authenticate(
      localizedReason: 'Please authenticate to access this feature',
      options: const AuthenticationOptions(biometricOnly: true),
    );
    setState(() {
      _didAuthenticate=didAuthenticate;
    });
  } catch (e) {
    print(e);
  }

  if (_didAuthenticate) {
    print('User successfully authenticated.');
    // ignore: use_build_context_synchronously
    Navigator.push(context,
                            MaterialPageRoute(builder: (context) => WelcomePage()),
                            );
  } else {
    print('Authentication failed.');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Can check biometrics: $_canCheckBiometrics'),
            Text('Available biometrics: $_availableBiometrics'),
            const SizedBox(height: 20),
            if (!_fingerprintAvailable)
              ElevatedButton(
                onPressed: () {
                  // Show dialog guiding users to system settings to register fingerprints
                  _authenticate();
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('No Fingerprint Found.'),
                      content: const Text(
                          'It seems like you haven\'t registered any fingerprints. Please go to your device\'s settings to add one.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Register Fingerprint'),
              ),
          ],
        ),
      ),
    );
  }
}
