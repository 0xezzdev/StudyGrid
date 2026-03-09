import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:study_grid/core/colors/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:study_grid/feature/file_page.dart/widgets/delete_file_dialog.dart';
import 'package:study_grid/feature/file_page.dart/widgets/empty_files_state.dart';
import 'package:study_grid/feature/file_page.dart/widgets/file_card.dart';
import '../../core/models/class_file.dart';
import '../../core/services/file_service.dart';

class FilesPage extends StatefulWidget {
  final String usserRole;

  final int groupId;
  const FilesPage({super.key, required this.groupId, required this.usserRole});

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  final _fileService = FileService();
  List<ClassFile> _files = [];
  bool _isLoading = true;
  bool get _isAdmin => widget.usserRole == 'admin';
  bool _isUploading = false;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _initAndStream();
  }

  Future<void> _initAndStream() async {
    // جرب تخليها true علطول عشان نختبر الزرار
    //setState(() => _isAdmin = true);

    _sub = _fileService.filesStream(widget.groupId).listen((files) {
      if (!mounted) return;
      setState(() {
        _files = files;
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  // ── Admin check ────────────────────────────────────────────────────────────

  // Future<void> _checkAdmin() async {
  //   final admin = await _fileService.isAdmin(widget.groupId);
  //   if (mounted) setState(() => _isAdmin = admin);
  // }

  // ── Stream ─────────────────────────────────────────────────────────────────

  void _startStream() {
    _sub = _fileService.filesStream(widget.groupId).listen((files) {
      if (!mounted) return;
      setState(() {
        _files = files;
        _isLoading = false;
      });
    });
  }

  // ── Upload ─────────────────────────────────────────────────────────────────

  Future<void> _uploadFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      // allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx'],
    );
    if (result == null || result.files.isEmpty) return;

    final picked = result.files.first;
    if (picked.path == null) return;

    setState(() => _isUploading = true);
    try {
      await _fileService.uploadFile(
        widget.groupId,
        File(picked.path!),
        picked.name,
        picked.extension?.toLowerCase() ?? 'file',
      );
      if (!mounted) return;
      _showSnack(
        '${picked.name} uploaded',
        AppColors.darkGreenColor,
        AppColors.greenColor,
        Icons.check_circle_outline,
      );
    } catch (_) {
      if (!mounted) return;
      _showSnack(
        'Upload failed',
        AppColors.purplecolor,
        AppColors.sentMessageMainColor,
        Icons.error_outline,
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // ── Delete ─────────────────────────────────────────────────────────────────

  void _deleteFile(ClassFile file) {
    DeleteFileDialog.show(
      context,
      file: file,
      onConfirm: () async {
        try {
          await _fileService.deleteFile(file);
          if (!mounted) return;
          _showSnack(
            '${file.name} deleted',
            AppColors.purplecolor,
            AppColors.sentMessageMainColor,
            Icons.delete_outline,
          );
        } catch (_) {
          if (!mounted) return;
          _showSnack(
            'Delete failed',
            AppColors.purplecolor,
            AppColors.sentMessageMainColor,
            Icons.error_outline,
          );
        }
      },
    );
  }

  // ── Download ───────────────────────────────────────────────────────────────

  Future<void> _downloadFile(ClassFile file) async {
    if (file.url == null) return;
    final Uri uri = Uri.parse(file.url!);

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      _showSnack(
        'Could not launch browser',
        AppColors.purplecolor,
        AppColors.sentMessageMainColor,
        Icons.error_outline,
      );
      print("Error launching URL: $e");
    }
  }
  // ── Snackbar ───────────────────────────────────────────────────────────────

  void _showSnack(String msg, Color bg, Color iconColor, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _formatTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('MMM d').format(t);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,

      floatingActionButton: _isAdmin
          ? Padding(
              padding: const EdgeInsets.only(bottom: 80.0),
              child: _buildFab(),
            )
          : null,

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppColors.purplecolor),
            )
          : _files.isEmpty
          ? const EmptyFilesState()
          : _buildFileList(),
    );
  }

  AppBar _buildAppBar() => AppBar(
    backgroundColor: AppColors.itemsColor,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white70),
      onPressed: () => Navigator.pop(context),
    ),
    title: const Text(
      'Files',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    actions: [
      if (_isAdmin)
        Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.purplecolor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.purplecolor.withOpacity(0.4)),
          ),
          child: Text(
            'Admin',
            style: TextStyle(
              color: AppColors.purplecolor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
    ],
  );

  Widget _buildFab() => FloatingActionButton.extended(
    onPressed: _isUploading ? null : _uploadFile,
    backgroundColor: AppColors.purplecolor,
    icon: _isUploading
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
        : const Icon(Icons.upload_file_rounded, color: Colors.white),
    label: Text(
      _isUploading ? 'Uploading...' : 'Upload File',
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    ),
  );

  Widget _buildFileList() => ListView.builder(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
    itemCount: _files.length,
    itemBuilder: (_, i) => FileCard(
      file: _files[i],
      formattedTime: _formatTime(_files[i].uploadedAt),
      isAdmin: _isAdmin,
      onDelete: _isAdmin ? () => _deleteFile(_files[i]) : null,
      onDownload: () => _downloadFile(_files[i]),
    ),
  );
}
