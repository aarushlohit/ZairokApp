#!/usr/bin/env node
import admin from 'firebase-admin';
import fs from 'fs';

// Get service account key
const serviceAccountPath = process.env.GOOGLE_APPLICATION_CREDENTIALS || 
  `${process.env.HOME}/.config/gcloud/legacy_credentials/aarush1822@gmail.com/adc.json`;

let serviceAccount;
try {
  serviceAccount = JSON.parse(fs.readFileSync(serviceAccountPath, 'utf8'));
} catch (e) {
  console.error('Error: Could not find service account key.');
  console.log('Visit: https://console.firebase.google.com/project/zairok/settings/serviceaccounts/adminsdk');
  console.log('Download JSON and set GOOGLE_APPLICATION_CREDENTIALS env var, or place at:');
  console.log(serviceAccountPath);
  process.exit(1);
}

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://zairok-default-rtdb.firebaseio.com',
});

const db = admin.database();

// Initialize counter
db.ref('downloads').set(50).then(() => {
  console.log('✅ Download counter initialized to 50');
  process.exit(0);
}).catch(err => {
  console.error('❌ Error:', err.message);
  process.exit(1);
});
