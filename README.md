# 🛒 FireGraph Smart Grocery Recommender

## 📑 Table of Contents

- [Project Overview](#project-overview)
- [Features](#features)
- [Technology Stack](#technology-stack)
- [System Architecture](#system-architecture)
- [Installation](#installation)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [Graph Model](#graph-model)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgments](#acknowledgments)
- [References](#references)

---

## 📖 Project Overview

**FireGraph Smart Grocery Recommender** is a personalized grocery recommendation system that uses graph-based machine learning to analyze user interactions and provide intelligent suggestions.

It combines a cross-platform Flutter app with a Flask backend, Neo4j graph database, and Firebase authentication to deliver scalable and personalized grocery experiences.

---

## ✨ Features

- Personalized product recommendations based on user behavior
- Graph relationships like VIEWED, PURCHASED, SIMILAR_TO
- Recommender logic using collaborative filtering + category similarity
- Real-time suggestion performance via optimized Cypher queries
- Secure login, registration, and session management via Firebase
- Admin interface for managing product categories (optional)
- Easily extendable for promotions, preferences, etc.

---

## 🛠 Technology Stack

| Layer           | Technology         |
|----------------|--------------------|
| Frontend       | Flutter            |
| Authentication | Firebase           |
| Backend        | Flask REST API     |
| Database       | Neo4j              |
| Data Format    | Cypher             |
| Hosting        | Local / Cloud      |

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
|Firebase| | Neo4j |
+--------+ +------------+


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

# Clone the repository
git clone https://github.com/<your-username>/firegraph-smart-grocery-recommender.git

# Navigate to the backend directory
cd firegraph-smart-grocery-recommender/backend

# Create a virtual environment
python -m venv venv

# Activate the virtual environment
# For macOS/Linux:
source venv/bin/activate
# For Windows:
# venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Set environment variables (do this before running the app)
# On macOS/Linux:
export NEO4J_URI="bolt://localhost:7687"
export NEO4J_USER="neo4j"
export NEO4J_PASSWORD="your_password"

# On Windows:
# set NEO4J_URI="bolt://localhost:7687"
# set NEO4J_USER="neo4j"
# set NEO4J_PASSWORD="your_password"

# Run the application
python app.py

📲 Usage
-Launch the Flutter app
-Register or log in with Firebase
-Browse grocery products
-View tailored recommendations based on your behavior
-Track your interaction history (viewed/purchased)
-(Optional) Admin panel for managing product categories
📂 Project Structure
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



🌐 Graph Model
🧩 Nodes
-User: { userID, name, email 
-Product: { productID, name, price, category }
-Category: { categoryID, name }

🔗 Relationships
-VIEWED: (User)-[:VIEWED {timestamp}]->(Product)
-PURCHASED: (User)-[:PURCHASED {timestamp, quantity}]->(Product)
-BELONGS_TO: (Product)-[:BELONGS_TO]->(Category)
-SIMILAR_TO: (Product)-[:SIMILAR_TO]->(Product)

🙏 Acknowledgments
👨‍💻 Team Members:
-Muhammad Arslan Jameel (2022-CS-816)
-Raheel Anjum (2022-CS-810)
👨‍🏫 Supervisor:
-Sir Talha
🏛️ Institution:
-University of Engineering and Technology, Lahore (Faisalabad Campus)
🕓 Session:
-2022–2026

📚 References
-Neo4j Documentation
-Flutter
-Flask
-Firebase
-Gamma et al., Design Patterns
-Ricci et al., Recommender Systems Handbook (Springer, 2011)
-Cypher Query Language Reference
