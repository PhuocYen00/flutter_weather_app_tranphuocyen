import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/weather_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _doSearch(BuildContext context, String city) async {
    city = city.trim();
    if (city.isEmpty) return;

    if (!mounted) return;
    setState(() => _loading = true);

    final p = context.read<WeatherProvider>();

    try {
      await p.loadByCity(city);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint("Search error: $e");
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<WeatherProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm kiếm thành phố'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (v) => _doSearch(context, v),
                    decoration: const InputDecoration(
                      hintText: 'Nhập tên thành phố (ví dụ: Ho Chi Minh)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _loading
                    ? const SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () => _doSearch(context, _controller.text),
                      ),
              ],
            ),
          ),
          if (p.favoriteCities.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thành phố yêu thích',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: p.favoriteCities
                        .map(
                          (c) => ActionChip(
                            label: Text(c),
                            onPressed: () => _doSearch(context, c),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Tìm kiếm gần đây',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      if (p.searchHistory.isNotEmpty)
                        TextButton(
                          onPressed: () => p.clearSearchHistory(),
                          child: const Text('Xoá lịch sử'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: p.searchHistory.isEmpty
                        ? const Center(
                            child: Text('Chưa có lịch sử tìm kiếm'),
                          )
                        : ListView.separated(
                            itemCount: p.searchHistory.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (_, i) {
                              final city = p.searchHistory[i];
                              return ListTile(
                                leading: const Icon(Icons.history),
                                title: Text(city),
                                onTap: () => _doSearch(context, city),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
