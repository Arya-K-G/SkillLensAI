import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constant/app_colors.dart';
import '../models/role_card.dart';
import '../routes/routes.dart';
import '../services/ai_api_service.dart';

class JobDescriptionScreen extends StatefulWidget {
  const JobDescriptionScreen({super.key});

  @override
  State<JobDescriptionScreen> createState() => _JobDescriptionScreenState();
}

class _JobDescriptionScreenState extends State<JobDescriptionScreen> {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController customJobDescriptionController = TextEditingController();

  String _query = '';
  String _selectedIndustry = 'All';
  Future<RoleLibraryPage>? _futurePage;

  Map get _args => Get.arguments is Map ? Get.arguments as Map : <String, dynamic>{};

  String get _resumeText => (_args['resumeText'] ?? '').toString();
  String get _resumeFileName => (_args['resumeFileName'] ?? '').toString();

  @override
  void initState() {
    super.initState();
    final initialJobDescription = (_args['jobDescription'] ?? '').toString().trim();
    if (initialJobDescription.isNotEmpty) {
      customJobDescriptionController.text = initialJobDescription;
    }
    _futurePage = _loadRoles();
  }

  @override
  void dispose() {
    searchController.dispose();
    customJobDescriptionController.dispose();
    super.dispose();
  }

  Future<RoleLibraryPage> _loadRoles() {
    return AiApiService.instance.fetchRoleLibrary(
      query: '',
      page: 1,
      pageSize: 1000,
    );
  }

