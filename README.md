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

**FireGraph Smart Grocery Recommender** is an advanced recommendation system designed to provide personalized grocery product suggestions using a graph-based approach. It leverages **Neo4j** for data modeling, **Flask** for backend services, **Flutter** for a cross-platform user interface, and **Firebase** for secure authentication.

The system combines **collaborative filtering** and **category-based filtering** to deliver real-time, tailored recommendations. This project was developed as part of a university curriculum at **University of Engineering and Technology, Lahore (Faisalabad Campus)**.

---

## ✨ Features

- **Personalized Recommendations** using PageRank and Node Similarity algorithms
- **Collaborative Filtering**: User-to-user and item-to-item recommendations
- **Category-Based Filtering** for refined suggestions
- **Real-Time Performance** with optimized Neo4j queries
- **Secure Authentication** via Firebase
- **Scalable Architecture** supporting millions of relationships in Neo4j
- **Cross-Platform UI** built with Flutter
- **Modular Design** using the Strategy Pattern for flexible algorithm switching

---

## 🛠 Technology Stack

| Layer           | Technology         |
|-----------------|--------------------|
| **Frontend**    | Flutter            |
| **Backend**     | Flask API          |
| **Database**    | Neo4j (Graph DB)   |
| **Authentication** | Firebase        |
| **Networking**  | HTTP REST APIs     |

---

## 🏗 System Architecture

The system follows a modular, layered architecture:

- **Frontend**: Flutter-based mobile app for seamless user interactions
- **Backend**: Flask API to interface with Neo4j and Firebase
- **Database**: Neo4j stores user-product relationships (`VIEWED`, `PURCHASED`, `BELONGS_TO`)
- **Authentication**: Firebase for secure login and session management

---

## 🚀 Installation

### Prerequisites

- **Flutter SDK** (>=3.0.0)
- **Python** (>=3.8)
- **Neo4j Desktop or Server** (>=5.0)
- **Firebase Project** (configured)
- **Node.js** (>=16.0)
- **Git**

### Setup Instructions

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/<your-username>/firegraph-smart-grocery-recommender.git
   cd firegraph-smart-grocery-recommender
