class API {
  // Base URL for the API
  static const String _baseURL = "http://divinelifeministriesinternational.org";

  // User-related endpoints
  static const String _userEndpoint = "$_baseURL/users";

  // Signup endpoint
  static Uri get signup => Uri.parse("$_userEndpoint/userRegister.php");

  // Check email endpoint
  static Uri get checkEmail => Uri.parse("$_userEndpoint/check_email.php");

  // Login endpoint
  static Uri get login => Uri.parse("$_userEndpoint/login.php");
}
