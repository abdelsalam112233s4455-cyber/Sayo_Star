const express = require('express');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const path = require('path');
const http = require('http');
const cors = require('cors');
const { Server } = require('socket.io');

dotenv.config({
  path: path.join(__dirname, 'config.env'),
});

const app = express();
const server = http.createServer(app);

const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
  },
});

app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

const PORT = process.env.PORT || 5000;
const CONNECTION_STRING = process.env.CONNECTION_STRING;

mongoose
  .connect(CONNECTION_STRING)
  .then(() => console.log('✅ MongoDB connected'))
  .catch((error) => console.error('❌ MongoDB connection error:', error));

const userSchema = new mongoose.Schema(
  {
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },
    username: { type: String, default: '' },
    country: { type: String, default: '' },
    age: { type: Number, default: null },
    gender: { type: String, default: '' },
    bio: { type: String, default: '' },
    avatarUrl: { type: String, default: '' },
    uid: { type: String, default: '', index: true },
  },
  { timestamps: true }
);

const messageSchema = new mongoose.Schema(
  {
    senderId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    receiverId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    messageText: {
      type: String,
      required: true,
      trim: true,
    },
    createdAt: {
      type: Date,
      default: Date.now,
      index: true,
    },
  },
  { versionKey: false }
);

messageSchema.index({ senderId: 1, receiverId: 1, createdAt: 1 });

const noteSchema = new mongoose.Schema(
  {
    des: { type: String, default: '' },
    type: { type: String, default: '' },
  },
  { timestamps: true }
);

const User = mongoose.model('User', userSchema);
const Message = mongoose.model('Message', messageSchema);
const Note = mongoose.model('Note', noteSchema);

const onlineUsers = new Map();

function isValidObjectId(id) {
  return (
    typeof id === 'string' &&
    mongoose.Types.ObjectId.isValid(id) &&
    new mongoose.Types.ObjectId(id).toString() === id.toLowerCase()
  );
}

function normalizeId(id) {
  return String(id || '').trim().toLowerCase();
}

function sendAck(ack, data) {
  if (typeof ack === 'function') {
    ack(data);
  }
}

app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'SaYo Star server is running',
  });
});

// ========================================
// Get user by email
// ========================================

app.get('/users/:email', async (req, res) => {
  try {
    const email = decodeURIComponent(req.params.email)
      .trim()
      .toLowerCase();

    const user = await User.findOne({ email }).lean();

    if (!user) {
      return res.status(404).json({
        atchevement: false,
        message: 'المستخدم غير موجود',
      });
    }

    return res.json(user);
  } catch (error) {
    console.error('GET /users/:email error:', error);

    return res.status(500).json({
      atchevement: false,
      message: 'حدث خطأ أثناء جلب المستخدم',
    });
  }
});

// ========================================
// Create user
// ========================================

app.post('/users', async (req, res) => {
  try {
    const {
      email,
      username,
      country,
      age,
      gender,
      bio,
      avatarUrl,
      uid,
    } = req.body;

    if (!email || !String(email).trim()) {
      return res.status(400).json({
        success: false,
        message: 'البريد الإلكتروني مطلوب',
      });
    }

    const normalizedEmail = String(email).trim().toLowerCase();

    const existingUser = await User.findOne({
      email: normalizedEmail,
    });

    if (existingUser) {
      return res.status(409).json({
        success: false,
        message: 'المستخدم مسجل بالفعل',
        user: existingUser,
      });
    }

    const user = await User.create({
      email: normalizedEmail,
      username: username || '',
      country: country || '',
      age: age ?? null,
      gender: gender || '',
      bio: bio || '',
      avatarUrl: avatarUrl || '',
      uid: uid || '',
    });

    return res.status(201).json({
      success: true,
      user,
    });
  } catch (error) {
    console.error('POST /users error:', error);

    return res.status(500).json({
      success: false,
      message: 'تعذر إنشاء المستخدم',
    });
  }
});

// ========================================
// Check user by email
// ========================================

app.get('/users/check/:email', async (req, res) => {
  try {
    const email = decodeURIComponent(req.params.email)
      .trim()
      .toLowerCase();

    const user = await User.findOne({ email }).lean();

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'المستخدم غير موجود',
      });
    }

    return res.json({
      success: true,
      _id: user._id,
      email: user.email,
      username: user.username,
      uid: user.uid,
      avatarUrl: user.avatarUrl,
      country: user.country,
      age: user.age,
      gender: user.gender,
      bio: user.bio,
    });
  } catch (error) {
    console.error('GET /users/check/:email error:', error);

    return res.status(500).json({
      success: false,
      message: 'حدث خطأ أثناء البحث عن المستخدم',
    });
  }
});

// ========================================
// Delete user
// ========================================

