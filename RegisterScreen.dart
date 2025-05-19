import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../screens/DashboardScreen.dart';
import 'LoginScreen.dart';
import '../services/cart_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final addressController = TextEditingController();
  final ageController = TextEditingController();
  String? gender;
  String error = "";
  bool isLoading = false;

  final List<String> genders = ['Male', 'Female', 'Other'];
  final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    addressController.dispose();
    ageController.dispose();
    super.dispose();
  }

  void registerUser() async {
    FocusScope.of(context).unfocus();

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirm = confirmController.text.trim();
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final address = addressController.text.trim();
    final ageText = ageController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || address.isEmpty || ageText.isEmpty || gender == null) {
      setState(() => error = "All fields are required.");
      return;
    }

    if (!emailRegex.hasMatch(email)) {
      setState(() => error = "Invalid email format.");
      return;
    }

    if (password.length < 6) {
      setState(() => error = "Password should be at least 6 characters.");
      return;
    }

    if (password != confirm) {
      setState(() => error = "Passwords do not match.");
      return;
    }

    int? age = int.tryParse(ageText);
    if (age == null || age < 0 || age > 150) {
      setState(() => error = "Please enter a valid age.");
      return;
    }

    setState(() {
      isLoading = true;
      error = "";
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'address': address,
        'age': age,
        'gender': gender,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final cartService = CartService(userCredential.user!.uid);
      await cartService.addToCart({
        'category': 'Fruit',
        'id': 1,
        'name': 'apple',
        'price': 300.0,
        'quantity': 2,
      });

      try {
        final response = await http.post(
          Uri.parse('https://grocerybackendapi.vercel.app/create-user'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'userId': userCredential.user!.uid,
            'name': '$firstName $lastName',
            'email': email,
          }),
        );

        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        if (response.statusCode != 201) {
          print('Warning: Failed to create user node in Neo4j, but continuing registration');
        }
      } catch (apiError) {
        print('Error calling API: $apiError');
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DashboardScreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = _getErrorMessage(e);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = "Registration failed: $e";
        isLoading = false;
      });
    }
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Registration failed: ${e.message}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double paddingHorizontal = screenWidth > 600 ? 40.0 : screenWidth * 0.04;
    final double paddingVertical = screenHeight > 800 ? 20.0 : screenHeight * 0.02;
    final double iconSize = screenWidth > 600 ? 50.0 : screenWidth * 0.12;
    final double fontSizeTitle = (screenWidth * 0.07).clamp(24, 36);
    final double fontSizeText = (screenWidth * 0.035).clamp(14, 18);
    final double buttonHeight = screenHeight > 800 ? 60.0 : screenHeight * 0.07;

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                padding: EdgeInsets.symmetric(
                  horizontal: paddingHorizontal,
                  vertical: paddingVertical,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_add_alt, size: iconSize, color: Colors.white),
                    SizedBox(height: paddingVertical),
                    Text(
                      "REGISTER",
                      style: TextStyle(
                        fontSize: fontSizeTitle,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: paddingVertical * 1.5),
                    Container(
                      padding: EdgeInsets.all(paddingHorizontal),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildTextField(
                            firstNameController,
                            Icons.person,
                            "First Name",
                            fontSize: fontSizeText,
                          ),
                          SizedBox(height: paddingVertical),
                          _buildTextField(
                            lastNameController,
                            Icons.person,
                            "Last Name",
                            fontSize: fontSizeText,
                          ),
                          SizedBox(height: paddingVertical),
                          _buildTextField(
                            emailController,
                            Icons.email,
                            "Email",
                            fontSize: fontSizeText,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(height: paddingVertical),
                          _buildTextField(
                            addressController,
                            Icons.home,
                            "Address",
                            fontSize: fontSizeText,
                          ),
                          SizedBox(height: paddingVertical),
                          _buildTextField(
                            ageController,
                            Icons.cake,
                            "Age",
                            fontSize: fontSizeText,
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: paddingVertical),
                          _buildGenderDropdown(fontSize: fontSizeText),
                          SizedBox(height: paddingVertical),
                          _buildTextField(
                            passwordController,
                            Icons.lock,
                            "Password",
                            fontSize: fontSizeText,
                            isPassword: true,
                          ),
                          SizedBox(height: paddingVertical),
                          _buildTextField(
                            confirmController,
                            Icons.lock_outline,
                            "Confirm Password",
                            fontSize: fontSizeText,
                            isPassword: true,
                          ),
                          SizedBox(height: paddingVertical * 1.5),
                          _buildRegisterButton(height: buttonHeight, fontSize: fontSizeText),
                          if (error.isNotEmpty) _buildErrorMessage(fontSize: fontSizeText),
                          _buildLoginRow(fontSize: fontSizeText),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      IconData icon,
      String hintText, {
        required double fontSize,
        bool isPassword = false,
        TextInputType keyboardType = TextInputType.text,
      }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.white, fontSize: fontSize),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white70, size: fontSize * 1.5),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white54, fontSize: fontSize),
        filled: true,
        fillColor: Colors.white10,
        contentPadding: EdgeInsets.symmetric(vertical: fontSize * 0.8, horizontal: fontSize),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.cyanAccent, width: 1),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown({required double fontSize}) {
    return DropdownButtonFormField<String>(
      value: gender,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.person_outline, color: Colors.white70, size: fontSize * 1.5),
        hintText: "Select Gender",
        hintStyle: TextStyle(color: Colors.white54, fontSize: fontSize),
        filled: true,
        fillColor: Colors.white10,
        contentPadding: EdgeInsets.symmetric(vertical: fontSize * 0.8, horizontal: fontSize),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.cyanAccent, width: 1),
        ),
      ),
      dropdownColor: const Color(0xFF2c5364),
      style: TextStyle(color: Colors.white, fontSize: fontSize),
      icon: Icon(Icons.arrow_drop_down, color: Colors.white70, size: fontSize * 1.5),
      isExpanded: true,
      items: genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
      onChanged: (value) => setState(() => gender = value),
      hint: Text("Select Gender", style: TextStyle(color: Colors.white54, fontSize: fontSize)),
    );
  }

  Widget _buildRegisterButton({required double height, required double fontSize}) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: registerUser,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.greenAccent,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Text(
          "REGISTER",
          style: TextStyle(fontSize: fontSize * 1.1, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildErrorMessage({required double fontSize}) {
    return Padding(
      padding: EdgeInsets.only(top: fontSize),
      child: Container(
        padding: EdgeInsets.all(fontSize * 0.8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          error,
          style: TextStyle(color: Colors.red, fontSize: fontSize),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildLoginRow({required double fontSize}) {
    return Padding(
      padding: EdgeInsets.only(top: fontSize),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Already have an account? ",
            style: TextStyle(color: Colors.white70, fontSize: fontSize),
          ),
          GestureDetector(
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
            child: Text(
              "Login",
              style: TextStyle(
                color: Colors.cyanAccent,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}