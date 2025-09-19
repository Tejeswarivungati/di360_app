//import 'package:di360_flutter/feature/job_profile/model/job_profile.dart';
import 'package:di360_flutter/feature/job_profile_listing/repository/job_profile_respo_impl.dart';
import 'package:di360_flutter/feature/talents/model/job_profile.dart';
import 'package:di360_flutter/utils/alert_diaglog.dart';
import 'package:di360_flutter/utils/loader.dart';
import 'package:flutter/material.dart';

class JobProfileListingViewModel extends ChangeNotifier {
  final JobProfileRepoImpl repo = JobProfileRepoImpl();

  final List<String> statuses = [
    'DRAFT',
    'PENDING',
    'ACTIVE',
    'INACTIVE',
    'REJECTED',
  ];

  final Map<String, String> statusDisplayNames = {
    'DRAFT': 'Draft',
    'PENDING': 'Pending Approval',
    'ACTIVE': 'Active',
    'INACTIVE': 'Inactive',
    'REJECTED': 'Rejected',
  };

  String? selectedStatus;
  List<JobProfile> allJobProfiles = [];
  bool isLoading = false;
  Future<void> fetchJobProfiles() async {
    isLoading = true;
    try {
      final response = await repo.getJobProfiles();
      allJobProfiles = response;
      if (allJobProfiles.isNotEmpty) {
        selectedStatus = allJobProfiles.first.adminStatus?.toUpperCase() ?? '';
      }
    } catch (e) {
      allJobProfiles = [];
      selectedStatus = null;
    }
    isLoading = false;
    notifyListeners();
  }

  List<JobProfile> get filteredProfiles {
    if (selectedStatus == null) return allJobProfiles;
    return allJobProfiles
        .where((job) => (job.adminStatus ?? '').toUpperCase() == selectedStatus)
        .toList();
  }

  String displayName(String status) {
    return statusDisplayNames[status.toUpperCase()] ?? status;
  }

  Future<void> updateJobProfileStatus(
      BuildContext context, String? id, String status) async {
    Loaders.circularShowLoader(context);
    final res = await repo.updateJobProfile(id, status);
    if (!context.mounted) return;
    if (res != null) {
      scaffoldMessenger('JobListingData updated successfully');
      await fetchJobProfiles();
    } else {
      scaffoldMessenger('Failed to update JobListingData');
    }
    if (context.mounted) {
      Loaders.circularHideLoader(context);
    }
    notifyListeners();
  }

  Future<void> removeJobsProfileData(BuildContext context) async {
    Loaders.circularShowLoader(context);
    final res = await repo.removeJobProfile();
    if (res != null) {
      scaffoldMessenger('JobListingData removed successfully');
      await fetchJobProfiles();
    } else {
      scaffoldMessenger('Failed to remove JobListingData');
    }
    notifyListeners();
  }
}
