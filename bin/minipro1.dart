import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

//Function all expenses
void allExpense() {}
//Function Todays expense
void TodaysExpense() {}
//Function Searching
void Searching() {}
//Function Add new expense
Future<void> addExpense(int userId) async {
  print("===== Add New Item =====");
  stdout.write("Item: ");
  String? item = stdin.readLineSync();
  stdout.write("Paid: ");
  String? paid = stdin.readLineSync();

  if (item == null || item.isEmpty || paid == null || paid.isEmpty) {
    print("Please fill in both fields.");
    return;
  }

  final url = Uri.parse("http://localhost:3000/addexpenses");

  var response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "user_id": userId,
      "item": item,
      "paid": int.tryParse(paid) ?? 0,
    }),
  );

  if (response.statusCode == 200) {
    print("Inserted!");
  } else {
    print("Error adding expense: ${response.body}");
  }
}

//Function Delete an expense
Future<void> deleteExpense(int userId) async {
  print("===== Delete Expense =====");
  stdout.write("Enter item ID to delete: ");
  String? input = stdin.readLineSync();

  if (input == null || input.isEmpty) {
    print("ID is required.");
    return;
  }

  final expenseId = int.tryParse(input);
  if (expenseId == null) {
    print("Invalid ID format.");
    return;
  }

  final url = Uri.parse("http://localhost:3000/deleteexpense");

  var response = await http.delete(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"user_id": userId, "expense_id": expenseId}),
  );

  if (response.statusCode == 200) {
    print("Deleted!");
  } else {
    print("Error deleting expense: ${response.body}");
  }
}

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
              // Call your searchFunction() here
              break;
            case 4:
              //---> go to Adding function
              await addExpense(confirmedUserId!);
              break;
            case 5:
              //---> go to Delete function
              print('Deleting an expense...');
              await deleteExpense(confirmedUserId!);
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
