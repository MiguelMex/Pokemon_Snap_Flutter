import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pokeclase20263/models/generation_list_response.dart';
import 'package:pokeclase20263/providers/poke_api_provider.dart';
import 'package:pokeclase20263/screens/generation_detail_screen.dart';
import 'package:provider/provider.dart';

class GenerationListScreen extends StatelessWidget {
  const GenerationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generaciones de Pokémon'),
        centerTitle: true,
      ),
      body: FutureBuilder<http.Response>(
        future: Provider.of<PokeApiProvider>(context, listen: false).getGenerations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _LoadingView();
          } else if (snapshot.hasError) {
            return _ErrorView(message: 'Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.statusCode != 200) {
            return const _ErrorView(
              message: 'No se encontraron generaciones de Pokémon.',
            );
          } else {
            final generationListResponse =
                GenerationListResponse.fromJson(json.decode(snapshot.data!.body));
            return _GenerationList(response: generationListResponse);
          }
        },
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _GenerationList extends StatelessWidget {
  final GenerationListResponse response;

  const _GenerationList({required this.response});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: response.results.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final generation = response.results[index];
        return _GenerationCard(
          name: generation.name,
          generationNumber: index + 1,
        );
      },
    );
  }
}

class _GenerationCard extends StatelessWidget {
  final String name;
  final int generationNumber;

  const _GenerationCard({
    required this.name,
    required this.generationNumber,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GenerationDetailScreen(
                generationId: generationNumber,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  '$generationNumber',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  name,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Icon(Icons.chevron_right, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}