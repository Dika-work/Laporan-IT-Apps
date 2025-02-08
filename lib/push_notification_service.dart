// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:googleapis_auth/auth_io.dart' as auth;
// import 'package:googleapis/servicecontrol/v1.dart' as serviceControl;

// class PushNotificationService {
//   static Future<String> getAccessToken() async {
//     final serviceAccountJson = {
//       "type": "service_account",
//       "project_id": "laporan-kerja-71c97",
//       "private_key_id": "1caf6d554658910f01b1d4410a6bf60db108b15d",
//       "private_key":
//           "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCpHm1MHJ05nSTU\nWcikL3QUsLol01/stcaYHKf9Crq3QNfdLo4vo7RwxgJQ45eRzLRtCPriwR2Lh6Vm\nZziLBy8WqAkpHETrMuca5FhBoS+fxstcT8kHkP6679Pwo2VVWjtDKdz13V5OOl8q\nv5pHA+WKV58+4w9PK6ygc1DAl2+zkMF2HPZBzJqMgDdqLgyXcrCGPmbO9fNG/ULM\n4UeNNhTbrgy80jV8LEmLWFDPWPK+FwDmbMsCZI7IBH/Nj0dK/Htofy4FWUuCUcVN\nDiFXIz/T5LpaeaqMw/JEVjgxWVKWxYLeiJeMnpYA6N4R1buuJJnIXW+Yriz+ltJg\n0kF8zYp1AgMBAAECggEAB/DrJkJxtN2GzTHUv2Dlt9L/P/zHlFCKHWUQaPayrcgt\nsAUaSBe3xqkwPVFyhzYa2BkuhAHtZo/dWbb0a2glneVmCLglxFAvlI5Zq+XrBpBJ\nxvE4JKgk+Jd/rDJVSnIM4P/Q5aVEuFz6payO4fwc2yd3eCHRUOEMH2dKyMBTo8Ak\nwqK1qlU/OJRIJz3e/qOV4f6GAJXTq0G/xQI68NqlaHh2MUDqRwnKS8fKgzCCJmTr\n9g3ppfjE7Bv/aHBXSLEggLWndrku4XBqKuu+sMf/iudXjA54wA8gy+inF/xHuoMr\nVfhbOAHRa8UkMMD4zeHIzpdV4Wg0CruOR2aPxb32QQKBgQDcdSOyF0dnt4D6pQyc\nVeXoKDoF1mJuH/m+CgpFm/mMr4VI1b/puqhZ6oilxow20sqtNzm9vItDijP+5aIP\n6dy4Njr8yChRRerba1bOaBWrIMQD/zPCNdoeiWj1M+GO2ROU2JETKbnm0RqVl3Bb\nBUdmU6Oy3VLJLEWdNc2e2+aGuwKBgQDEYmd+iI8NTPD6l1/r40a/6r0rXE5lj7a7\nqH8qD2KcUn4P2Z0YEl6OcZutq5lEcLMQOFxWmYCKR/FDwOd4vEPSknmkAiD7khb5\nWsp9XzCaq3TOedRe7DhJReXpwi2x32UhndcHrwIR4g+BqlO5C89Vlm7T9oZqrRUB\ndLWCGqhYjwKBgD7q75UUL7zaEmV2VXMI0OTBFk40MUNcvNoP436aVU5hiZiP6IW8\nT+/Zj8ZANCQxZMaqzD/qX5SXDN/iia4hAG1SjOM3/Mm1OqIEsHGYIxcD8u1xGESF\nOgsdDGdutyEdswj4Be+CKRxG8V9gKSDREN+TX1Tc9ZOUnwmPIXAFMnWhAoGASC5D\nC+b1bVYSXIi24OSwZGnLDdznk7y21VKhKrxs6jgHzZuWefqGdqSbK8Iem2Ew741H\noyzYafr3WofUjDPmWccsnnOJ2+1eNFiChIIwQykxzZJJ1HnOVmAymTCdyvrpGOoC\n1vgkMp58RJRuIV2N309jfNTnot3rEpXrAN77cVECgYEAgzvDsJPR745ZzoznZs4Q\nV0Cj9z5k+sKTOTqcCCbcM4B5p21qvmG163/YSkdh8/pSWOjqHMUPyHGo/7V66yG/\njrka/3nOgpL5wYoiJkPF38uFTgmYP28AkMg9FbsaCi3D3mMsBhBlIQD0amrXt4L7\nUy484CAflh2yCrPZOG93tbs=\n-----END PRIVATE KEY-----\n",
//       "client_email":
//           "firebase-adminsdk-zwl8b@laporan-kerja-71c97.iam.gserviceaccount.com",
//       "client_id": "104991763587712789052",
//       "auth_uri": "https://accounts.google.com/o/oauth2/auth",
//       "token_uri": "https://oauth2.googleapis.com/token",
//       "auth_provider_x509_cert_url":
//           "https://www.googleapis.com/oauth2/v1/certs",
//       "client_x509_cert_url":
//           "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-zwl8b%40laporan-kerja-71c97.iam.gserviceaccount.com",
//       "universe_domain": "googleapis.com"
//     };

//     List<String> scopes = [
//       "https://www.googleapis.com/auth/userinfo.email",
//       "https://www.googleapis.com/auth/firebase.database",
//       "https://www.googleapis.com/auth/firebase.messaging"
//     ];

//     http.Client client = await auth.clientViaServiceAccount(
//         auth.ServiceAccountCredentials.fromJson(serviceAccountJson), scopes);

//     // get access token
//     auth.AccessCredentials credentials =
//         await auth.obtainAccessCredentialsViaServiceAccount(
//             auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
//             scopes,
//             client);

//     client.close();

//     return credentials.accessToken.data;
//   }

//   static sendNotification(
//       String deviceToken, BuildContext context, String tripID) async {
//     final String serverKey = await getAccessToken();
//     String endPointFirebaseCloudMessaging =
//         'https://fcm.googleapis.com/v1/projects/laporan-kerja-71c97/messages:send';

//     final Map<String, dynamic> message = {
//       'message': {
//         'token': deviceToken,
//         'notification': {'title': '','body': ''}
//       }
//     };
//   }
// }
