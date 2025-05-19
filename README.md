FireGraph Smart Grocery Recommender
Overview
FireGraph Smart Grocery Recommender is an intelligent recommendation system designed to provide personalized grocery product suggestions using graph database technology. Built with Neo4j for graph-based data modeling, a Flask backend, Flutter for the cross-platform UI, and Firebase for authentication, the system leverages collaborative and category-based filtering to enhance user experience in e-commerce applications. It ensures real-time performance, scalability, and accurate recommendations.
Features

Personalized Recommendations: Utilizes graph-based algorithms (PageRank, Node Similarity) for tailored product suggestions.
Collaborative Filtering: Supports user-user and item-item recommendation techniques.
Category-Based Filtering: Recommends products based on categories.
Real-Time Performance: Efficient traversals and query optimizations for instant recommendations.
Secure Authentication: Firebase-powered user authentication and session management.
Scalable Architecture: Handles millions of relationships using Neo4j's graph database.
Cross-Platform UI: Built with Flutter for seamless mobile experiences.
Modular Design: Implements the Strategy Pattern for flexible recommendation algorithms.

Technology Stack



Layer
Technology



UI
Flutter


Authentication
Firebase


Backend
Flask API


Database
Neo4j (Graph DB)


Networking
HTTP REST APIs


System Architecture
The system follows a layered architecture:

Frontend: Flutter-based mobile app for user interaction.
Backend: Flask API handles requests and communicates with Neo4j.
Database: Neo4j stores user-product relationships (e.g., VIEWED, PURCHASED, BELONGS_TO).
Authentication: Firebase manages user sessions and security.

Installation
Prerequisites

Flutter SDK
Python 3.8+
Neo4j Desktop/Server
Firebase project setup
Node.js (for Firebase CLI, optional)
Git

Steps

Clone the Repository:
git clone https://github.com/<your-username>/firegraph-smart-grocery-recommender.git
cd firegraph-smart-grocery-recommender


Set Up the Backend (Flask):
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt


Configure Neo4j connection in config.py (update URI, username, password).
Run the Flask server:python app.py




Set Up the Frontend (Flutter):
cd frontend
flutter pub get


Configure Firebase:
Add google-services.json (Android) and GoogleService-Info.plist (iOS) from your Firebase project.
Update Firebase configuration in lib/firebase_options.dart.


Run the Flutter app:flutter run




Set Up Neo4j:

Install Neo4j Desktop or a server instance.
Create a new database and note the Bolt URI, username, and password.
Import initial data (optional, see data/import.cypher for sample Cypher queries).


Firebase Setup:

Create a Firebase project at Firebase Console.
Enable Authentication (Email/Password or other providers).
Add your Flutter app to the Firebase project and download configuration files.



Usage

Launch the App:
Run the Flutter app on a simulator/emulator or physical device.


Log In:
Use Firebase authentication to log in or sign up.


View Products:
Browse available grocery products.


Get Recommendations:
Request personalized recommendations based on your history and preferences.


View History:
Check past orders and interactions.


Admin Features (if applicable):
Manage product categories via the admin interface.



Project Structure
firegraph-smart-grocery-recommender/
├── backend/                  # Flask API and Neo4j integration
│   ├── app.py                # Main Flask application
│   ├── config.py             # Configuration (Neo4j, Firebase)
│   ├── requirements.txt      # Python dependencies
│   └── ...
├── frontend/                 # Flutter mobile app
│   ├── lib/                  # Dart source code
│   ├── pubspec.yaml          # Flutter dependencies
│   └── ...
├── data/                     # Sample data and Cypher queries
│   ├── import.cypher         # Neo4j data import queries
│   └── ...
├── docs/                     # Project documentation
│   ├── Project_Report.pdf    # Full project report
│   └── ...
└── README.md                 # This file

Neo4j Graph Model

Nodes:
User: Properties like userID, name, email.
Product: Properties like productID, name, price.
Category: Properties like categoryID, name.


Relationships:
VIEWED: User viewed a product (with timestamp).
PURCHASED: User bought a product (with timestamp, quantity).
BELONGS_TO: Product belongs to a category.
SIMILAR_TO: Product similarity based on attributes or user behavior.



Contributing
Contributions are welcome! Please follow these steps:

Fork the repository.
Create a new branch (git checkout -b feature/your-feature).
Commit your changes (git commit -m "Add your feature").
Push to the branch (git push origin feature/your-feature).
Open a Pull Request.

License
This project is licensed under the MIT License. See the LICENSE file for details.
Acknowledgments

Group Members:
Muhammad Arslan Jameel (2022-CS-816)
Raheel Anjum (2022-CS-810)


Supervisor: Sir Talha
Institution: University of Engineering and Technology, Lahore (Faisalabad Campus)
Session: 2022-2026

References

Neo4j Official Documentation
Flutter Framework
Flask Documentation
Firebase Documentation
Design Patterns - Gamma et al.
Recommender Systems Handbook (Springer, 2011)
Cypher Query Language Reference

