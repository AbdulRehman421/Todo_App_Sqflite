import 'package:flutter/material.dart';
import 'package:simple_todo_app/DataBase/db_helper.dart';

class HomePage extends StatefulWidget {

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Map<String, dynamic>> _allData = [];
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  void _refreshData()async{
    final data = await SQLHelper.getAllData();
    setState(() {
      _allData = data;
      _isLoading = false;
    });
  }

  void initState(){
    super.initState();
    _refreshData();
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionContrller = TextEditingController();

  void showBottomSheet(int? id)async{
    if(id!=null){
      final existingData = _allData.firstWhere((element) => element['id'] == id);
      _titleController.text = existingData['title'];
      _descriptionContrller.text = existingData['description'];
    }
    showModalBottomSheet(
      elevation: 5,
        isScrollControlled: true,
        context: context,
        builder: (_) => Container(
          padding: EdgeInsets.only(top: 30 , left: 15 , right: 15, bottom: MediaQuery.of(context).viewInsets.bottom + 50,),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter title';
                    }
                  },
                  controller: _titleController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Title'
                  ),
                ),
                SizedBox(height: 10,),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter title';
                    }
                  },
                  controller: _descriptionContrller,
                  maxLines: 4,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Description'
                  ),
                ),
                SizedBox(height: 20,),
                Center(
                  child: ElevatedButton(onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (id == null) {
                        await _addData();
                      }
                      if (id != null) {
                        await _updateData(id);
                      }
                      _titleController.text = "";
                      _descriptionContrller.text = "";
                      Navigator.of(context).pop();
                      print('Data Added');
                    }

                  },
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Text(id == null ? 'Submit' : 'Update', style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),),
                      )),
                )

              ],
            ),
          ),
        ),
    );
  }

  Future<void> _addData()async{
    await SQLHelper.createData(_titleController.text, _descriptionContrller.text);
    _refreshData();
  }
  Future<void> _updateData(int id)async{
    await SQLHelper.updateData(id, _titleController.text, _descriptionContrller.text);
    _refreshData();
  }
  Future<void> _deleteData(int id)async{
    await SQLHelper.deleteData(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text('Data Deleted')));
    _refreshData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFECEAF4),
      appBar: AppBar(
        title: Text('Todo List'),
      ),
      body: _isLoading ? Center(
        child: CircularProgressIndicator(),
      ) : ListView.builder(
          itemCount: _allData.length,
          itemBuilder: (context , index) => Card(
         margin: EdgeInsets.all(15),
            child: ListTile(
              title: Padding(padding: EdgeInsets.symmetric(vertical: 5),

              child: Text(_allData[index]['title'],
              style: TextStyle(fontSize: 20,),
              ),),
              subtitle: Text(_allData[index]['description']),
              trailing: PopupMenuButton(
                onSelected: (value) async {
                  if (value == 'edit'){
                    showBottomSheet(_allData[index]['id']);
                  }else if(value == 'delete'){
                    _deleteData(_allData[index]['id']);
                  }

                },

                itemBuilder: (context) {
                return[
                  PopupMenuItem(child: Text('Edit'),value: 'edit'),
                  PopupMenuItem(child: Text('Delete'),value: 'delete',),
                ];
              },),

            ),
      )
      ),floatingActionButton: FloatingActionButton(onPressed: () => showBottomSheet(null),
    child: Icon(Icons.add),
    ),
      
    );
  }
}
