import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:animated_snack_bar/animated_snack_bar.dart';

import './widgets/chart.dart';
import './widgets/transaction_list.dart';
import './widgets/new_transaction.dart';
import 'models/transaction.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Exp',
      home: MyHomePage(),
      theme: ThemeData(
          // Swatch: automatically generates shades of the primary color
          primarySwatch: Colors.purple,
          accentColor: Colors.amber,
          // errorColor: ,
          fontFamily: 'ProximaNova',
          textTheme: ThemeData.light().textTheme.copyWith(
                headline3: TextStyle(
                  fontFamily: 'ProximaNova',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.grey[850],
                ),
                headline4: TextStyle(
                  fontFamily: 'ProximaNova',
                  fontSize: 18,
                  color: Colors.grey[850],
                ),
                headline5: TextStyle(
                  fontFamily: 'ProximaNova',
                  fontSize: 15,
                  color: Colors.grey,
                ),
                bodyText1: TextStyle(
                  fontFamily: 'ProximaNova',
                  fontSize: 14,
                  color: Colors.grey[850],
                ),
                bodyText2: TextStyle(
                  fontFamily: 'ProximaNova',
                  fontSize: 15,
                  color: Colors.white,
                ),
                button: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
          appBarTheme: AppBarTheme(
            titleTextStyle: TextStyle(
              fontFamily: 'Futura',
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          )),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Transaction> _userTransactions = [];
  bool isLoading = false;

  void set allTransactions(List<Transaction> transactions) {
    setState(() {
      _userTransactions.clear();
      _userTransactions.addAll(transactions);
    });
  }

  void loadAllProducts() async {
    try {
      setState(() {
        isLoading = true;
      });
      var response = await http.get(Uri.parse(
          "https://afternoon-bayou-05068.herokuapp.com/getAllMyTransactions"));

      var res = jsonDecode(response.body);

      var result = res.map<Transaction>((json) {
        final newTx = Transaction(
          title: json['title'],
          amount: json['amount'].toDouble(),
          date: DateFormat('yyyy-MM-dd').parse(json['date']),
          id: json['_id'],
        );
        setState(() {
          _userTransactions.add(newTx);
        });
      }).toList();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  List<Transaction> get _recentTransactions {
    return _userTransactions.where((tx) {
      return tx.date.isAfter(
        DateTime.now().subtract(Duration(days: 7)),
      );
    }).toList();
  }

  void _addNewTransaction(
      String txTitle, double txAmount, DateTime chosenDate) {
    final newTx = Transaction(
      title: txTitle,
      amount: txAmount,
      date: chosenDate,
      id: DateTime.now().toString(),
    );

    setState(() {
      _userTransactions.add(newTx);
      saveTransaction(newTx);
      loadAllProducts();
    });
  }

  Future<void> saveTransaction(Transaction newTransaction) async {
    try {
      Map body = {
        "id": newTransaction.id,
        "title": newTransaction.title,
        "amount": newTransaction.amount.toString(),
        "date": newTransaction.date.toString(),
      };

      var response = await http.post(
        Uri.parse("https://afternoon-bayou-05068.herokuapp.com/addTransaction"),
        body: body,
      );

      var result = jsonDecode(response.body);
    } catch (e) {
      print(e);
    }
  }

  void _handleDeleteTransaction(String id) async {
    setState(() {
      _userTransactions.removeWhere((tx) => (tx.id == id));
    });

    try {
      Map body = {
        "id": id,
      };

      var response = await http.delete(
        Uri.parse(
            "https://afternoon-bayou-05068.herokuapp.com/deleteTransaction"),
        body: body,
      );
      var result = jsonDecode(response.body);

      AnimatedSnackBar.material(
        'Transaction deleted',
        type: AnimatedSnackBarType.success,
        duration: Duration(seconds: 5),
        borderRadius: BorderRadius.circular(10),
        mobileSnackBarPosition: MobileSnackBarPosition.bottom,
        desktopSnackBarPosition: DesktopSnackBarPosition.topRight,
      ).show(context);

    } catch (e) {
      print(e);
    }
  }

  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return NewTransaction(_addNewTransaction);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('My Exp'),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _startAddNewTransaction(context),
            )
          ],
        ),
        body: isLoading
            ? Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: Theme.of(context).primaryColor,
                  size: 100,
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Chart(_recentTransactions),
                    TransactionList(
                        _userTransactions, _handleDeleteTransaction),
                  ],
                ),
              ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () => _startAddNewTransaction(context),
        ));
  }
}
