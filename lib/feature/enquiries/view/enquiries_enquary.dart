import 'package:di360_flutter/core/app_mixin.dart';
import 'package:di360_flutter/feature/job_listings/model/job_applicants_respo.dart';
import 'package:flutter/material.dart';


class EnquiriesEnquary extends StatelessWidget with BaseContextHelpers {
  final JobApplicants applicant;

  const EnquiriesEnquary({super.key, required this.applicant});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "Enquiry",
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),

                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (applicant.jobEnquiries != null &&
                            applicant.jobEnquiries!.isNotEmpty)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: applicant.jobEnquiries!.length,
                            itemBuilder: (context, index) {
                              final JobEnquiries enquiry =
                                  applicant.jobEnquiries![index];

                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 24,
                                  backgroundImage: applicant.dentalProfessional
                                              ?.profileImage?.url !=
                                          null
                                      ? NetworkImage(applicant
                                          .dentalProfessional!
                                          .profileImage!
                                          .url!)
                                      : null,
                                  child: applicant.dentalProfessional
                                              ?.profileImage?.url ==
                                          null
                                      ? const Icon(Icons.person, size: 24)
                                      : null,
                                ),
                                title: Text(enquiry.enquiryDescription ?? ""),
                              );
                            },
                          )
                        else
                          const Text("No enquiries found"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
