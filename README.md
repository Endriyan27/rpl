# Sistem Prediksi Menu Harian Restoran Hokben

Aplikasi prediksi menu harian untuk restoran Hokben yang mengintegrasikan machine learning dengan fitur-fitur lengkap untuk analisis dan prediksi penjualan.

## 🚀 Fitur Utama

### 📊 Dashboard Operasional
- **Metrik Utama**: Total Penjualan (YTD) dengan persentase pertumbuhan
- **Rata-rata Order**: Order per hari dengan trend analysis
- **Visualisasi**: Grafik penjualan bulanan interaktif
- **Status Model**: Indikator performa ANN real-time

### 🤖 Sistem Machine Learning
- **Model**: Artificial Neural Network (ANN) dengan 12 fitur input
- **Input Data**:
  - Data historis penjualan
  - Hari dalam seminggu
  - Tanggal dan bulan
  - Data cuaca simulasi
  - Event/hari libur lokal
  - Trend historis
  - Stok bahan baku
  - Performa menu sebelumnya

### 🔮 Prediksi Signifikan
- **Lonjakan Penjualan**: Menu yang diprediksi naik dengan persentase dan alasan
- **Peringatan Stok**: Notifikasi menu dengan risiko stok berlebih
- **Timeline**: Tanggal kapan prediksi akan terjadi
- **Alert System**: Notifikasi real-time untuk prediksi kritis

### ⚙️ Monitoring Sistem
- **Status Model**: Optimal/Perlu Training Ulang/Error/Training
- **Metrics**: Akurasi model, error rate, waktu training terakhir
- **Quality Indicator**: Sangat Baik/Baik/Cukup berdasarkan performa

## 🛠 Teknologi yang Digunakan

### Frontend
- **Flutter**: Framework utama untuk cross-platform development
- **Provider**: State management
- **FL Chart**: Visualisasi data dan grafik

### Backend & Database
- **SQLite**: Database lokal untuk menyimpan data historis
- **Shared Preferences**: Penyimpanan pengaturan aplikasi

### Machine Learning
- **ML Algo**: Library machine learning Dart native
- **Custom Neural Network**: Implementasi ANN dengan 12 input features

### UI/UX
- **Google Fonts**: Typography yang konsisten
- **Lottie**: Animasi smooth dan modern
- **Material Design 3**: Design system terbaru dari Google

## 📱 Navigasi Aplikasi

1. **Beranda** - Dashboard operasional utama
2. **Prediksi** - Analisis dan prediksi menu harian
3. **Ops** - Monitoring operasional (coming soon)
4. **Riwayat** - History prediksi dan performa (coming soon)
5. **Settings** - Pengaturan aplikasi dan profile user

## 🔐 Sistem Autentikasi

### Role-based Access Control:
- **Admin**: Akses penuh, dapat melatih model
- **Manager**: Akses prediksi dan dashboard
- **Staff**: Akses terbatas untuk viewing

### Demo Credentials:
- Admin: `admin@hokben.com` / `admin123`
- Manager: `manager@hokben.com` / `manager123`

## 🎯 Model ANN Architecture

```
Input Layer (12 features) → Hidden Layer (20 nodes) → Output Layer (1 prediction)
```

### Features Input:
1. Day of week (1-7)
2. Day of month (1-31)  
3. Month (1-12)
4. Year offset
5. Temperature
6. Holiday flag
7. Local event flag
8. Historical average
9. Menu price
10. Weather score
11. Seasonality factor
12. Trend factor

## 📊 Metrik Evaluasi

- **Akurasi**: >90% untuk prediksi harian
- **Confidence Level**: 0.7 - 0.98 range
- **Error Rate**: <5% untuk model optimal
- **Response Time**: <2 detik untuk dashboard

## 🚀 Cara Menjalankan

### Prerequisites
- Flutter SDK (latest stable)
- Dart SDK
- Chrome (untuk web development)

### Installation
```bash
# Clone repository
git clone <repo-url>
cd aplikasi_prediksi_penjualan

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Build untuk Production
```bash
# Web
flutter build web

# Android APK
flutter build apk

# iOS
flutter build ios
```

## 🎨 Screenshots & Demo

*Screenshots akan ditambahkan setelah UI final*

## 📈 Roadmap

### Phase 1 ✅ (Current)
- [x] Dashboard operasional
- [x] Sistem prediksi dasar
- [x] Authentication & settings
- [x] Database integration

### Phase 2 🔄 (Next)
- [ ] Advanced ML model training
- [ ] Real-time notifications
- [ ] Export functionality (PDF/Excel)
- [ ] Advanced analytics

### Phase 3 📅 (Future)
- [ ] API integration
- [ ] Multi-restaurant support  
- [ ] Mobile push notifications
- [ ] Advanced reporting

## 🤝 Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Hokben Restaurant for the business case
- Flutter team for the amazing framework
- Community contributors and beta testers

---

**Made with ❤️ for Hokben Restaurant Management**

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
