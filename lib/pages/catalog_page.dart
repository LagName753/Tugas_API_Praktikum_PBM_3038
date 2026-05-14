import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/product_model.dart';
import 'add_product_page.dart';
import 'login_page.dart';
import 'detail_page.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final storage = const FlutterSecureStorage();

  List<Product> _allProducts = [];
  List<Product> _displayedProducts =
      [];

  bool _isLoading = true;
  bool _isAscending = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String? token = await storage.read(key: 'auth_token');
      if (token == null) throw Exception("Token tidak ditemukan.");

      final url = Uri.parse('https://task.itprojects.web.id/api/products');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> productsJson = [];

        if (data['data'] != null && data['data']['products'] != null) {
          productsJson = data['data']['products'];
        } else if (data['products'] != null) {
          productsJson = data['products'];
        }

        setState(() {
          _allProducts = productsJson
              .map((json) => Product.fromJson(json))
              .toList();

          _applyFilterAndSort();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Data berhasil diproses! '),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF0F172A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.all(20),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: const EdgeInsets.all(20),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteProduct(int id) async {
    try {
      String? token = await storage.read(key: 'auth_token');

      final url = Uri.parse('https://task.itprojects.web.id/api/products/$id');

      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Data berhasil dihapus!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF0F172A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.all(20),
          ),
        );
        _fetchProducts();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal hapus: Endpoint mungkin tidak didukung.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF0F172A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.all(20),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: const EdgeInsets.all(20),
        ),
      );
    }
  }

  void _applyFilterAndSort() {
    setState(() {
      _displayedProducts = _allProducts.where((product) {
        return product.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();

      _displayedProducts.sort((a, b) {
        if (_isAscending) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        } else {
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        }
      });
    });
  }

  void _toggleSort() {
    setState(() {
      _isAscending = !_isAscending;
      _applyFilterAndSort();
    });
  }

  Future<void> _logout() async {
    await storage.delete(key: 'auth_token');
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          ' UMKM-core-6',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isAscending
                  ? Icons.sort_by_alpha
                  : Icons.sort,
              color: Colors.white,
            ),
            tooltip: _isAscending ? 'Urutkan Z-A' : 'Urutkan A-Z',
            onPressed: _toggleSort,
          ),

          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh Data',
            onPressed: _fetchProducts,
          ),

          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Keluar',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Keluar?'),
                  content: const Text('Yakin ingin keluar dari akun ini?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _logout();
                      },
                      child: const Text(
                        'Keluar',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF0F172A),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: TextField(
              onChanged: (value) {
                _searchQuery = value;
                _applyFilterAndSort();
              },
              decoration: InputDecoration(
                hintText: 'Cari nama portofolio...',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF6B6B)),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchProducts,
                    child: _displayedProducts.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 100),
                              Center(
                                child: Text(
                                  'Yah, portofolionya nggak ketemu atau masih kosong.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _displayedProducts.length,
                            itemBuilder: (context, index) {
                              final product = _displayedProducts[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 4,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFFFF9E6), Colors.white],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: ListTile(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DetailPage(product: product),
                                        ),
                                      );
                                    },

                                    contentPadding: const EdgeInsets.all(16),
                                    leading: const CircleAvatar(
                                      backgroundColor: Color(0xFFFFD93D),
                                      child: Icon(
                                        Icons.web,
                                        color: Color(0xFF2D3142),
                                      ),
                                    ),
                                    title: Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Color(0xFF2D3142),
                                      ),
                                    ),

                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.delete_sweep,
                                        color: Color(0xFFFF6B6B),
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Hapus Data?'),
                                            content: Text(
                                              'Yakin ingin menghapus "${product.name}"?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text('Batal'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  if (product.id != null) {
                                                    _deleteProduct(product.id!);
                                                  }
                                                },
                                                child: const Text(
                                                  'Hapus',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),

                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 8),

                                        Text(
                                          product.description,
                                          maxLines: 2,
                                          overflow: TextOverflow
                                              .ellipsis,
                                          style: const TextStyle(
                                            color: Colors.black87,
                                          ),
                                        ),

                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF6BCB77),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Text(
                                            'Rp ${product.price.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductPage()),
          );
          if (result == true) {
            _fetchProducts();
          }
        },
        backgroundColor: const Color(0xFF2563EB),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Tambah',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
