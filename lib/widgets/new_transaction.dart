import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'process_receipt.dart';

// Widget Class
class NewTransaction extends StatefulWidget {
  final Function addTx;

  NewTransaction(this.addTx);

  @override
  State<NewTransaction> createState() => _NewTransactionState();
}

// State Class
class _NewTransactionState extends State<NewTransaction> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate;

  void _submitData() {
    if (_amountController.text.isEmpty) {
      return;
    }

    final enteredTitle = _titleController.text;
    final enteredAmount = double.parse(_amountController.text);

    if (enteredTitle.isEmpty || enteredAmount <= 0 || _selectedDate == null) {
      return;
    }

    widget.addTx(
      // address a property inside the widget class
      enteredTitle,
      enteredAmount,
      _selectedDate,
    );

    Navigator.of(context).pop();
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      _setDate(pickedDate);
    });
  }

  void _setDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Card(
        child: Container(
          height: 300,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                cursorColor: Theme.of(context).primaryColor,
                decoration: InputDecoration(
                  labelText: 'Title',
                ),
                style: Theme.of(context).textTheme.headline4,
                controller: _titleController,
                onSubmitted: (_) => _submitData(),
              ),
              TextField(
                cursorColor: Theme.of(context).primaryColor,
                decoration: InputDecoration(
                  labelText: 'Amount',
                ),
                style: Theme.of(context).textTheme.headline4,
                controller: _amountController,
                keyboardType: TextInputType.number,
                onSubmitted: (_) => _submitData(),
              ),
              Container(
                height: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      (_selectedDate == null)
                          ? 'No date chosen'
                          : 'Transaction date: ${DateFormat.yMd().format(_selectedDate)}',
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    FlatButton(
                      textColor: Theme.of(context).primaryColor,
                      onPressed: _presentDatePicker,
                      child: (_selectedDate == null)
                          ? Text(
                              'Choose Date',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )
                          : null,
                    )
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ProcessReceipt(_titleController, _amountController, _setDate),
                  RaisedButton(
                    child: Text(
                      'Save Transaction',
                      style: Theme.of(context).textTheme.button,
                    ),
                    color: Theme.of(context).primaryColor,
                    onPressed: _submitData,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
