# AI Med Scan

A Flutter application for medical image analysis using AI to detect brain tumors from MRI scans. The app allows users to upload or capture MRI images, analyze them with a machine learning model, and view results with confidence scores and downloadable reports.

## Features

- User authentication (register/login)
- Upload MRI images from gallery or camera
- AI-powered brain tumor classification
- View analysis results with confidence levels
- Scan history with downloadable reports
- Cross-platform support (Android, iOS, Web, Desktop)

## Project Structure

```
ai_med_scan/
├── lib/                    # Flutter frontend
│   ├── screens/           # UI screens
│   ├── services/          # API service layer
│   ├── models/            # Data models
│   └── widgets/           # Reusable widgets
├── android/               # Android platform code
├── ios/                   # iOS platform code
├── web/                   # Web platform code
├── backend/               # Node.js backend
│   ├── routes/           # API routes
│   ├── config/           # Database configuration
│   ├── middleware/       # Authentication middleware
│   ├── ml/               # Machine learning components
│   └── uploads/          # Uploaded files
└── test/                 # Flutter tests
```

## Prerequisites

- Flutter SDK (3.10.0 or later)
- Node.js (16 or later)
- PostgreSQL database
- Python 3.8+ (for ML model)
- Git

## Backend Setup

1. **Navigate to backend directory:**
   ```bash
   cd backend
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Set up PostgreSQL database:**
   - Create a PostgreSQL database
   - Update `backend/config/db.js` with your database credentials

4. **Set up environment variables:**
   - Create a `.env` file in the backend directory
   - Add necessary environment variables (JWT secret, database URL, etc.)

5. **Install Python dependencies for ML:**
   ```bash
   pip install tensorflow numpy pillow
   ```

6. **Start the backend server:**
   ```bash
   npm start
   ```
   The server will run on http://localhost:3000

## Frontend Setup

1. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run the app:**
   - For Android: `flutter run`
   - For iOS: `flutter run` (on macOS)
   - For Web: `flutter run -d chrome`
   - For Desktop: `flutter run -d windows` or `flutter run -d linux`

## API Endpoints

- `POST /register` - User registration
- `POST /login` - User login
- `POST /predict` - Upload and analyze MRI image
- `GET /history` - Get user's scan history
- `GET /reports/:filename` - Download analysis report

## Machine Learning Model

The ML model (`brain_tumor_classifier_model.h5`) is a TensorFlow/Keras model trained for brain tumor classification. The prediction script (`predict.py`) processes uploaded images and generates classification results with confidence scores.

## Building for Production

### Backend
```bash
npm run build
```

### Frontend
```bash
flutter build apk  # For Android
flutter build ios  # For iOS
flutter build web  # For Web
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, please open an issue on GitHub or contact the development team.
