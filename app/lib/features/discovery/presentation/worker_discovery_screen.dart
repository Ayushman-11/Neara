import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../data/worker_providers.dart';
import '../data/worker_models.dart';
import '../../../core/ai/ai_providers.dart';

class WorkerDiscoveryScreen extends ConsumerStatefulWidget {
  const WorkerDiscoveryScreen({super.key});

  @override
  ConsumerState<WorkerDiscoveryScreen> createState() =>
      _WorkerDiscoveryScreenState();
}

class _WorkerDiscoveryScreenState extends ConsumerState<WorkerDiscoveryScreen> {
  bool _showMap = true;
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby help')),
      body: Column(
        children: [
          _SearchBar(
            onSubmitted: (query) {
              ref.read(searchFiltersProvider.notifier).fromQuery(query);
            },
          ),
          _FilterSummary(onTap: _openFilters),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Results',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: true,
                      icon: Icon(Icons.map),
                      label: Text('Map'),
                    ),
                    ButtonSegment(
                      value: false,
                      icon: Icon(Icons.list),
                      label: Text('List'),
                    ),
                  ],
                  selected: {_showMap},
                  onSelectionChanged: (value) {
                    setState(() {
                      _showMap = value.first;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _showMap ? _buildMapView() : _buildListView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: LatLng(16.7049, 74.2433),
        zoom: 13,
      ),
      onMapCreated: (controller) => _mapController = controller,
      myLocationEnabled: true,
      markers: const <Marker>{}, // TODO: bind to workers stream
    );
  }

  Widget _buildListView() {
    final workers = ref.watch(filteredWorkersProvider);
    return ListView.builder(
      itemCount: workers.length,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemBuilder: (context, index) {
        return _WorkerCard(worker: workers[index]);
      },
    );
  }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _FiltersSheet(),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final void Function(String query) onSubmitted;

  const _SearchBar({required this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFF121826),
          hintText: 'Describe what you need',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: const Icon(Icons.mic_none),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: BorderSide.none,
          ),
        ),
        onSubmitted: onSubmitted,
      ),
    );
  }
}

class _FilterSummary extends StatelessWidget {
  final VoidCallback onTap;

  const _FilterSummary({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            const Icon(Icons.tune, size: 18, color: Color(0xFF9CA3AF)),
            const SizedBox(width: 8),
            Expanded(
              child: Wrap(
                spacing: 6,
                runSpacing: -4,
                children: const [
                  _FilterChipLabel('Plumber'),
                  _FilterChipLabel('Within 5 km'),
                  _FilterChipLabel('4★+ rating'),
                  _FilterChipLabel('Verified'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChipLabel extends StatelessWidget {
  final String label;

  const _FilterChipLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
      ),
    );
  }
}

class _WorkerCard extends StatelessWidget {
  final Worker worker;

  const _WorkerCard({required this.worker, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF111827),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundImage: AssetImage('assets/placeholder_worker.png'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    worker.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${worker.primaryCategory.name} · ${worker.skills.join(', ')}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${worker.rating.toStringAsFixed(1)} ★ (${worker.jobCount} jobs) · ${worker.distanceKm.toStringAsFixed(1)} km · ${worker.etaMinutes} min ETA',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Final price after inspection',
                    style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                // TODO: Request service flow.
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: const Text('Request'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FiltersSheet extends StatelessWidget {
  const _FiltersSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 16,
        left: 16,
        right: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filters',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          const Text(
            'Service category',
            style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: const [
              Chip(label: Text('Mechanic')),
              Chip(label: Text('Plumber')),
              Chip(label: Text('Electrician')),
              Chip(label: Text('Maid')),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Distance radius',
            style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
          ),
          Slider(
            value: 5,
            min: 1,
            max: 20,
            divisions: 19,
            label: '5 km',
            onChanged: (_) {},
          ),
          const SizedBox(height: 8),
          const Text(
            'Rating',
            style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Expanded(child: _ToggleTile(label: '4★+ rating')),
              SizedBox(width: 8),
              Expanded(child: _ToggleTile(label: 'Verified only')),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Availability',
            style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Expanded(child: _ToggleTile(label: 'Now')),
              SizedBox(width: 8),
              Expanded(child: _ToggleTile(label: 'Today')),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Gender preference',
            style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Expanded(child: _ToggleTile(label: 'Any')),
              SizedBox(width: 8),
              Expanded(child: _ToggleTile(label: 'Female only')),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Apply filters'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _ToggleTile({
    required this.label,
    this.selected = false,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = selected ? Colors.white : const Color(0xFF9CA3AF);
    final Color backgroundColor = selected
        ? const Color(0xFF1F2937)
        : const Color(0xFF111827);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(label, style: TextStyle(fontSize: 12, color: textColor)),
        ),
      ),
    );
  }
}
