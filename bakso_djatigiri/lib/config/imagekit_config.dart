// Konfigurasi ImageKit untuk upload gambar
// File ini akan digunakan untuk setup endpoint dan API key ImageKit

class ImageKitConfig {
  // Ganti dengan endpoint dan public key dari dashboard ImageKit
  static const String uploadEndpoint =
      'https://upload.imagekit.io/api/v1/files/upload';
  static const String publicKey = 'public_SSS3tsRN6GdbW6wPdzxGRdH9OWU=';
  static const String urlEndpoint = 'https://ik.imagekit.io/cape';
  // Jika butuh autentikasi private key, sebaiknya lakukan di backend, bukan di aplikasi mobile
}
