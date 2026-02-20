import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Centralized icon registry for the Kaya app.
///
/// All icons rendered in the application MUST go through this class.
/// No other file should reference `Icons` or `CupertinoIcons` directly.
///
/// On iOS, Cupertino icons are used where an appropriate counterpart exists.
/// On Android (and all other platforms), Material icons are used.
class KayaIcon {
  KayaIcon._();

  static bool get _isIOS => Platform.isIOS;

  // Navigation & chrome
  static IconData get menu => Icons.menu;
  static IconData get home => _isIOS ? CupertinoIcons.home : Icons.home;
  static IconData get account =>
      _isIOS ? CupertinoIcons.profile_circled : Icons.account_circle;
  static IconData get add =>
      _isIOS ? CupertinoIcons.add_circled_solid : Icons.add;
  static IconData get search => _isIOS ? CupertinoIcons.search : Icons.search;
  static IconData get clear => Icons.clear;
  static IconData get chevronRight => Icons.chevron_right;

  // Actions
  static IconData get share => _isIOS ? CupertinoIcons.share_up : Icons.share;
  static IconData get download =>
      _isIOS ? CupertinoIcons.cloud_download : Icons.download;
  static IconData get openInBrowser => Icons.open_in_browser;
  static IconData get sync =>
      _isIOS ? CupertinoIcons.arrow_2_squarepath : Icons.sync;
  static IconData get testConnection => Icons.wifi_tethering;
  static IconData get refresh => Icons.refresh;
  static IconData get email => Icons.email;

  // Content types
  static IconData get bookmark =>
      _isIOS ? CupertinoIcons.bookmark_fill : Icons.bookmark;
  static IconData get bookmarkBorder => Icons.bookmark_border;
  static IconData get web => Icons.web;
  static IconData get pdf =>
      _isIOS ? CupertinoIcons.doc_richtext : Icons.picture_as_pdf;
  static IconData get video => Icons.video_file;
  static IconData get image => Icons.image;
  static IconData get file => Icons.insert_drive_file;
  static IconData get playCircle => Icons.play_circle_outline;

  // Media playback
  static IconData get play => Icons.play_arrow;
  static IconData get pause => Icons.pause;

  // Status & feedback
  static IconData get warningAmber => Icons.warning_amber_rounded;
  static IconData get error => Icons.error;
  static IconData get warning => Icons.warning;
  static IconData get errorOutline => Icons.error_outline;
  static IconData get checkCircleOutline => Icons.check_circle_outline;
  static IconData get searchOff => Icons.search_off;
  static IconData get cloudSync => Icons.cloud_sync;
  static IconData get cloudDone => Icons.cloud_done;
  static IconData get cloudOff => Icons.cloud_off;

  // Account & settings
  static IconData get visibilityOff =>
      _isIOS ? CupertinoIcons.eye_slash_fill : Icons.visibility_off;
  static IconData get visibility =>
      _isIOS ? CupertinoIcons.eye_fill : Icons.visibility;
  static IconData get bugReport => Icons.bug_report;

  // Destructive / editing
  static IconData get delete => Icons.delete;
  static IconData get deleteSweep => Icons.delete_sweep;
  static IconData get deleteOutline => Icons.delete_outline;

  // Misc
  static IconData get descriptionOutlined => Icons.description_outlined;
}
