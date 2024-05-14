import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({Key? key}) : super(key: key);

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<Map<String, dynamic>> productList = [];
  String? selectedCategory;
  TextEditingController filterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final dio = Dio();
    try {
      final response =
          await dio.get('https://consultancy-server.onrender.com/getproduct');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        setState(() {
          productList = List<Map<String, dynamic>>.from(data);
        });
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  void _deleteProduct(int index) async {
    final dio = Dio();
    final productId = productList[index]['_id'];

    try {
      final response =
          await dio.delete('https://consultancy-server.onrender.com/deleteproduct/$productId');
      if (response.statusCode == 200) {
        setState(() {
          productList.removeAt(index);
          Navigator.of(context).pop();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product deleted successfully')),
        );
      } else {
        throw Exception('Failed to delete product: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting product')),
      );
    }
  }

  final Map<String, String> productImages = {
    'T-shirt': "Assets/images/tshirt.png",
    'Shirt': "Assets/images/shirt.png",
    'Shorts': "Assets/images/shorts.png",
    'Pant': "Assets/images/pant.png",
    // Add more mappings as needed for other products
  };
  List<Map<String, dynamic>> get filteredProducts {
    final filterText = filterController.text.toLowerCase();
    return productList
        .where((product) => product['description']
            .toString()
            .toLowerCase()
            .contains(filterText))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product List'),
      ),
      body: Column(
        children: [
          if (selectedCategory != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: filterController,
                decoration: InputDecoration(
                  labelText: 'Filter by Brand',
                  hintText: 'Enter brand name',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
          Expanded(
            child: selectedCategory == null
                ? ListView(
                    children: [
                      ListTile(
                        leading: Icon(Icons.person),
                        title: Text('Men'),
                        onTap: () {
                          setState(() {
                            selectedCategory = 'Mens';
                          });
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.child_care),
                        title: Text('Kids'),
                        onTap: () {
                          setState(() {
                            selectedCategory = 'Kids';
                          });
                        },
                      ),
                    ],
                  )
                : ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      final productName = product['productname'] ?? 'No Name';
                      final brand = product['description'] ?? 'No Brand';
                      final leadingImage = productImages
                              .containsKey(productName)
                          ? Image.asset(
                              productImages[productName]!,
                              width: 50,
                              height: 50,
                            )
                          : Icon(
                              Icons.image); // Placeholder if image is not found

                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(productName),
                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Brand: $brand'),
                                    Text(
                                        'ProductID: ${product['productID'] ?? 'No ProductID'}'),
                                    Text(
                                        'Category: ${product['category'] ?? 'No Category'}'),
                                    Text(
                                        'Ordered Date: ${product['date'] ?? 'No Date'}'),
                                    Text(
                                        'Price: ${product['costperunit'] ?? '0.0'}'),
                                    Text(
                                        'Stock: ${product['totalstock'] ?? '0'}'),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                    },
                                    child: Text('Close'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _deleteProduct(index);
                                    },
                                    child: Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.all(8),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                leadingImage,
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(productName),
                                    Text('Brand: $brand'),
                                  ],
                                ),
                                Spacer(),
                                Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ProductListPage(),
  ));
}
