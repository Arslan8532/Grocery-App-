# 🛒 FireGraph Smart Grocery Recommender

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev/)
[![Neo4j](https://img.shields.io/badge/Neo4j-5.0+-green.svg)](https://neo4j.com/)
[![Firebase](https://img.shields.io/badge/Firebase-Auth-orange.svg)](https://firebase.google.com/)

---

## 📑 Table of Contents

- [Project Overview](#project-overview)
- [Features](#features)
- [Technology Stack](#technology-stack)
- [System Architecture](#system-architecture)
- [Installation](#installation)
- [Usage](#usage)
- [Graph Model](#graph-model)
- [Project Structure](#project-structure)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgments](#acknowledgments)
- [References](#references)

---

## 📖 Project Overview

**FireGraph Smart Grocery Recommender** is an intelligent grocery recommendation system powered by **graph-based algorithms** and built with modern, scalable technologies. It offers personalized product suggestions using **Neo4j**, **Flask**, **Flutter**, and **Firebase**.

Developed as a final year project at **University of Engineering and Technology, Lahore (Faisalabad Campus)**, the system demonstrates the power of real-time recommendation engines for e-commerce platforms.

---

## ✨ Features

- 🔍 **Personalized Recommendations** using PageRank and Node Similarity
- 👥 **Collaborative Filtering** (User-User, Item-Item)
- 🧠 **Category-Based Filtering** for refined suggestions
- ⚡ **Real-Time Performance** with optimized Cypher queries
- 🔐 **Secure Authentication** via Firebase
- 🧩 **Scalable Graph Structure** with millions of nodes/relationships
- 📱 **Cross-Platform App** with Flutter (iOS/Android)
- 🧠 **Strategy Pattern** to switch between recommendation techniques

---

## 🛠 Technology Stack

| Layer             | Technology         |
|------------------|--------------------|
| **Frontend**      | Flutter            |
| **Backend**       | Flask (Python)     |
| **Database**      | Neo4j (Graph DB)   |
| **Authentication**| Firebase           |
| **Networking**    | HTTP REST APIs     |

---

## 🏗 System Architecture

+---------------------+
| Flutter App |
+---------------------+
|
v
+---------------------+
| Flask API |
+---------------------+
| |
v v
+--------+ +------------+
| Firebase| | Neo4j |
+--------+ +------------+

markdown
Copy
Edit

- **Frontend**: Built with Flutter for both Android and iOS.
- **Backend**: Flask-based REST API communicates with Firebase and Neo4j.
- **Database**: Neo4j stores user-product interactions and relationships.
- **Authentication**: Firebase handles sign-in, sign-up, and session tokens.

---

## 🚀 Installation

### ✅ Prerequisites

- Flutter SDK (>=3.0.0)
- Python (>=3.8)
- Node.js (>=16.0)
- Neo4j Desktop or Server (>=5.0)
- Firebase Project
- Git

### 🔧 Setup Instructions

#### 1. Clone the Repository

```bash
git clone https://github.com/<your-username>/firegraph-smart-grocery-recommender.git
cd firegraph-smart-grocery-recommender
2. Backend Setup (Flask)
bash
Copy
Edit
cd backend
python -m venv venv
# Activate virtual environment:
# macOS/Linux:
source venv/bin/activate
# Windows:
venv\Scripts\activate

pip install -r requirements.txt
Update your Neo4j config in backend/config.py:

python
Copy
Edit
NEO4J_URI = "bolt://localhost:7687"
NEO4J_USER = "neo4j"
NEO4J_PASSWORD = "your_password"
Start the Flask server:

bash
Copy
Edit
python app.py
3. Frontend Setup (Flutter)
bash
Copy
Edit
cd ../frontend
flutter pub get
Set up Firebase:

Download google-services.json (Android) and GoogleService-Info.plist (iOS) from Firebase Console

Place in:

android/app/google-services.json

ios/Runner/GoogleService-Info.plist

Update Firebase options in:

dart
Copy
Edit
lib/firebase_options.dart
Run the app:

bash
Copy
Edit
flutter run
4. Neo4j Setup
Install Neo4j Desktop or use a Neo4j server

Create a database

Note the Bolt URI, username, and password

Import sample data (optional):

cypher
Copy
Edit
:source data/import.cypher
5. Firebase Setup
Go to Firebase Console

Create a new project

Enable Authentication (Email/Password)

Register your Android/iOS app

Download and place config files into respective frontend folders

📲 Usage
Launch the Flutter app

Register or log in with Firebase

Browse grocery products

View tailored recommendations based on your behavior

Track your interaction history (viewed/purchased)

(Optional) Admin panel for managing product categories

🌐 Graph Model
🧩 Nodes
User: { userID, name, email }

Product: { productID, name, price, category }

Category: { categoryID, name }

🔗 Relationships
VIEWED: (User)-[:VIEWED {timestamp}]->(Product)

PURCHASED: (User)-[:PURCHASED {timestamp, quantity}]->(Product)

BELONGS_TO: (Product)-[:BELONGS_TO]->(Category)

SIMILAR_TO: (Product)-[:SIMILAR_TO]->(Product)

🚀 Cypher Examples
Find similar users:

cypher
Copy
Edit
MATCH (u1:User)-[:VIEWED]->(p:Product)<-[:VIEWED]-(u2:User)
WHERE u1.userID = 'user123' AND u1 <> u2
RETURN u2, COUNT(*) AS similarity
ORDER BY similarity DESC
Recommend products:

cypher
Copy
Edit
MATCH (u:User)-[:VIEWED]->(p1:Product)-[:SIMILAR_TO]->(p2:Product)
WHERE u.userID = 'user123'
RETURN DISTINCT p2
LIMIT 10
📂 Project Structure
arduino
Copy
Edit
firegraph-smart-grocery-recommender/
├── backend/
│   ├── app.py
│   ├── config.py
│   ├── requirements.txt
│   └── routes/
├── frontend/
│   ├── lib/
│   ├── pubspec.yaml
│   └── assets/
├── data/
│   ├── import.cypher
├── docs/
│   ├── Project_Report.pdf
│   └── architecture_diagram.png
└── README.md
🤝 Contributing
We welcome contributions from the community!

How to Contribute
Fork the repository

Create a new branch:

bash
Copy
Edit
git checkout -b feature/your-feature
Commit your changes:

bash
Copy
Edit
git commit -m "Add your feature"
Push to your branch:

bash
Copy
Edit
git push origin feature/your-feature
Open a Pull Request on GitHub

Please follow the Code of Conduct and maintain consistent code style.

📜 License
This project is licensed under the MIT License.

🙏 Acknowledgments
👨‍💻 Team Members:

Muhammad Arslan Jameel (2022-CS-816)

Raheel Anjum (2022-CS-810)

👨‍🏫 Supervisor: Sir Talha

🏛️ Institution: University of Engineering and Technology, Lahore (Faisalabad Campus)

🕓 Session: 2022–2026

📚 References
Neo4j Documentation

Flutter

Flask

Firebase

Gamma et al., Design Patterns

Ricci et al., Recommender Systems Handbook (Springer, 2011)

Cypher Query Language Reference

yaml
Copy
Edit

---

Let me know if you want me to:

- Add screenshots or GIFs to the README  
- Generate the `firebase_options.dart` file for you  
- Set up a GitHub Actions CI/CD badge or deployment workflow  

Just copy and paste this file as `README.md` in your GitHub repo root.
