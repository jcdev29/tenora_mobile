class AppConstants {
  // App Info
  static const String appName = 'Tenora Tenant';
  static const String appVersion = '1.0.0';
  
  // Mock Credentials
  static const String mockEmail = 'juan@email.com';
  static const String mockPassword = 'password123';
  
  // Date Formats
  static const String dateFormat = 'MMM dd, yyyy';
  static const String dateTimeFormat = 'MMM dd, yyyy hh:mm a';
  static const String timeFormat = 'hh:mm a';
  
  // Payment Methods
  static const String gcashNumber = '0917 123 4567';
  static const String gcashName = 'Maria Santos';
  static const String bankName = 'BDO';
  static const String bankAccountNumber = '1234 5678 9012';
  static const String bankAccountName = 'Tenora Property Management';
  
  // Complaint Categories
  static const List<String> complaintCategories = [
    'Plumbing',
    'Electrical',
    'Aircon',
    'Furniture',
    'Cleaning',
    'Noise',
    'Security',
    'Others',
  ];
  
  // Priority Levels
  static const List<String> priorityLevels = [
    'Low',
    'Medium',
    'High',
    'Urgent',
  ];
  
  // Pagination
  static const int pageSize = 10;
  
  // Image Upload
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png'];
}