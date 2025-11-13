import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

// --- Step 1: Initialize YOUR (Client App) Admin SDK ---
// This uses the default credentials of the project it's in.
admin.initializeApp();
const clientDb = admin.firestore();

// --- Step 2: Initialize the THERAPIST Admin SDK ---
// We load the secret key file we downloaded
const serviceAccount = require("../therapist-admin-key.json");

// We initialize a *second* app connection using the key
const therapistAdmin = admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
}, "therapistAdmin"); // We give it a unique name

// We get a reference to the therapist database
const therapistDb = therapistAdmin.firestore();


// --- Step 3: Create the "Bridge" Function ---
// This is an "onCall" function, meaning your Flutter app can call it directly.
export const forwardBookingToTherapist = functions.https.onCall(
  async (data, context) => {
    // 1. Check if the user making this call is a logged-in client
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "You must be logged in to book an appointment.",
      );
    }

    // 2. Get the booking data from the Flutter app
    const bookingData = data;
    const clientId = context.auth.uid;

    try {
      // 3. First, save the booking to the *Client's* database
      // This is what we did before, but now the server does it
      // so the client can't send fake data.
      const clientBookingData = {
        ...bookingData,
        clientId: clientId, // Ensure the client ID is correct
        status: "pending", // Set the initial status
        therapistId: null,
      };

      const clientBookingRef = await clientDb
        .collection("users")
        .doc(clientId)
        .collection("orders")
        .add(clientBookingData);

      functions.logger.info("Booking saved to client's DB:", clientBookingRef.id);

      // 4. Second, "forward" the booking to the *Therapist's* database
      // We use the *therapistDb* connection here
      const therapistBookingRef = await therapistDb
        .collection("bookings") // Save to the top-level 'bookings'
        .add(clientBookingData); // Send the same data

      functions.logger.info(
        "Booking forwarded to therapist DB:",
        therapistBookingRef.id,
      );

      // 5. Send a "success" response back to the Flutter app
      return {
        success: true,
        clientBookingId: clientBookingRef.id,
        therapistBookingId: therapistBookingRef.id,
      };
    } catch (error) {
      functions.logger.error("Error forwarding booking:", error);
      throw new functions.https.HttpsError(
        "internal",
        "An error occurred while creating your booking.",
        error,
      );
    }
  },
);