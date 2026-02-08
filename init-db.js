#!/usr/bin/env node

// This script initializes the downloads counter in Firebase Realtime Database
// It uses the web API directly without needing service account

const API_KEY = "AIzaSyCi15TCJE2N2NkETcfiiSqR6zB2HbO5930";
const PROJECT_ID = "zairok";
const DB_URL = "https://zairok-default-rtdb.firebaseio.com";

async function initializeCounter() {
  try {
    console.log("🔧 Initializing Firebase Realtime Database...");
    
    // Try to create the database by writing to it
    const response = await fetch(`${DB_URL}/downloads.json`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(50),
    });

    if (response.ok) {
      console.log("✅ Successfully initialized downloads counter to 50");
      console.log(`📊 Database: ${DB_URL}`);
      return true;
    } else if (response.status === 404) {
      console.error("❌ Database not created. Create it manually:");
      console.log(`   1. Go to: https://console.firebase.google.com/project/${PROJECT_ID}/database`);
      console.log("   2. Click 'Create Database'");
      console.log("   3. Choose location (e.g., us-central1)");
      console.log("   4. Start in 'Test Mode'");
      console.log("   5. Once created, run this script again");
      return false;
    } else {
      const error = await response.json();
      console.error("❌ Error:", error);
      return false;
    }
  } catch (err) {
    console.error("❌ Network error:", err.message);
    return false;
  }
}

initializeCounter().then(success => {
  process.exit(success ? 0 : 1);
});
