import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import 'RegisterScreen.dart';
import '../screens/DashboardScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool rememberMe = false;
  String error = "";
  bool isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email');
    final savedPassword = prefs.getString('password');
    final savedRememberMe = prefs.getBool('rememberMe') ?? false;

    if (savedRememberMe && savedEmail != null && savedPassword != null) {
      emailController.text = savedEmail;
      passwordController.text = savedPassword;
      setState(() {
        rememberMe = true;
      });
    }
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setString('email', emailController.text.trim());
      await prefs.setString('password', passwordController.text.trim());
      await prefs.setBool('rememberMe', true);
    } else {
      await prefs.remove('email');
      await prefs.remove('password');
      await prefs.setBool('rememberMe', false);
    }
  }

  Future<void> loginUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        error = "Please enter both email and password.";
      });
      return;
    }

    setState(() {
      isLoading = true;
      error = "";
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _saveCredentials();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = _getErrorMessage(e);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = "Unexpected error occurred. Please try again.";
        isLoading = false;
      });
    }
  }

  Future<void> signInWithGoogle() async {
    setState(() {
      isLoading = true;
      error = "";
    });

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() {
          isLoading = false;
          error = "Google Sign-In canceled.";
        });
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = _getGoogleErrorMessage(e);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = _getPlatformErrorMessage(e);
        isLoading = false;
      });
    }
  }

  Future<void> resetPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        error = "Please enter your email to reset password.";
      });
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() {
        error = "Please enter a valid email address.";
      });
      return;
    }

    setState(() {
      isLoading = true;
      error = "";
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Password reset link sent! Check your email.',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      setState(() {
        isLoading = false;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = _getResetErrorMessage(e);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = "Failed to send reset email. Please try again.";
        isLoading = false;
      });
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many login attempts. Try again later.';
      default:
        return 'Login failed. Please try again.';
    }
  }

  String _getGoogleErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email but different sign-in method.';
      case 'invalid-credential':
        return 'Invalid Google credentials. Please try again.';
      case 'user-disabled':
        return 'This Google account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      default:
        return 'Google Sign-In failed. Please try again.';
    }
  }

  String _getResetErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email format.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      default:
        return 'Failed to send reset email. Please try again.';
    }
  }

  String _getPlatformErrorMessage(dynamic e) {
    if (e.toString().contains('Google Play Services')) {
      return 'Google Play Services is not available. Please check your device.';
    } else if (e.toString().contains('network')) {
      return 'Network error. Please check your internet connection.';
    } else {
      return 'Failed to sign in with Google. Please try again.';
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double paddingHorizontal = screenWidth > 600 ? 40.0 : screenWidth * 0.06;
    final double iconSize = screenWidth > 600 ? 60.0 : screenWidth * 0.15;
    final double fontSizeTitle = (screenWidth * 0.07).clamp(24, 36);
    final double fontSizeText = (screenWidth * 0.035).clamp(14, 18);
    final double buttonHeight = screenHeight > 800 ? 60.0 : screenHeight * 0.07;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f2027), Color(0xFF203a43), Color(0xFF2c5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: screenHeight * 0.08),
                        Icon(
                          Icons.lock,
                          size: iconSize,
                          color: Colors.white,
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        Text(
                          "LOGIN",
                          style: GoogleFonts.poppins(
                            fontSize: fontSizeTitle,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.05),
                        _buildTextField(
                          controller: emailController,
                          icon: Icons.email,
                          hintText: "Email",
                          keyboardType: TextInputType.emailAddress,
                          fontSize: fontSizeText,
                        ),
                        SizedBox(height: screenHeight * 0.025),
                        _buildPasswordField(fontSize: fontSizeText),
                        SizedBox(height: screenHeight * 0.01),
                        _buildRememberMeAndForgotPassword(fontSize: fontSizeText),
                        SizedBox(height: screenHeight * 0.04),
                        _buildLoginButton(height: buttonHeight, fontSize: fontSizeText),
                        SizedBox(height: screenHeight * 0.025),
                        _buildGoogleSignInButton(height: buttonHeight, fontSize: fontSizeText),
                        SizedBox(height: screenHeight * 0.04),
                        _buildRegisterLink(fontSize: fontSizeText),
                        if (error.isNotEmpty) _buildErrorMessage(fontSize: fontSizeText),
                        SizedBox(height: screenHeight * 0.025),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    required double fontSize,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      style: GoogleFonts.poppins(color: Colors.white, fontSize: fontSize),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white70, size: fontSize * 1.5),
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(color: Colors.white60, fontSize: fontSize),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.cyanAccent, width: 1),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: fontSize * 0.8, horizontal: fontSize),
      ),
    );
  }

  Widget _buildPasswordField({required double fontSize}) {
    return TextField(
      controller: passwordController,
      obscureText: _obscurePassword,
      style: GoogleFonts.poppins(color: Colors.white, fontSize: fontSize),
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock, color: Colors.white70, size: fontSize * 1.5),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.white70,
            size: fontSize * 1.5,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        hintText: "Password",
        hintStyle: GoogleFonts.poppins(color: Colors.white60, fontSize: fontSize),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.cyanAccent, width: 1),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: fontSize * 0.8, horizontal: fontSize),
      ),
    );
  }

  Widget _buildRememberMeAndForgotPassword({required double fontSize}) {
    return Row(
      children: [
        SizedBox(
          height: fontSize * 1.5,
          width: fontSize * 1.5,
          child: Checkbox(
            value: rememberMe,
            onChanged: (value) {
              setState(() {
                rememberMe = value ?? false;
              });
            },
            activeColor: Colors.cyanAccent,
            checkColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        SizedBox(width: fontSize * 0.5),
        Text(
          "Remember Me",
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: fontSize,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: resetPassword,
          child: Text(
            "Forgot Password?",
            style: GoogleFonts.poppins(
              color: Colors.cyanAccent,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton({required double height, required double fontSize}) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : loginUser,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.tealAccent,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          disabledBackgroundColor: Colors.tealAccent.withOpacity(0.6),
        ),
        child: isLoading
            ? SizedBox(
          height: fontSize * 1.5,
          width: fontSize * 1.5,
          child: const CircularProgressIndicator(
            color: Colors.black,
            strokeWidth: 2,
          ),
        )
            : Text(
          "LOGIN",
          style: GoogleFonts.poppins(
            fontSize: fontSize * 1.1,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleSignInButton({required double height, required double fontSize}) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : signInWithGoogle,
        icon: Image.asset(
          'assets/google_logo.png',
          height: fontSize * 1.5,
        ),
        label: Text(
          "Sign in with Google",
          style: GoogleFonts.poppins(
            fontSize: fontSize * 1.1,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          disabledBackgroundColor: Colors.white.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildRegisterLink({required double fontSize}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: fontSize,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RegisterScreen()),
            );
          },
          child: Text(
            "Register",
            style: GoogleFonts.poppins(
              color: Colors.cyanAccent,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage({required double fontSize}) {
    return Padding(
      padding: EdgeInsets.only(top: fontSize),
      child: Text(
        error,
        style: GoogleFonts.poppins(
          color: Colors.redAccent,
          fontSize: fontSize,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}