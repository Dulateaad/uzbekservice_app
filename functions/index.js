const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

/**
 * Отправка уведомления о новом заказе специалисту
 * Срабатывает при создании нового заказа в Firestore
 */
exports.sendOrderNotification = functions.firestore
  .document('orders/{orderId}')
  .onCreate(async (snap, context) => {
    const order = snap.data();
    const orderId = context.params.orderId;
    
    console.log('📦 Новый заказ создан:', orderId);
    
    // Получаем данные специалиста
    const specialistId = order.specialistId;
    if (!specialistId) {
      console.log('⚠️ Заказ без specialistId, пропускаем уведомление');
      return null;
    }
    
    try {
      const specialistDoc = await admin.firestore()
        .collection('users')
        .doc(specialistId)
        .get();
      
      if (!specialistDoc.exists) {
        console.log('⚠️ Специалист не найден:', specialistId);
        return null;
      }
      
      const specialist = specialistDoc.data();
      const deviceTokens = specialist.deviceTokens || [];
      
      if (deviceTokens.length === 0) {
        console.log('⚠️ У специалиста нет токенов устройств');
        return null;
      }
      
      // Проверяем настройки уведомлений
      const notificationPrefs = specialist.notificationPreferences || {};
      if (notificationPrefs.push === false) {
        console.log('⚠️ Push-уведомления отключены для специалиста');
        return null;
      }
      
      // Получаем данные клиента
      const clientId = order.clientId;
      let clientName = 'Клиент';
      if (clientId) {
        try {
          const clientDoc = await admin.firestore()
            .collection('users')
            .doc(clientId)
            .get();
          if (clientDoc.exists) {
            clientName = clientDoc.data().name || clientName;
          }
        } catch (e) {
          console.log('⚠️ Не удалось получить имя клиента:', e);
        }
      }
      
      // Формируем сообщение
      const message = {
        notification: {
          title: 'Новый заказ!',
          body: `У вас новый заказ от ${clientName}`,
        },
        data: {
          type: 'order',
          orderId: orderId,
          status: order.status || 'pending',
        },
        tokens: deviceTokens,
      };
      
      // Отправляем уведомление
      const response = await admin.messaging().sendMulticast(message);
      console.log('✅ Уведомление отправлено:', response.successCount, 'из', deviceTokens.length);
      
      // Удаляем невалидные токены
      if (response.failureCount > 0) {
        const failedTokens = [];
        response.responses.forEach((resp, idx) => {
          if (!resp.success) {
            failedTokens.push(deviceTokens[idx]);
          }
        });
        
        if (failedTokens.length > 0) {
          console.log('🗑️ Удаляем невалидные токены:', failedTokens.length);
          const updatedTokens = deviceTokens.filter(token => !failedTokens.includes(token));
          await admin.firestore()
            .collection('users')
            .doc(specialistId)
            .update({ deviceTokens: updatedTokens });
        }
      }
      
      return { success: true, sent: response.successCount };
    } catch (error) {
      console.error('❌ Ошибка отправки уведомления о заказе:', error);
      return null;
    }
  });

/**
 * Отправка уведомления о новом сообщении в чате
 * Срабатывает при создании нового сообщения
 */
exports.sendChatNotification = functions.firestore
  .document('chats/{chatId}/messages/{messageId}')
  .onCreate(async (snap, context) => {
    const message = snap.data();
    const chatId = context.params.chatId;
    const messageId = context.params.messageId;
    
    console.log('💬 Новое сообщение в чате:', chatId);
    
    // Получаем данные чата
    let chatDoc;
    try {
      chatDoc = await admin.firestore()
        .collection('chats')
        .doc(chatId)
        .get();
    } catch (e) {
      console.log('⚠️ Чат не найден:', chatId);
      return null;
    }
    
    if (!chatDoc.exists) {
      console.log('⚠️ Чат не существует');
      return null;
    }
    
    const chat = chatDoc.data();
    const senderId = message.senderId;
    
    // Определяем получателя (тот, кто не отправил сообщение)
    const recipientId = chat.participants?.find(p => p !== senderId);
    if (!recipientId) {
      console.log('⚠️ Получатель не найден');
      return null;
    }
    
    try {
      // Получаем данные получателя
      const recipientDoc = await admin.firestore()
        .collection('users')
        .doc(recipientId)
        .get();
      
      if (!recipientDoc.exists) {
        console.log('⚠️ Получатель не найден:', recipientId);
        return null;
      }
      
      const recipient = recipientDoc.data();
      const deviceTokens = recipient.deviceTokens || [];
      
      if (deviceTokens.length === 0) {
        console.log('⚠️ У получателя нет токенов устройств');
        return null;
      }
      
      // Проверяем настройки уведомлений
      const notificationPrefs = recipient.notificationPreferences || {};
      if (notificationPrefs.push === false) {
        console.log('⚠️ Push-уведомления отключены для получателя');
        return null;
      }
      
      // Получаем имя отправителя
      let senderName = 'Пользователь';
      try {
        const senderDoc = await admin.firestore()
          .collection('users')
          .doc(senderId)
          .get();
        if (senderDoc.exists) {
          senderName = senderDoc.data().name || senderName;
        }
      } catch (e) {
        console.log('⚠️ Не удалось получить имя отправителя:', e);
      }
      
      // Формируем сообщение
      const messageText = message.text || 'Новое сообщение';
      const messagePreview = messageText.length > 50 
        ? messageText.substring(0, 50) + '...' 
        : messageText;
      
      const notification = {
        notification: {
          title: senderName,
          body: messagePreview,
        },
        data: {
          type: 'chat',
          chatId: chatId,
          senderId: senderId,
          messageId: messageId,
        },
        tokens: deviceTokens,
      };
      
      // Отправляем уведомление
      const response = await admin.messaging().sendMulticast(notification);
      console.log('✅ Уведомление о сообщении отправлено:', response.successCount);
      
      // Удаляем невалидные токены
      if (response.failureCount > 0) {
        const failedTokens = [];
        response.responses.forEach((resp, idx) => {
          if (!resp.success) {
            failedTokens.push(deviceTokens[idx]);
          }
        });
        
        if (failedTokens.length > 0) {
          const updatedTokens = deviceTokens.filter(token => !failedTokens.includes(token));
          await admin.firestore()
            .collection('users')
            .doc(recipientId)
            .update({ deviceTokens: updatedTokens });
        }
      }
      
      return { success: true, sent: response.successCount };
    } catch (error) {
      console.error('❌ Ошибка отправки уведомления о сообщении:', error);
      return null;
    }
  });

