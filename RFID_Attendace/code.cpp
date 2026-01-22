#include <SPI.h>
#include <MFRC522.h>
#include <Arduino.h>
#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <WiFiClient.h>
#include <WiFiClientSecureBearSSL.h>

#define RST_PIN  D3
#define SS_PIN   D4
#define Blue     D2
#define Red      D1
#define Green    D0

MFRC522 mfrc522(SS_PIN, RST_PIN);
MFRC522::MIFARE_Key key;  
MFRC522::StatusCode status;      

String card_holder_name;
const String sheet_url = "https://script.google.com/macros/s/AKfycbxYJqToQAPvVqRTDm5uYWthRpWrsOddxjBUDVJH4tzX9ED9iTSnvzUgcERQF24wBvMR-g/exec?name=";

// Define a structure to store UID and corresponding names
struct User {
  String uid;
  String name;
};

// Store the UID and names in the structure
User users[] = {
  {"196d26f3", "Adarsh_V_Pai"},
  {"5e3594a3", "Akshay_Kumar_KS"},
  {"36f0d3dc", "Jatin_Khanna"}
};

const uint8_t fingerprint[20] = {0x01, 0x16, 0xa3, 0xae, 0xca, 0xc9, 0xac, 0xed, 0x3a, 0xc9, 0xaa, 0x75, 0xbe, 0xc2, 0x51, 0xef, 0x65, 0xce, 0x23, 0xe1};

#define WIFI_SSID "Hardware 2.4"
#define WIFI_PASSWORD "hardware@2024"

void setup() {
  Serial.begin(9600);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED){
    delay(200);
  }
  pinMode(Blue, OUTPUT);
  pinMode(Red, OUTPUT);
  pinMode(Green, OUTPUT);
  digitalWrite(Blue, HIGH);
  SPI.begin();
}

void loop() {
  digitalWrite(Blue, HIGH); // Turn on Blue LED to indicate scanning

  mfrc522.PCD_Init();
  if (!mfrc522.PICC_IsNewCardPresent()) {
    digitalWrite(Blue, LOW); // Turn off Blue LED if no card present
    return;
  }
  if (!mfrc522.PICC_ReadCardSerial()) {
    digitalWrite(Blue, LOW); // Turn off Blue LED if card reading failed
    return;
  }

  Serial.println();
  Serial.println(F("Reading UID from RFID..."));
  String uid = readUID();

  Serial.println();
  Serial.print(F("UID read from RFID: "));
  Serial.println(uid);

  digitalWrite(Blue, LOW); // Turn off Blue LED as UID is successfully read

  if (WiFi.status() == WL_CONNECTED) {
    std::unique_ptr<BearSSL::WiFiClientSecure> client(new BearSSL::WiFiClientSecure);
    client->setFingerprint(fingerprint);

    // Check if the read UID matches any stored UID
    card_holder_name = getUserName(uid);
    if (!card_holder_name.isEmpty()) {
      card_holder_name = sheet_url + card_holder_name;
      HTTPClient https;
      if (https.begin(*client, (String)card_holder_name)){
        int httpCode = https.GET();
        if (httpCode > 0) {
          Serial.printf("[HTTPS] GET... code: %d\n", httpCode);
          digitalWrite(Green, HIGH); // Turn on Green LED to indicate successful transmission
          delay(200);
          digitalWrite(Green, LOW); // Turn off Green LED
        } else {
          Serial.printf("[HTTPS] GET... failed, error: %s\n", https.errorToString(httpCode).c_str());
          digitalWrite(Red, HIGH); // Turn on Red LED to indicate failed transmission
          delay(200);
          digitalWrite(Red, LOW); // Turn off Red LED
        }
        https.end();
        delay(1000);
      } else {
        Serial.printf("[HTTPS} Unable to connect\n");
        digitalWrite(Red, HIGH); // Turn on Red LED to indicate unable to connect
        delay(200);
        digitalWrite(Red, LOW); // Turn off Red LED
      }
    } else {
      Serial.println("Unknown user");
      digitalWrite(Red, HIGH); // Turn on Red LED to indicate unknown user
      delay(200);
      digitalWrite(Red, LOW); // Turn off Red LED
    }
  }
}

String readUID() {
  String uid = "";
  for (byte i = 0; i < mfrc522.uid.size; i++) {
    uid += String(mfrc522.uid.uidByte[i] < 0x10 ? "0" : "");
    uid += String(mfrc522.uid.uidByte[i], HEX);
  }
  return uid;
}

String getUserName(String uid) {
  for (int i = 0; i < sizeof(users) / sizeof(users[0]); i++) {
    if (uid == users[i].uid) {
      return users[i].name;
    }
  }
  return ""; // Return empty string if UID is not found
}
