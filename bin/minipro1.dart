import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

//Function all expenses
void allExpense() {}
//Function Todays expense
void TodaysExpense() {}
//Function Searching
Future<void> Searching() async { // Changed to async as it will make an HTTP request
  stdout.write("Item to Search: ");
  String keyword = stdin.readLineSync()?.trim().toLowerCase() ?? "";

  if (keyword.isEmpty) {
    print(" Item not found (empty keyword)");
    return;
  }

  // Construct the URL for your Node.js service
  final url = Uri.parse('http://localhost:3000/searching?q=$keyword');

  try {
    // Make the HTTP GET request
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // If the server returns a 200 OK status, print the response body
      print(response.body);
    } else if (response.statusCode == 400) {
      // Handle bad request errors (e.g., empty keyword)
      print("Error: ${response.body}");
    } else if (response.statusCode == 500) {
      // Handle server errors
      print("Server Error: ${response.body}");
    } else {
      // Handle other unexpected status codes
      print("Unexpected error: ${response.statusCode} - ${response.body}");
    }
  } catch (e) {
    // Catch any network or other exceptions
    print("Failed to connect to the server: $e");
  }
}


//Function Delete an expense
void delete() {}
void main() async {
  //["All expense","Today's expense","Serch"];
  Map<int, String> menu = {
    1: "All expense",
    2: "Today's expense",
    3: "Serch",
    4: "Add new expense",
    5: "Delete an expense",
    6: "Exit",
  };
  //fetch from server after login
  String? confirmedUsername;
  int? confirmedUserId;
  //Login
  print('==== Login ====');
  stdout.write('Username: ');
  String? inputUsername = stdin.readLineSync();
  stdout.write('Password: ');
  String? password = stdin.readLineSync();

  if (inputUsername != null && password != null) {
    //.... Check login, This is dummy condition
    final body = {"username": inputUsername, "password": password};
    final url = Uri.parse('http://localhost:3000/login');
    final response = await http.post(url, body: body);

    if (response.statusCode == 200) {
      int? selectedMenu; // Declare selectedMenu outside the loop
      final Map<String, dynamic> responseData = json.decode(response.body);
      final Map<String, dynamic>? user = responseData['user'];
      if (user != null &&
          user.containsKey('username') &&
          user.containsKey('id')) {
        confirmedUsername = user['username'];
        confirmedUserId = user['id'];
      } else {
        print(
          'Warning: Server did not provide username in response. Using input username.',
        );
        confirmedUsername = inputUsername;
      }
      // Main Application Loop
      do {
        print('\n========== Expense Tracking App ==========');
        print('Welcome $confirmedUsername ');
        menu.forEach((key, value) {
          print('$key. $value');
        });

        stdout.write('Choose an option: '); // Clarified prompt
        String? choosingMenu = stdin.readLineSync();

        if (choosingMenu != null) {
          selectedMenu = int.tryParse(choosingMenu);
          switch (selectedMenu) {
            case 1:
              //---> go to Summarize all expense function
              print('Viewing all expenses...');
              // Call your summarizeAllExpenses() function here
              break;
            case 2:
              //---> go to Today's summarize function
              print("Viewing today's expenses...");
              // Call your todaySummary() function here
              break;
            case 3:
              //---> go to searching function
              print('Searching expenses...');
              await Searching();
              // Call your searchFunction() here
              break;
            case 4:
              //---> go to Adding function
              print('Adding new expense...');
              break;
            case 5:
              //---> go to Delete function
              print('Deleting an expense...');
              // Call your deleteExpense() function here
              break;
            case 6:
              //---> end program
              print('----- Exiting Expense Tracking App. Goodbye! -----');
              break;
            default:
              print('Unknown menu option. Please enter a number from 1 to 6.');
          }
        } else {
          print('Invalid input. Please enter a number.');
          selectedMenu = 0; // Reset to a non-6 value to continue loop
        }
        // Add a small delay or a newline for better readability between menu loops
        if (selectedMenu != 6) {
          print('\nPress Enter to continue...');
          stdin.readLineSync(); // Wait for user to press Enter
        }
      } while (selectedMenu != 6);
    } else {
      print("Username or password wrong!");
    }
  } else {
    print('Input error. Please try again');
  }
}
