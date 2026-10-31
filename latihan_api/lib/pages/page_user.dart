import 'package:flutter/material.dart';

class PageUser extends StatefulWidget {
  const PageUser({super.key});

  @override
  State<PageUser> createState() => _PageUserState();
}

class _PageUserState extends State<PageUser> {
  List<Map<String, String>> dataUser = [
    {
      'nama': 'Andi',
      'email': 'andi@gmail.com',
      'status': 'Aktif',
    },
    {
      'nama': 'Budi',
      'email': 'budi@gmail.com',
      'status': 'Aktif',
    },
  ];

  final nama = TextEditingController();
  final email = TextEditingController();
  final status = TextEditingController();

  void formUser({int? index}) {
    nama.text = index == null ? '' : dataUser[index]['nama']!;
    email.text = index == null ? '' : dataUser[index]['email']!;
    status.text = index == null ? '' : dataUser[index]['status']!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(index == null ? 'Tambah User' : 'Edit User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nama,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              controller: email,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: status,
              decoration: const InputDecoration(labelText: 'Status'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nama.text.isEmpty ||
                  email.text.isEmpty ||
                  status.text.isEmpty) {
                return;
              }

              setState(() {
                Map<String, String> user = {
                  'nama': nama.text,
                  'email': email.text,
                  'status': status.text,
                };

                if (index == null) {
                  dataUser.add(user);
                } else {
                  dataUser[index] = user;
                }
              });

              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void hapusUser(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus User'),
        content: const Text('Yakin ingin menghapus data ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                dataUser.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data User'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: dataUser.length,
        itemBuilder: (context, index) {
          final user = dataUser[index];

          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text(user['nama']!),
              subtitle: Text(
                '${user['email']}\nStatus: ${user['status']}',
              ),
              isThreeLine: true,
              trailing: PopupMenuButton<String>(
                onSelected: (pilihan) {
                  if (pilihan == 'edit') {
                    formUser(index: index);
                  } else if (pilihan == 'hapus') {
                    hapusUser(index);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  const PopupMenuItem(
                    value: 'hapus',
                    child: Text('Hapus'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => formUser(),
        child: const Icon(Icons.add),
      ),
    );
  }
}