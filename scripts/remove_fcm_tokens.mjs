/**
 * One-time cleanup: remove fcmToken / fcmTokenUpdatedAt from all users docs.
 *
 * Prerequisites:
 *   1. npm install firebase-admin   (in this scripts/ folder or project root)
 *   2. firebase login
 *   3. set GOOGLE_APPLICATION_CREDENTIALS or run: gcloud auth application-default login
 *
 * Usage (from repo root):
 *   cd scripts
 *   npm init -y
 *   npm install firebase-admin
 *   node remove_fcm_tokens.mjs
 *
 * Or set PROJECT_ID env var if different from .firebaserc default.
 */
import { initializeApp, applicationDefault } from "firebase-admin/app";
import { getFirestore, FieldValue } from "firebase-admin/firestore";

const projectId = process.env.PROJECT_ID ?? "me-c-69d57";

initializeApp({
  credential: applicationDefault(),
  projectId,
});

const db = getFirestore();
const snapshot = await db.collection("users").get();

let updated = 0;
let batch = db.batch();
let batchCount = 0;

for (const doc of snapshot.docs) {
  const data = doc.data();
  if (!("fcmToken" in data) && !("fcmTokenUpdatedAt" in data)) {
    continue;
  }

  batch.update(doc.ref, {
    fcmToken: FieldValue.delete(),
    fcmTokenUpdatedAt: FieldValue.delete(),
  });
  updated++;
  batchCount++;

  if (batchCount >= 400) {
    await batch.commit();
    batch = db.batch();
    batchCount = 0;
  }
}

if (batchCount > 0) {
  await batch.commit();
}

console.log(`Done. Removed fcmToken fields from ${updated} user document(s).`);
