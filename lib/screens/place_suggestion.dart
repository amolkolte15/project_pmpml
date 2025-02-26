import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class PlaceSuggestionField extends StatefulWidget {
  final String hint;
  final IconData icon;
  final Function(Map<String, dynamic>) onPlaceSelected;

  const PlaceSuggestionField({
    Key? key,
    required this.hint,
    required this.icon,
    required this.onPlaceSelected,
  }) : super(key: key);

  @override
  _PlaceSuggestionFieldState createState() => _PlaceSuggestionFieldState();
}

class _PlaceSuggestionFieldState extends State<PlaceSuggestionField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Map<String, dynamic>> _places = [];
  List<Map<String, dynamic>> _filteredPlaces = [];
  bool _isLoading = true;
  String _selectedPlace = '';
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _loadPlaces();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _showOverlay();
      } else {
        _hideOverlay();
      }
    });
  }

  @override
  void dispose() {
    _hideOverlay();
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadPlaces() async {
    try {
      final String response = await rootBundle.loadString('lib/service/data.json');
      final data = await json.decode(response);
      setState(() {
        _places = List<Map<String, dynamic>>.from(data['places']);
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading places: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterPlaces(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredPlaces = [];
        _updateOverlay();
      });
      return;
    }

    setState(() {
      _filteredPlaces = _places
          .where((place) =>
              place['name'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
      _updateOverlay();
    });
  }

  void _selectPlace(Map<String, dynamic> place) {
    setState(() {
      _selectedPlace = place['name'];
      _controller.text = place['name'];
      _hideOverlay();
      _focusNode.unfocus();
    });
    widget.onPlaceSelected(place);
  }

  void _showOverlay() {
    _hideOverlay();
    
    if (_controller.text.isEmpty && _filteredPlaces.isEmpty) {
      _filteredPlaces = _places.take(5).toList(); // Show first 5 places by default
    }
    
    _overlayEntry = _createOverlayEntry();
    if (_overlayEntry != null) {
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  void _updateOverlay() {
    _hideOverlay();
    _overlayEntry = _createOverlayEntry();
    if (_overlayEntry != null) {
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry? _createOverlayEntry() {
    if (_filteredPlaces.isEmpty) return null;
    
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    
    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              constraints: BoxConstraints(
                maxHeight: 200,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _filteredPlaces.length > 5 ? 5 : _filteredPlaces.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final place = _filteredPlaces[index];
                  return ListTile(
                    dense: true,
                    title: Text(place['name']),
                    subtitle: Text(
                      "Lat: ${place['latitude']}, Lng: ${place['longitude']}",
                      style: TextStyle(fontSize: 12),
                    ),
                    onTap: () => _selectPlace(place),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Icon(widget.icon, color: Colors.black54),
            const SizedBox(width: 10),
            Expanded(
              child: _selectedPlace.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPlace = '';
                        _controller.text = '';
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedPlace,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Icon(Icons.clear, size: 18, color: Colors.grey),
                      ],
                    ),
                  )
                : TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: widget.hint,
                      hintStyle: const TextStyle(fontSize: 16, color: Colors.black54),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: _filterPlaces,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}