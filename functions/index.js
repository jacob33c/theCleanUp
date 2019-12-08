//jshint esversion:8
const functions = require('firebase-functions');
const stripe = require('stripe')('sk_test_Xclw4Eqgu51hsT2KIx90g79a00uFgRvhPS');
const admin = require('firebase-admin');
const escapeHtml = require('escape-html');
const express = require('express');
const stripeAuthLink = "https://connect.stripe.com/express/oauth/authorize?&client_id=ca_Fkha46B1HuZb7PaGl66xh1tYRFzbtYKU#/";
admin.initializeApp();
var db = admin.database();


exports.helloWorld = functions.https.onRequest((request, response) => {
  console.log(request);
  console.log("request.query.code =",request.query.code);
  code =  request.query.code;
  console.log("hello world!");
  stripe.oauth.token({
    grant_type: 'authorization_code',
    code: code,
  }).then(function(response) {
    // asynchronously called
    var connected_account_id = response.stripe_user_id;
    console.log("connected_account_id =", connected_account_id);
  });
  response.send("Hello from Firebase!");
});




exports.createExpressAccount = functions.https.onRequest((req, res) => {
  state = Math.random().toString(36).slice(2);
  console.log("state = ", state);
  // Define the mandatory Stripe parameters: make sure to include our platform's client ID
  res.redirect(
    stripeAuthLink + "&state=" + state
  );
});




// When a user is created, register them with Stripe
exports.createStripeCustomer = functions.auth.user().onCreate(async (user) => {
  var accountRef = db.ref("/cleaner/" + user.uid);
  accountRef.set({
    email: user.email,
    connected_account_id: false
  });

  // const customer = await stripe.customers.create({email: user.email});
  const customer = await stripe.customers.create({
    description: 'Customer for ' + user.email,
    source: "tok_visa" // obtained with Stripe.js
  }, function(err, customer) {
    // asynchronously called
    if (err) {
      console.log(err);
    } else {
      var usersRef = db.ref("/stripe_customers/" + user.uid);
      usersRef.set({
        email: user.email,
        customer_id: customer.id,
        description: customer.description
      });
    }
  });
});

// var newPaymentMethodRef = functions.database.ref('/stripe_customers/{uid}/newPaymentMethod');
// var stripe_customers = functions.database.ref('/stripe_customers/{uid}');


exports.createCharge = functions.database.ref('/stripe_customers/{userId}/charges').onCreate((snapshot, context) => {
  console.log("new charge was created");
  var paymentMethod = snapshot.child("paymentMethod").val();
  var amount = snapshot.child("amount").val();
  var currency = snapshot.child("currency").val();
  var customerId = snapshot.child("customerId").val();
  console.log("paymentMethod = " + paymentMethod);
  console.log(currency);
  console.log(amount);
  console.log(customerId);
  (async () => {
    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount,
      currency: 'usd',
      payment_method_types: ['card'],
      payment_method: paymentMethod,
      customer: customerId,
      confirm: true,
    });
  })();
  return snapshot.ref.remove();
});




exports.updateDefault = functions.database.ref('/stripe_customers/{userId}/defaultPaymentMethod').onWrite((change, context) => {
  const val = change.after.val();
  change.after.ref.parent.child('customer_id').once('value', function(snap) {
    var customer_id = snap.val();
    var paymentMethod = change.after.val();
    (async () => {
      const update = await stripe.customers.update(
        customer_id, {
          invoice_settings: {
            default_payment_method: paymentMethod
          }
        },
        function(err, customer) {
          // asynchronously called
          if (err) {
            console.log(err);
          } else {
            console.log(customer);
          }
        }
      );
    });
    return val;

  });


});


exports.newPaymentMethod = functions.database.ref('/stripe_customers/{userId}/newPaymentMethod').onWrite((change, context) => {
  if (change.after.val() == null) {
    console.log("paymentMethod empty, ending function");
    return;
  }
  change.after.ref.parent.child('customer_id').once('value', function(snapshot) {

    var userId = context.params.userId;
    var customer_id = snapshot.val();
    var paymentMethod = change.after.val();

    console.log("uid = " + userId);
    console.log("newPaymentMethod = " + paymentMethod);
    console.log("customer_id = " + customer_id);



      stripe.paymentMethods.attach(paymentMethod, {
        customer: customer_id
      }, function(err, paymentMethods) {
        // asynchronously called
        if (err) {
          console.log(err);
          console.log("error");
        } else {
          console.log(paymentMethods);
          console.log("going to set data");
          change.after.ref.parent.update({
            defaultPaymentMethod: paymentMethod
          });
          change.after.ref.remove();
        }
      });
  });
  return 0;
});
