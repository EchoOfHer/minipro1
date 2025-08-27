import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

//Function all expenses
const baseUrl = "http://localhost:3000"; // Node.js server
Future<void> allExpenses(int userId) async {
  try {
    var response = await http.get(Uri.parse("$baseUrl/expenses/$userId"));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      print("-------------  All Expenses ------------- ");

      if (data['expenses'].isEmpty) {
        print("No expenses found.");
      } else {
        int totalExpenses = 0;
        for (var exp in data['expenses']) {
          // Add the 'paid' value to the total
          totalExpenses += exp['paid'] as int;
          print(
            "${exp['id']}. ${exp['item']} : ${exp['paid']} : ${exp['date']}",
          );
        }
        print("Total expenses = $totalExpenses ฿");
      }
    } else {
      print("Error fetching expenses. Status code: ${response.statusCode}");
    }
  } catch (e) {
    print("Error: $e");
  }
}

//Function all expenses
//Function Todays expense
Future<void> TodaysExpense(int userId) async {
  try {
    var response = await http.get(Uri.parse("$baseUrl/expenses/today/$userId"));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      print("-------------  Today's Expenses ------------- ");

      if (data['expenses'].isEmpty) {
        print("No expenses found for today.");
      } else {
        int totalToday = 0;
        for (var exp in data['expenses']) {
          // Add the 'paid' value to the daily total
          totalToday += exp['paid'] as int;
          print(
            "${exp['id']}. ${exp['item']} : ${exp['paid']} : ${exp['date']}",
          );
        }
        print("Total expenses for today = $totalToday ฿");
      }
    } else {
      print(
        "Error fetching today's expenses. Status code: ${response.statusCode}",
      );
    }
  } catch (e) {
    print("Error: $e");
  }
}

//Function Searching
Future<void> Searching() async {
  stdout.write("Item to Search: ");
  String keyword = stdin.readLineSync()?.trim().toLowerCase() ?? "";

  if (keyword.isEmpty) {
    print("No item: (empty keyword)");
    return;
  }

  final url = Uri.http('localhost:3000', '/searching', {'q': keyword});

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // ลอง parse เป็น JSON ถ้าได้
      try {
        final List<dynamic> results = jsonDecode(response.body);

        if (results.isEmpty) {
          print("No item: $keyword");
          return;
        }

        for (var item in results) {
          int id = item['id'];
          String itemName = item['item'];
          int paid = item['paid'];
          String date = item['date'];

          print("$id. $itemName : $paid : $date");
        }
      } catch (_) {
        // ถ้า response ไม่ใช่ JSON (กรณี server ส่งข้อความ No item)
        print(response.body);
      }
    } else if (response.statusCode == 400) {
      print("Bad Request: ${response.body}");
    } else if (response.statusCode == 500) {
      print("Server Error: ${response.body}");
    } else {
      print("Unexpected error: ${response.statusCode} - ${response.body}");
    }
  } catch (e) {
    print("Failed to connect to the server: $e");
  }
}

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
  print("===== Delete an Item =====");
  stdout.write('Item id: ');
  int? id = int.tryParse(stdin.readLineSync() ?? '');

  if (id == null) {
    print('Invalid ID');
    return;
  }

  final url = Uri.parse('http://localhost:3000/expense/$id?user_id=$userId');

  try {
    final response = await http.delete(url);

    switch (response.statusCode) {
      case 200:
        print('Deleted!');
        break;
      case 404:
        print('Item not found or does not belong to you.');
        break;
      default:
        print('Failed to delete. Status: ${response.statusCode}');
    }
  } catch (e) {
    print('Request failed: $e');
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

        stdout.write('Choose...'); // Clarified prompt
        String? choosingMenu = stdin.readLineSync();

        if (choosingMenu != null) {
          selectedMenu = int.tryParse(choosingMenu);
          switch (selectedMenu) {
            case 1:
              //---> go to Summarize all expense function
              print('Viewing all expenses...');
              await allExpenses(confirmedUserId!);
              // Call your summarizeAllExpenses() function here
              break;
            case 2:
              //---> go to Today's summarize function
              print("Viewing today's expenses...");
              await TodaysExpense(confirmedUserId!);
              // Call your todaySummary() function here
              break;
            case 3:
              //---> go to searching function
              await Searching();
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
              print('----- Bye -----');
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
