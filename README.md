FireGraph Smart Grocery Recommender

📑 Table of Contents

Project Overview
Features
Technology Stack
System Architecture
Installation
Usage
Project Structure
Graph Model
Contributing
License
Acknowledgments
References

📖 Project Overview
FireGraph Smart Grocery Recommender is an advanced recommendation system designed to deliver personalized grocery product suggestions using graph database technology. Powered by Neo4j for graph-based data modeling, Flask for backend services, Flutter for a cross-platform user interface, and Firebase for secure authentication, the system combines collaborative and category-based filtering to provide accurate, real-time recommendations. This project is ideal for e-commerce platforms seeking scalable and user-centric solutions.
Developed as part of a university project at the University of Engineering and Technology, Lahore (Faisalabad Campus), it showcases modern software engineering principles and graph-based algorithms.
✨ Features

Personalized Recommendations: Leverages graph-based algorithms (PageRank, Node Similarity) for tailored suggestions.
Collaborative Filtering: Supports user-user and item-item recommendation techniques.
Category-Based Filtering: Recommends products based on predefined categories.
Real-Time Performance: Optimized queries and traversals for instant recommendations.
Secure Authentication: Firebase-powered user login and session management.
Scalable Architecture: Neo4j efficiently handles millions of relationships.
Cross-Platform UI: Flutter ensures a seamless experience on iOS and Android.
Modular Design: Uses the Strategy Pattern for flexible algorithm switching.

🛠 Technology Stack



Layer
Technology



Frontend
Flutter


Authentication
Firebase


Backend
Flask API


Database
Neo4j (Graph DB)


Networking
HTTP REST APIs


🏗 System Architecture
The system follows a modular, layered architecture:

Frontend: Flutter-based mobile app for user interactions (view products, get recommendations).
Backend: Flask API processes requests and interfaces with Neo4j.
Database: Neo4j stores user-product relationships (e.g., VIEWED, PURCHASED, BELONGS_TO).
Authentication: Firebase ensures secure user management.

 
🚀 Installation
Prerequisites

Flutter SDK (>=3.0.0)
Python (>=3.8)
Neo4j Desktop or Server (>=5.0)
Firebase project setup
Node.js (>=16.0, for Firebase CLI)
Git

Setup Instructions

Clone the Repository:
git clone https://github.com/<your-username>/firegraph-smart-grocery-recommender.git
cd firegraph-smart-grocery-recommender


Backend Setup (Flask):
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt


Update Neo4j credentials in backend/config.py (URI, username, password).
Start the Flask server:python app.py




Frontend Setup (Flutter):
cd frontend
flutter pub get


Configure Firebase:
Download google-services.json (Android) and GoogleService-Info.plist (iOS) from Firebase Console.
Place them in frontend/android/app and frontend/ios/Runner, respectively.
Update lib/firebase_options.dart with Firebase configuration.


Run the app:flutter run




Neo4j Setup:

Install Neo4j Desktop or a server instance.
Create a database and note the Bolt URI, username, and password.
Import sample data (optional):// Run in Neo4j Browser
:source data/import.cypher




Firebase Configuration:

Create a project in Firebase Console.
Enable Authentication (Email/Password or other providers).
Register your Flutter app in Firebase and add configuration files.



📲 Usage

Launch the App:
Run the Flutter app on an emulator or physical device.


Sign In:
Log in or register using Firebase authentication.


Explore Products:
Browse available grocery products.


Receive Recommendations:
Request personalized suggestions based on your history and preferences.


View History:
Access past orders and interactions.


Admin Features (if implemented):
Manage product categories through the admin interface.



📂 Project Structure
firegraph-smart-grocery-recommender/
├── backend/                  # Flask API and Neo4j integration
│   ├── app.py                # Main Flask application
│   ├── config.py             # Neo4j and Firebase configuration
│   ├── requirements.txt      # Python dependencies
│   └── routes/               # API endpoints
├── frontend/                 # Flutter mobile app
│   ├── lib/                  # Dart source code
│   ├── pubspec.yaml          # Flutter dependencies
│   └── assets/               # Images and resources
├── data/                     # Sample data and Cypher queries
│   ├── import.cypher         # Neo4j data import scripts
│   └── ...
├── docs/                     # Documentation
│   ├── Project_Report.pdf    # Full project report
│   └── architecture_diagram.png  # System architecture diagram
└── README.md                 # Project README

🌐 Graph Model
The Neo4j graph database is central to the recommendation system:

Nodes:
User: Properties (userID, name, email).
Product: Properties (productID, name, price, category).
Category: Properties (categoryID, name).


Relationships:
VIEWED: User viewed a product (timestamp).
PURCHASED: User bought a product (timestamp, quantity).
BELONGS_TO: Product belongs to a category.
SIMILAR_TO: Product similarity based on attributes or behavior.


Cypher Queries:
Find similar users for collaborative filtering.
Recommend products based on connected nodes.


Optimizations:
Node indexing for faster queries.
Caching frequent queries.
Limiting relationship depth for performance.



🤝 Contributing
We welcome contributions to enhance FireGraph! To contribute:

Fork the repository.
Create a feature branch:git checkout -b feature/your-feature


Commit your changes:git commit -m "Add your feature"


Push to the branch:git push origin feature/your-feature


Open a Pull Request with a clear description of your changes.

Please follow the Code of Conduct and ensure your code adheres to the project's style guidelines.
📜 License
This project is licensed under the MIT License. See the LICENSE file for details.
🙏 Acknowledgments

Team Members:
Muhammad Arslan Jameel (2022-CS-816)
Raheel Anjum (2022-CS-810)


Supervisor: Sir Talha
Institution: University of Engineering and Technology, Lahore (Faisalabad Campus)
Session: 2022-2026

📚 References

Neo4j Official Documentation
Flutter Framework
Flask Documentation
Firebase Documentation
Gamma, E., et al. Design Patterns: Elements of Reusable Object-Oriented Software
Ricci, F., et al. Recommender Systems Handbook (Springer, 2011)
Cypher Query Language Reference