/**
 * Отправка уведомления об изменении статуса заказа
 * Срабатывает при обновлении заказа
 */
exports.sendOrderStatusNotification = functions.firestore
  .document('orders/{orderId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const orderId = context.params.orderId;
    
    // Проверяем, изменился ли статус
    if (before.status === after.status) {
      return null;
    }
    
    console.log('📦 Статус заказа изменен:', orderId, before.status, '→', after.status);
    
    // Определяем получателя уведомления
    let recipientId;
    let notificationTitle;
    let notificationBody;
    
    if (after.status === 'accepted') {
      // Специалист принял заказ - уведомляем клиента
      recipientId = after.clientId;
      notificationTitle = 'Заказ принят!';
      notificationBody = 'Специалист принял ваш заказ';
    } else if (after.status === 'completed') {
      // Заказ выполнен - уведомляем клиента
      recipientId = after.clientId;
      notificationTitle = 'Заказ выполнен!';
      notificationBody = 'Ваш заказ успешно выполнен';
    } else if (after.status === 'cancelled') {
      // Заказ отменен - уведомляем обе стороны
      // Для простоты уведомляем только клиента
      recipientId = after.clientId;
      notificationTitle = 'Заказ отменен';
      notificationBody = 'Заказ был отменен';
    } else {
      return null;
    }
    
    if (!recipientId) {
      console.log('⚠️ Получатель не найден');
      return null;
    }
    
    try {
      const recipientDoc = await admin.firestore()
        .collection('users')
        .doc(recipientId)
        .get();
      
      if (!recipientDoc.exists) {
        return null;
      }
      
      const recipient = recipientDoc.data();
      const deviceTokens = recipient.deviceTokens || [];
      
      if (deviceTokens.length === 0) {
        return null;
      }
      
      const notificationPrefs = recipient.notificationPreferences || {};
      if (notificationPrefs.push === false) {
        return null;
      }
      
      const message = {
        notification: {
          title: notificationTitle,
          body: notificationBody,
        },
        data: {
          type: 'order',
          orderId: orderId,
          status: after.status,
        },
        tokens: deviceTokens,
      };
      
      const response = await admin.messaging().sendMulticast(message);
      console.log('✅ Уведомление о статусе отправлено:', response.successCount);
      
      return { success: true, sent: response.successCount };
    } catch (error) {
      console.error('❌ Ошибка отправки уведомления о статусе:', error);
      return null;
    }
  });

/**
 * Отправка уведомления о новом отзыве специалисту
 * Срабатывает при создании нового отзыва
 */
exports.sendReviewNotification = functions.firestore
  .document('reviews/{reviewId}')
  .onCreate(async (snap, context) => {
    const review = snap.data();
    const reviewId = context.params.reviewId;
    
    console.log('⭐ Новый отзыв создан:', reviewId);
    
    const specialistId = review.specialistId;
    if (!specialistId) {
      return null;
    }
    
    try {
      const specialistDoc = await admin.firestore()
        .collection('users')
        .doc(specialistId)
        .get();
      
      if (!specialistDoc.exists) {
        return null;
      }
      
      const specialist = specialistDoc.data();
      const deviceTokens = specialist.deviceTokens || [];
      
      if (deviceTokens.length === 0) {
        return null;
      }
      
      const notificationPrefs = specialist.notificationPreferences || {};
      if (notificationPrefs.push === false) {
        return null;
      }
      
      const rating = review.rating || 0;
      const message = {
        notification: {
          title: 'Новый отзыв!',
          body: `Вам оставили отзыв: ${rating} ⭐`,
        },
        data: {
          type: 'specialist',
          specialistId: specialistId,
          reviewId: reviewId,
          action: 'new_review',
        },
        tokens: deviceTokens,
      };
      
      const response = await admin.messaging().sendMulticast(message);
      console.log('✅ Уведомление об отзыве отправлено:', response.successCount);
      
      return { success: true, sent: response.successCount };
    } catch (error) {
      console.error('❌ Ошибка отправки уведомления об отзыве:', error);
      return null;
    }
  });

