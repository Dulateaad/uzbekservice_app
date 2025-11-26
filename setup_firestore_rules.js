// Скрипт для настройки правил Firestore
// Запустите этот скрипт в консоли браузера на странице Firebase Console

const firestoreRules = `
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Временные правила для разработки (ОТКРЫТЫЙ ДОСТУП)
    // ⚠️ НЕ ИСПОЛЬЗУЙТЕ В ПРОДАКШЕНЕ!
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
`;

console.log('📋 Правила Firestore для копирования:');
console.log('=====================================');
console.log(firestoreRules);
console.log('=====================================');
console.log('📝 Инструкции:');
console.log('1. Откройте Firebase Console: https://console.firebase.google.com');
console.log('2. Выберите проект: odo-uz-app');
console.log('3. Перейдите в Firestore Database > Rules');
console.log('4. Скопируйте правила выше и вставьте их');
console.log('5. Нажмите "Publish"');
