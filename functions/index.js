const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();
const firestore = admin.firestore();
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
exports.onReportCreate = functions
    .firestore
    .document('/AccidentReports/{pincode}/{pincode1}/{docId}')
    .onCreate(async (snapshot, context) => {
         const pincode = context.params.pincode;
        //All locations reference in user's pincode
        const hospitalReference = admin
            .firestore()
            .collection("Users")
            .where("userType","==","hospital");
        const querySnapshot = await hospitalReference.get();
        count = 0;
        querySnapshot.forEach(doc => {
            if (doc.exists) {
                if(doc.data()['pincode']==pincode){
                    const androidNotificationToken = doc.data()['androidNotificationToken'];
                    const message = {
                        notification: {
                            body: `An accident has been reported`,
                            title: "Please acknowledge",
                            
                        },
                        token: androidNotificationToken,
                        android: {
                            notification: {
                                
                                tag:doc.data()['uid']+"fromfcm",
                                notification_priority:"PRIORITY_DEFAULT"
                            },
                            priority: 'high',
                            ttl: 0
                        }
        
                    };
                    admin.messaging().send(message).then(res => {
                        console.log("message sent successfully ", res);
                    }).catch(error => {
                        console.log("Error : ", error);
                    });        
                }
            }
        });

    });



 