app.delete('/users/:email', async (req, res) => {
  try {
    const email = decodeURIComponent(req.params.email)
      .trim()
      .toLowerCase();

    const user = await User.findOneAndDelete({ email });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'المستخدم غير موجود',
      });
    }

    await Message.deleteMany({
      $or: [
        { senderId: user._id },
        { receiverId: user._id },
      ],
    });

    return res.json({
      success: true,
      message: 'تم حذف المستخدم',
    });
  } catch (error) {
    console.error('DELETE /users/:email error:', error);

    return res.status(500).json({
      success: false,
      message: 'تعذر حذف المستخدم',
    });
  }
});

// ========================================
// Update user
// ========================================

app.put('/users/iditto/:email', async (req, res) => {
  try {
    const email = decodeURIComponent(req.params.email)
      .trim()
      .toLowerCase();

    const allowedFields = [
      'username',
      'country',
      'age',
      'gender',
      'bio',
      'avatarUrl',
      'uid',
    ];

    const updates = {};

    for (const field of allowedFields) {
      if (Object.prototype.hasOwnProperty.call(req.body, field)) {
        updates[field] = req.body[field];
      }
    }

    const user = await User.findOneAndUpdate(
      { email },
      { $set: updates },
      { new: true, runValidators: true }
    );

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'المستخدم غير موجود',
      });
    }

    return res.json({
      success: true,
      user,
    });
  } catch (error) {
    console.error('PUT /users/iditto/:email error:', error);

    return res.status(500).json({
      success: false,
      message: 'تعذر تحديث بيانات المستخدم',
    });
  }
});

// ========================================
// Save note
// ========================================

app.post('/users/note', async (req, res) => {
  try {
    const { des, type } = req.body;

    const note = await Note.create({
      des: des || '',
      type: type || '',
    });

    return res.status(201).json({
      success: true,
      note,
    });
  } catch (error) {
    console.error('POST /users/note error:', error);

    return res.status(500).json({
      success: false,
      message: 'تعذر حفظ البيانات',
    });
  }
});

// ========================================
// Get user by MongoDB _id or Firebase UID
// ========================================

app.get('/api/users/:id', async (req, res) => {
  try {
    const id = String(req.params.id || '').trim();

    let user = null;

    if (isValidObjectId(id)) {
      user = await User.findById(id).lean();
    }

    if (!user) {
      user = await User.findOne({ uid: id }).lean();
    }

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'المستخدم غير موجود',
      });
    }

    return res.json(user);
  } catch (error) {
    console.error('GET /api/users/:id error:', error);

    return res.status(500).json({
      success: false,
      message: 'تعذر جلب المستخدم',
    });
  }
});

// ========================================
// Get users and their latest message
// ========================================

app.get('/api/users', async (req, res) => {
  try {
    const currentUserId = String(
      req.query.currentUserId || ''
    ).trim();

    if (!isValidObjectId(currentUserId)) {
      return res.status(400).json({
        success: false,
        message: 'currentUserId يجب أن يكون MongoDB _id صحيحًا',
      });
    }

    const currentObjectId = new mongoose.Types.ObjectId(
      currentUserId
    );

    const users = await User.find({
      _id: { $ne: currentObjectId },
    })
      .select('_id email username country age gender bio avatarUrl uid')
      .lean();

    const usersWithLastMessage = await Promise.all(
      users.map(async (user) => {
        const lastMessage = await Message.findOne({
          $or: [
            {
              senderId: currentObjectId,
              receiverId: user._id,
            },
            {
              senderId: user._id,
              receiverId: currentObjectId,
            },
          ],
        })
          .sort({ createdAt: -1, _id: -1 })
          .lean();

        return {
          ...user,
          lastMessageText: lastMessage
            ? lastMessage.messageText
            : '',
          lastMessageTime: lastMessage
            ? lastMessage.createdAt
            : null,
        };
      })
    );

    usersWithLastMessage.sort((a, b) => {
      const timeA = a.lastMessageTime
        ? new Date(a.lastMessageTime).getTime()
        : 0;

      const timeB = b.lastMessageTime
        ? new Date(b.lastMessageTime).getTime()
        : 0;

      return timeB - timeA;
    });

    return res.json(usersWithLastMessage);
  } catch (error) {
    console.error('GET /api/users error:', error);

    return res.status(500).json({
      success: false,
      message: 'تعذر تحميل المستخدمين',
    });
  }
});

// ========================================
// Get conversation messages
// ========================================

app.get('/api/messages/:senderId/:receiverId', async (req, res) => {
  try {
    const { senderId, receiverId } = req.params;

    if (
      !isValidObjectId(senderId) ||
      !isValidObjectId(receiverId)
    ) {
      return res.status(400).json({
        success: false,
        message: 'معرف المستخدم غير صحيح',
      });
    }

    const senderObjectId = new mongoose.Types.ObjectId(senderId);
    const receiverObjectId = new mongoose.Types.ObjectId(
      receiverId
    );

    const messages = await Message.find({
      $or: [
        {
          senderId: senderObjectId,
          receiverId: receiverObjectId,
        },
        {
          senderId: receiverObjectId,
          receiverId: senderObjectId,
        },
      ],
    })
      .sort({ createdAt: 1, _id: 1 })
      .lean();

    return res.json(messages);
  } catch (error) {
    console.error('GET /api/messages error:', error);

    return res.status(500).json({
      success: false,
      message: 'تعذر تحميل الرسائل',
    });
  }
});

