import 'package:flutter/material.dart';
// import 'package:expense_tracker/'
import 'package:expense_tracker/models/expense.dart';

class NewExpense extends StatefulWidget{
  const NewExpense({super.key, required this.onAddExpense});

  final void Function(Expense expense) onAddExpense;
  
  @override
  State<StatefulWidget> createState() {
    return _NewExpenseState();
  }
}

class _NewExpenseState extends State<NewExpense> {
  // var _enteredTitle = '';

  // void _saveTitleInput(String inputValue) {
  //   var _enteredTitle = inputValue;
  // }

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate; // null
  Category _selectedCategory = Category.leisure;

  void _presentDatePicker() async { // async for future value
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker( // Future object
      context: context, 
      initialDate: now, 
      firstDate: firstDate, 
      lastDate: now
    );
    // this line will only be executed when the value is available
    setState(() {
      _selectedDate = pickedDate;
    },);
  }

  void _submitExpenseData () {
    final enteredAmount = double.tryParse(_amountController.text); // tryParse('Hello') => null, tryParse('1.12') => 1.12
    final amountIsInvalid = enteredAmount == null || enteredAmount <= 0;
    if (_titleController.text.trim().isEmpty ||
        amountIsInvalid || 
        _selectedDate == null) {
        // show error message if empty title or a bunch of blanks
        showDialog(context: context, builder: (ctx) => AlertDialog(
          title: const Text('Invalid input'),
          content: const Text('Please make sure a valid title, amount, date and category was entered.'),
          actions: [
            TextButton(
              onPressed: () {
              Navigator.pop(ctx);
            }, child: Text('Okay'),
            ),
          ],
        ),
      );
      return;
    }

    widget.onAddExpense(
      Expense(
        title: _titleController.text, 
        amount: enteredAmount, 
        date: _selectedDate!, 
        category: _selectedCategory
      ),
    );
    Navigator.pop(context);
  }

  //must tell flutter to delete it when it's not needed anymore
  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
      child: Column(
        children: [
          TextField(
            // onChanged: _saveTitleInput, // only needed in Approach 1
            controller: _titleController,
            maxLength: 50,
            decoration: const InputDecoration(
              label: Text('Title'),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    prefixText: '\$ ',
                    label: Text('Amount'),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _selectedDate == null 
                      ? 'No date selected' 
                      : formatter.format(_selectedDate!),
                    ), // ! will never be null
                    IconButton(
                      onPressed: _presentDatePicker,
                      icon: const Icon(
                        Icons.calendar_month,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              DropdownButton(
                value: _selectedCategory, // the currently selected value will show up on the screen
                items: Category.values
                .map(
                  (category) => DropdownMenuItem(
                    value: category, // makes flutter understand that the value we will get will be of type category
                    child: Text(
                      category.name.toUpperCase(),
                    ),
                  ),
                ).toList(), 
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                  _selectedCategory = value;
                  });
                },
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // pop removes the overlay from the screen
                }, 
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _submitExpenseData,
                child: const Text('Save Expense'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}