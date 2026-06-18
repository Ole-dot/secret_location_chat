/**
 * Deletes test/dummy user profiles from Firestore.
 *
 * Matches users where:
 *   - isTest === true, OR
 *   - email ends with @example.com / @test.com (common dev accounts)
 *
 * Prerequisites:
 *   npm install firebase-admin
 *   firebase login
 *   gcloud auth application-default login
 *
 * Usage:
 *   cd scripts && npm install firebase-admin && node delete_test_users.mjs
 *
 * Dry run (list only, no deletes):
 *   DRY_RUN=1 node delete_test_users.mjs
 */
import { initializeApp, applicationDefault } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { getAuth } from "firebase-admin/auth";

const projectId = process.env.PROJECT_ID ?? "me-c-69d57";
const dryRun = process.env.DRY_RUN === "1";

initializeApp({
  credential: applicationDefault(),
  projectId,
});

const db = getFirestore();
const auth = getAuth();

function isTestUser(data) {
  if (data.isTest === true) return true;
  const email = String(data.email ?? "").toLowerCase();
  return email.endsWith("@example.com") || email.endsWith("@test.com");
}

const snapshot = await db.collection("users").get();
const toDelete = snapshot.docs.filter((doc) => isTestUser(doc.data()));

if (toDelete.length === 0) {
  console.log("No test users found in Firestore.");
  process.exit(0);
}

console.log(`Found ${toDelete.length} test user(s):`);
for (const doc of toDelete) {
  const data = doc.data();
  console.log(`  - ${doc.id}  ${data.email ?? "?"}  ${data.username ?? data.nickname ?? "?"}`);
}

if (dryRun) {
  console.log("\nDRY_RUN=1 — no documents deleted.");
  process.exit(0);
}

for (const doc of toDelete) {
  await db.recursiveDelete(doc.ref);
  try {
    await auth.deleteUser(doc.id);
    console.log(`Deleted Firestore + Auth: ${doc.id}`);
  } catch (err) {
    console.log(`Deleted Firestore only (Auth missing?): ${doc.id} — ${err.message}`);
  }
}

console.log("Done.");
