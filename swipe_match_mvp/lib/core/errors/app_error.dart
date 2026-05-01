String friendlyError(Object error) {
  final text = error.toString().toLowerCase();

  if (text.contains('socket') ||
      text.contains('timeout') ||
      text.contains('network') ||
      text.contains('connection')) {
    return 'Network connection is unavailable. Please try again.';
  }

  if (text.contains('invalid login') || text.contains('invalid credentials')) {
    return 'Email or password is incorrect.';
  }

  if (text.contains('email')) {
    return 'Please check the email address.';
  }

  return 'Something went wrong. Please try again.';
}
