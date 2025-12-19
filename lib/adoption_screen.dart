import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdoptionScreen extends StatefulWidget {
  const AdoptionScreen({super.key});

  @override
  State<AdoptionScreen> createState() => _AdoptionScreenState();
}

class _AdoptionScreenState extends State<AdoptionScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Dog', 'Cat', 'Bird', 'Rabbit', 'Other'];
  bool _isLoading = true;
  List<Map<String, dynamic>> _allPets = [];

  @override
  void initState() {
    super.initState();
    _fetchPets();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPets() async {
    try {
      final snapshot = await _firestore
          .collection('lost_found_posts')
          .where('statusType', isEqualTo: 'Found')
          .get();

      setState(() {
        _allPets = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            ...data,
            'docId': doc.id,
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching pets: $e");
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredPets {
    return _allPets.where((pet) {
      final petName = (pet['petName'] ?? '').toString().toLowerCase();
      final petType = (pet['petType'] ?? '').toString();
      final description = (pet['description'] ?? '').toString().toLowerCase();

      final matchesSearch = _searchQuery.isEmpty ||
          petName.contains(_searchQuery) ||
          description.contains(_searchQuery);

      final matchesFilter = _selectedFilter == 'All' || petType == _selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  Future<void> _toggleFavorite(Map<String, dynamic> pet, String docId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to add favorites')),
      );
      return;
    }

    try {
      final favoriteRef =
      _firestore.collection('user_favorites').doc('${user.uid}_$docId');
      final favoriteDoc = await favoriteRef.get();

      if (favoriteDoc.exists) {
        await favoriteRef.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from favorites')),
        );
      } else {
        await favoriteRef.set({
          'userId': user.uid,
          'petId': docId,
          'petName': pet['petName'] ?? 'Unknown Pet',
          'petType': pet['petType'] ?? 'Pet',
          'imageUrl': pet['imageUrl'] ?? '',
          'timestamp': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to favorites')),
        );
      }
      setState(() {});
    } catch (e) {
      print("Favorite error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<bool> _isPetFavorite(String docId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      final favoriteDoc = await _firestore
          .collection('user_favorites')
          .doc('${user.uid}_$docId')
          .get();
      return favoriteDoc.exists;
    } catch (e) {
      print("Check favorite error: $e");
      return false;
    }
  }

  void _showPetDetails(Map<String, dynamic> pet, String docId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => PetDetailsBottomSheet(
          pet: pet,
          docId: docId,
          onToggleFavorite: _toggleFavorite,
        ),
      ),
    );
  }

  void _contactOwner(Map<String, dynamic> pet) {
    final contactInfo = pet['contactInfo'] ?? 'No contact information provided';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Owner'),
        content: SelectableText(contactInfo),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Adopt a Pet"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FA), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search pets...',
                  prefixIcon: const Icon(Icons.search, color: Colors.teal),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.teal),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              ),
            ),

            // Filter chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filters.map((filter) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(filter),
                        selected: _selectedFilter == filter,
                        onSelected: (selected) => setState(() {
                          _selectedFilter = selected ? filter : 'All';
                        }),
                        selectedColor: Colors.teal,
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: _selectedFilter == filter ? Colors.white : Colors.teal,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Pets list
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchPets,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.teal))
                    : _filteredPets.isEmpty
                    ? Center(child: Text('No pets available for adoption'))
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredPets.length,
                  itemBuilder: (context, index) {
                    final pet = _filteredPets[index];
                    final docId = pet['docId'] ?? '';
                    final petName = pet['petName'] ?? 'Unknown Pet';
                    final petType = pet['petType'] ?? 'Pet';
                    final imageUrl = pet['imageUrl'] ?? '';

                    return FutureBuilder<bool>(
                      future: _isPetFavorite(docId),
                      builder: (context, favSnapshot) {
                        final isFavorite = favSnapshot.data ?? false;
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          margin: const EdgeInsets.only(bottom: 16),
                          child: InkWell(
                            onTap: () => _showPetDetails(pet, docId),
                            borderRadius: BorderRadius.circular(15),
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundImage: imageUrl.isNotEmpty
                                    ? NetworkImage(imageUrl)
                                    : null,
                                child: imageUrl.isEmpty
                                    ? const Icon(Icons.pets, size: 30)
                                    : null,
                              ),
                              title: Text(petName),
                              subtitle: Text(petType),
                              trailing: IconButton(
                                icon: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: isFavorite ? Colors.red : Colors.teal,
                                ),
                                onPressed: () => _toggleFavorite(pet, docId),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Pet Details Bottom Sheet
class PetDetailsBottomSheet extends StatefulWidget {
  final Map<String, dynamic> pet;
  final String docId;
  final Function(Map<String, dynamic>, String) onToggleFavorite;

  const PetDetailsBottomSheet({
    super.key,
    required this.pet,
    required this.docId,
    required this.onToggleFavorite,
  });

  @override
  State<PetDetailsBottomSheet> createState() => _PetDetailsBottomSheetState();
}

class _PetDetailsBottomSheetState extends State<PetDetailsBottomSheet> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('user_favorites')
          .doc('${user.uid}_${widget.docId}')
          .get();
      if (mounted) setState(() => _isFavorite = doc.exists);
    } catch (e) {
      print("Check favorite status error: $e");
    }
  }

  void _contactOwner() {
    final contactInfo = widget.pet['contactInfo'] ?? 'No contact information provided';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Owner'),
        content: SelectableText(contactInfo),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(widget.pet['petName'] ?? 'Unknown Pet', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _contactOwner, child: const Text('Contact Owner')),
          ],
        ),
      ),
    );
  }
}