  void _refresh() {
    setState(() {
      _futurePage = _loadRoles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8FD),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  colors: [Color(0xFF081D34), Color(0xFF194E7B), Color(0xFF3990C9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _resumeText.isEmpty ? 'Role Library' : 'Match Your Resume to Any Role',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _resumeText.isEmpty
                        ? 'Search the backend catalog and browse a single continuous list of AI-generated role guides.'
                        : 'Search across the entire role catalog, open AI-generated examples, and compare your resume with a live job guide.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.82),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2B5A87).withOpacity(0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Search Roles',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0E2840),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {
                        _query = value.trim();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search any role, company, industry, skill, or level',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: const Color(0xFFF5F9FD),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(color: AppColors.azure.withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(color: AppColors.azure.withOpacity(0.3)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            FutureBuilder<RoleLibraryPage>(
              future: _futurePage,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const _LoadingPanel();
                }

                if (snapshot.hasError) {
                  return _ErrorPanel(
                    message: snapshot.error.toString(),
                    onRetry: _refresh,
                  );
                }

                final page = snapshot.data ?? const RoleLibraryPage(
                  items: [],
                  page: 1,
                  pageSize: 1000,
                  total: 0,
                  totalPages: 1,
                );

                final industries = <String>{
                  'All',
                  ...page.items.map((role) => role.industry).where((item) => item.trim().isNotEmpty),
                }.toList()
                  ..sort((a, b) => a == 'All'
                      ? -1
                      : b == 'All'
                          ? 1
                          : a.compareTo(b));

                final normalizedQuery = _query.toLowerCase();
                final items = page.items.where((role) {
                  final matchesIndustry =
                      _selectedIndustry == 'All' || role.industry == _selectedIndustry;
                  if (!matchesIndustry) {
                    return false;
                  }

                  if (normalizedQuery.isEmpty) {
                    return true;
                  }

                  final haystack = [
                    role.roleName,
                    role.company,
                    role.location,
                    role.level,
                    role.industry,
                    role.summary,
                    ...role.tags,
                  ].join(' ').toLowerCase();
                  return haystack.contains(normalizedQuery);
                }).toList();
                final hasResults = items.isNotEmpty;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        '${items.length} of ${page.total} roles shown',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF17324B),
                        ),
                      ),
                    ),
                    if (_query.trim().isNotEmpty || _selectedIndustry != 'All') ...[
                      const SizedBox(height: 2),
                      Text(
                        _query.trim().isEmpty
                            ? 'Filtered by $_selectedIndustry'
                            : _selectedIndustry == 'All'
                                ? 'Search results for "${_query.trim()}"'
                                : 'Search results for "${_query.trim()}" in $_selectedIndustry',
                        style: const TextStyle(
                          color: Color(0xFF5E7487),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 50,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: industries.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final industry = industries[index];
                          final selected = industry == _selectedIndustry;

                          return ChoiceChip(
                            label: Text(industry),
                            selected: selected,
                            onSelected: (_) {
                              setState(() => _selectedIndustry = industry);
                            },
                            labelStyle: TextStyle(
                              color: selected ? Colors.white : const Color(0xFF17324B),
                              fontWeight: FontWeight.w700,
                            ),
                            selectedColor: AppColors.babyblue,
                            backgroundColor: const Color(0xFFF0F5FA),
                            side: BorderSide(color: AppColors.azure.withOpacity(0.25)),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...items.map(
                      (role) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _RoleCard(
                          role: role,
                          onOpen: () {
                            Get.toNamed(
                              AppRoutes.jobRoleDetail,
                              arguments: {
                                'role': role,
                                'resumeText': _resumeText,
                                'resumeFileName': _resumeFileName,
                              },
                            );
                          },
                          onCompare: _resumeText.trim().isEmpty
                              ? null
                              : () {
                                  final roleContext = [
                                    'Role: ${role.roleName}',
                                    'Company: ${role.company}',
                                    'Industry: ${role.industry}',
                                    'Level: ${role.level}',
                                    'Key skills: ${role.tags.join(', ')}',
                                    'Role summary: ${role.summary}',
                                  ].join('\n');

                                  Get.toNamed(
                                    AppRoutes.analysis,
                                    arguments: {
                                      'resumeText': _resumeText,
                                      'resumeFileName': _resumeFileName,
                                      'jobDescription': roleContext,
                                      'roleName': role.roleName,
                                      'company': role.company,
                                    },
                                  );
                                },
                        ),
                      ),
                    ),
                    if (!hasResults)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Text(
                          'No roles matched your search. Try a broader query like healthcare, finance, designer, engineer, or manager.',
                          style: TextStyle(color: Color(0xFF5E7487)),
                        ),
                      ),
                    if (_resumeText.trim().isNotEmpty) ...[
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2B5A87).withOpacity(0.08),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Or Paste a Custom Job Description',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0E2840),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: customJobDescriptionController,
                              maxLines: 9,
                              decoration: InputDecoration(
                                hintText:
                                    'Paste a custom job description to get a full AI comparison against your resume.',
                                filled: true,
                                fillColor: const Color(0xFFF5F9FD),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide(color: AppColors.azure.withOpacity(0.3)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide(color: AppColors.azure.withOpacity(0.3)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (customJobDescriptionController.text.trim().isEmpty) {
                                    Get.snackbar(
                                      'Job description required',
                                      'Paste a custom job description first.',
                                      backgroundColor: Colors.white,
                                    );
                                    return;
                                  }

                                  Get.toNamed(
                                    AppRoutes.analysis,
                                    arguments: {
                                      'resumeText': _resumeText,
                                      'resumeFileName': _resumeFileName,
                                      'jobDescription': customJobDescriptionController.text.trim(),
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.babyblue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: const Text(
                                  'Analyze Custom Job Description',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.role,
    required this.onOpen,
    required this.onCompare,
  });

  final RoleCard role;
  final VoidCallback onOpen;
  final VoidCallback? onCompare;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C5C85).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            role.roleName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF10263B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${role.company} | ${role.location} | ${role.level} | ${role.industry}',
            style: const TextStyle(
              color: Color(0xFF667F96),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: role.tags
                .map(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF4FF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        color: Color(0xFF245E94),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 14),
          Text(
            role.summary,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF31465A),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onOpen,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.babyblue,
                    side: BorderSide(color: AppColors.azure.withOpacity(0.35)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Open AI Guide',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onCompare,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.babyblue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFCFD9E3),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Compare Resume',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        children: [
          SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Loading backend role catalog...',
              style: TextStyle(color: Color(0xFF5E7487)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Could not load role catalog',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: Color(0xFF5E7487))),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