// ========================================
// Socket.IO
// ========================================

io.on('connection', (socket) => {
  console.log('🔌 Socket connected:', socket.id);

  socket.on('join', async (rawUserId, ack) => {
    try {
      const userId = normalizeId(rawUserId);

      if (!isValidObjectId(userId)) {
        const result = {
          success: false,
          message: 'MongoDB _id غير صحيح',
        };

        socket.emit('chat_error', result);
        sendAck(ack, result);
        return;
      }

      const user = await User.findById(userId).select('_id').lean();

      if (!user) {
        const result = {
          success: false,
          message: 'المستخدم غير موجود في قاعدة البيانات',
        };

        socket.emit('chat_error', result);
        sendAck(ack, result);
        return;
      }

      socket.data.userId = user._id.toString();

      socket.join(user._id.toString());

      if (!onlineUsers.has(user._id.toString())) {
        onlineUsers.set(user._id.toString(), new Set());
      }

      onlineUsers.get(user._id.toString()).add(socket.id);

      const result = {
        success: true,
        userId: user._id.toString(),
      };

      socket.emit('joined', result);
      sendAck(ack, result);

      console.log(
        '✅ User joined chat:',
        user._id.toString(),
        socket.id
      );
    } catch (error) {
      console.error('Socket join error:', error);

      const result = {
        success: false,
        message: 'تعذر تسجيل الدخول إلى الدردشة',
      };

      socket.emit('chat_error', result);
      sendAck(ack, result);
    }
  });

  socket.on('send_message', async (data, ack) => {
    try {
      const senderId = socket.data.userId;

      if (!senderId || !isValidObjectId(senderId)) {
        const result = {
          success: false,
          message: 'سجّل دخول المستخدم في الدردشة أولاً',
        };

        socket.emit('chat_error', result);
        sendAck(ack, result);
        return;
      }

      if (!data || typeof data !== 'object') {
        sendAck(ack, {
          success: false,
          message: 'بيانات الرسالة غير صحيحة',
        });
        return;
      }

      const receiverId = normalizeId(data.receiverId);
      const messageText = String(
        data.messageText || ''
      ).trim();

      if (!isValidObjectId(receiverId)) {
        sendAck(ack, {
          success: false,
          message: 'معرف المستلم غير صحيح',
        });
        return;
      }

      if (!messageText) {
        sendAck(ack, {
          success: false,
          message: 'لا يمكن إرسال رسالة فارغة',
        });
        return;
      }

      if (messageText.length > 10000) {
        sendAck(ack, {
          success: false,
          message: 'الرسالة طويلة جدًا',
        });
        return;
      }

      if (senderId === receiverId) {
        sendAck(ack, {
          success: false,
          message: 'لا يمكنك إرسال رسالة إلى نفسك',
        });
        return;
      }

      const [sender, receiver] = await Promise.all([
        User.findById(senderId).select('_id username').lean(),
        User.findById(receiverId).select('_id username').lean(),
      ]);

      if (!sender || !receiver) {
        sendAck(ack, {
          success: false,
          message: 'المرسل أو المستلم غير موجود',
        });
        return;
      }

      const savedMessage = await Message.create({
        senderId: sender._id,
        receiverId: receiver._id,
        messageText,
        createdAt: new Date(),
      });

      const message = {
        _id: savedMessage._id.toString(),
        senderId: savedMessage.senderId.toString(),
        receiverId: savedMessage.receiverId.toString(),
        messageText: savedMessage.messageText,
        createdAt: savedMessage.createdAt.toISOString(),
      };

      sendAck(ack, {
        success: true,
        message,
      });

      io.to(receiver._id.toString()).emit(
        'receive_message',
        message
      );

      io.to(sender._id.toString()).emit(
        'new_message',
        message
      );

      io.to(receiver._id.toString()).emit(
        'new_message',
        message
      );

      console.log(
        '💬 Message saved:',
        message.senderId,
        '->',
        message.receiverId
      );
    } catch (error) {
      console.error('Socket send_message error:', error);

      sendAck(ack, {
        success: false,
        message: 'حدث خطأ أثناء إرسال الرسالة',
      });
    }
  });

  socket.on('disconnect', () => {
    const userId = socket.data.userId;

    if (userId && onlineUsers.has(userId)) {
      const userSockets = onlineUsers.get(userId);

      userSockets.delete(socket.id);

      if (userSockets.size === 0) {
        onlineUsers.delete(userId);
      }
    }

    console.log('🔌 Socket disconnected:', socket.id);
  });
});

// ========================================
// Error handling
// ========================================

app.use((err, req, res, next) => {
  console.error('Express error:', err);

  if (res.headersSent) {
    return next(err);
  }

  return res.status(500).json({
    success: false,
    message: 'حدث خطأ داخلي في السيرفر',
  });
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running on port ${PORT}`);
});