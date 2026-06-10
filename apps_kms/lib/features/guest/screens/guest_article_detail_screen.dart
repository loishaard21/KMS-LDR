import 'package:flutter/material.dart';
import '../../../shared/models/article_model.dart';

class GuestArticleDetailScreen extends StatelessWidget {
  final ArticleModel article;

  const GuestArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detail Artikel'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cover Image
            if (article.cover != null && article.cover!.isNotEmpty)
              Image.network(
                article.cover!,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  color: const Color(0xFFEEF4FF),
                  child: const Icon(Icons.image, color: Color(0xFF94A3B8), size: 48),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta Info Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF4FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          article.category,
                          style: const TextStyle(fontSize: 10, color: Color(0xFF0052CC), fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.calendar_today_outlined, size: 12, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Text(
                        article.date,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    article.title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A2332), height: 1.3),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 16),

                  // Excerpt / Summary
                  if (article.excerpt != null && article.excerpt!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        article.excerpt!,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF475569), fontWeight: FontWeight.w500, fontStyle: FontStyle.italic, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Content Body
                  Text(
                    article.content != null && article.content!.isNotEmpty ? article.content! : 'Tidak ada konten detail.',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.7),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
