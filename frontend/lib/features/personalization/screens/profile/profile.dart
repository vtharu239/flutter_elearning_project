import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/common/styles/section_heading.dart';
import 'package:flutter_elearning_project/common/widgets/appbar/appbar.dart';
import 'package:flutter_elearning_project/config/api_constants.dart';
import 'package:flutter_elearning_project/features/personalization/controllers/auth_controller.dart';
import 'package:flutter_elearning_project/features/personalization/controllers/profile_controller.dart';
import 'package:flutter_elearning_project/features/personalization/screens/profile/component/change_email_dialog.dart';
import 'package:flutter_elearning_project/features/personalization/screens/profile/component/change_password_dialog.dart';
import 'package:flutter_elearning_project/features/personalization/screens/profile/component/edit_date_dialog.dart';
import 'package:flutter_elearning_project/features/personalization/screens/profile/component/edit_gender_dialog.dart';
import 'package:flutter_elearning_project/features/personalization/screens/profile/component/profile_dialog.dart';
import 'package:flutter_elearning_project/features/personalization/screens/profile/component/image_options_sheet.dart';
import 'package:flutter_elearning_project/features/personalization/screens/profile/component/image_viewer_dialog.dart';
import 'package:flutter_elearning_project/features/personalization/screens/profile/widgets/profile_menu.dart';
import 'package:flutter_elearning_project/utils/constants/image_strings.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController profileController = Get.put(ProfileController());
  final AuthController authController = Get.find();

  void _showEditDialog(BuildContext context, String field) {
    final user = authController.user.value;
    if (user == null) return;

    switch (field) {
      case 'fullName':
        showDialog(
          context: context,
          builder: (context) => EditFieldDialog(
            title: 'Họ và tên',
            initialValue: user.fullName.isEmpty ? null : user.fullName,
            onSave: (value) => profileController.updateProfile(fullName: value),
          ),
        );
        break;

      case 'username':
        showDialog(
          context: context,
          builder: (context) => EditFieldDialog(
            title: 'Tên người dùng',
            initialValue: user.username.isEmpty ? null : user.username,
            onSave: (value) => profileController.updateProfile(username: value),
          ),
        );
        break;

      case 'phoneNo':
        showDialog(
          context: context,
          builder: (context) => EditFieldDialog(
            title: 'Số điện thoại',
            initialValue: user.phoneNo.isEmpty ? null : user.phoneNo,
            keyboardType: TextInputType.phone,
            onSave: (value) => profileController.updateProfile(phoneNo: value),
          ),
        );
        break;

      case 'gender':
        showDialog(
          context: context,
          builder: (context) => EditGenderDialog(
            initialValue: user.gender,
            onSave: (value) => profileController.updateProfile(gender: value),
          ),
        );
        break;

      case 'dateOfBirth':
        showDialog(
          context: context,
          builder: (context) => EditDateDialog(
            initialDate: user.dateOfBirth != null
                ? DateTime.parse(user.dateOfBirth!)
                : DateTime.now(),
            onSave: (value) => profileController.updateProfile(
              dateOfBirth: value.toIso8601String(),
            ),
          ),
        );
        break;
    }
  }

  // Show image options bottom sheet
  void _showImageOptions(BuildContext context, String type) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(TSizes.cardRadiusLg)),
      ),
      builder: (context) => TImageOptionsSheet(
        onView: () => _viewImage(context, type),
        onEdit: () => _editImage(type),
      ),
    );
  }

  // View image in full screen dialog
  void _viewImage(BuildContext context, String type) {
    final user = authController.user.value;
    if (user == null) return;

    final imageUrl = type == 'avatar' ? user.avatarUrl : user.coverImageUrl;
    final defaultImage = type == 'avatar' ? TImages.user : TImages.defaultCover;

    showDialog(
      context: context,
      builder: (context) => TImageViewerDialog(
        imageUrl: imageUrl != null ? ApiConstants.getUrl(imageUrl) : '',
        isNetworkImage: imageUrl != null,
        defaultImage: defaultImage,
      ),
    );
  }

  // Edit image (existing upload logic)
  void _editImage(String type) {
    profileController.pickAndUploadImage(type);
  }

  // Thêm phương thức hiển thị dialog đổi mật khẩu
  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => const ChangePasswordDialog(),
    );
  }

  // Thêm phương thức hiển thị dialog đổi email
  void _showChangeEmailDialog() {
    final user = authController.user.value;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (context) => ChangeEmailDialog(currentEmail: user.email),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GetBuilder<ProfileController>(
      builder: (controller) => Scaffold(
        appBar:
            const TAppBar(showBackArrow: true, title: Text('Hồ sơ cá nhân')),
        backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,

        /// -- Body
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            child: Column(
              children: [
                /// Cover Image Section
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // Cover Image with Edit Icon
                    Obx(() => Stack(
                          children: [
                            // Cover Image
                            Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: authController
                                              .user.value?.coverImageUrl !=
                                          null
                                      ? NetworkImage(
                                          ApiConstants.getUrl(authController
                                              .user.value!.coverImageUrl!),
                                          headers: {
                                            'cache-control': 'no-cache'
                                          },
                                        )
                                      : const AssetImage(TImages.defaultCover)
                                          as ImageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            // Cover Image Edit Button
                            Positioned(
                              top: 10,
                              right: 10,
                              child: CircleAvatar(
                                backgroundColor: Colors.white.withValues(alpha: 0.8),
                                child: IconButton(
                                  icon: const Icon(Iconsax.edit,
                                      color: Colors.blue),
                                  onPressed: profileController
                                          .isCoverLoading.value
                                      ? null
                                      : () =>
                                          _showImageOptions(context, 'cover'),
                                ),
                              ),
                            ),
                            // Loading Overlay
                            if (profileController.isCoverLoading.value)
                              Container(
                                width: double.infinity,
                                height: 200,
                                color: Colors.black45,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.white),
                                ),
                              ),
                          ],
                        )),
                    // Avatar
                    Positioned(
                      bottom: -20,
                      child: Obx(
                        () => Stack(
                          children: [
                            // Avatar
                            CircleAvatar(
                              radius: 50,
                              backgroundImage:
                                  authController.user.value?.avatarUrl != null
                                      ? NetworkImage(
                                          ApiConstants.getUrl(authController
                                              .user.value!.avatarUrl!),
                                          headers: {
                                            'cache-control': 'no-cache'
                                          },
                                        )
                                      : const AssetImage(TImages.user)
                                          as ImageProvider,
                            ),
                            // Loading Overlay
                            if (profileController.isAvatarLoading.value)
                              Container(
                                width: 100,
                                height: 100,
                                decoration: const BoxDecoration(
                                  color: Colors.black45,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.white),
                                ),
                              ),
                            // Avatar Edit Button
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.blue,
                                  child: IconButton(
                                    icon: const Icon(Icons.edit,
                                        size: 16, color: Colors.white),
                                    onPressed:
                                        profileController.isAvatarLoading.value
                                            ? null
                                            : () => _showImageOptions(
                                                context, 'avatar'),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 50),

                /// Details
                const Divider(),
                const SizedBox(height: TSizes.spaceBtwItems),

                /// Heading Profile Info
                const TSectionHeading(
                    title: "Thông tin hồ sơ", showActionButton: false),
                const SizedBox(height: TSizes.spaceBtwItems),

                Obx(() {
                  final user = authController.user.value;
                  if (user == null) return const SizedBox();

                  return Column(
                    children: [
                      TProfileMenu(
                        title: 'Họ và tên',
                        value: user.fullName,
                        onPressed: () => _showEditDialog(context, 'fullName'),
                      ),
                      TProfileMenu(
                        title: 'Tên người dùng',
                        value: user.username,
                        onPressed: () => _showEditDialog(context, 'username'),
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      const Divider(),
                      const SizedBox(height: TSizes.spaceBtwItems),

                      /// Heading Personal Info
                      const TSectionHeading(
                          title: "Thông tin cá nhân", showActionButton: false),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      TProfileMenu(
                        title: 'E-mail',
                        value: user.email,
                        onPressed: _showChangeEmailDialog,
                      ),
                      TProfileMenu(
                        title: 'Số điện thoại',
                        value: user.phoneNo,
                        onPressed: () => _showEditDialog(context, 'phoneNo'),
                      ),
                      TProfileMenu(
                        title: 'Giới tính',
                        value: user.gender == 'male'
                            ? 'Nam'
                            : user.gender == 'female'
                                ? 'Nữ'
                                : 'Khác',
                        onPressed: () => _showEditDialog(context, 'gender'),
                      ),
                      TProfileMenu(
                        title: 'Ngày sinh',
                        value: user.dateOfBirth != null
                            ? DateFormat('dd/MM/yyyy')
                                .format(DateTime.parse(user.dateOfBirth!))
                            : 'Chưa cập nhật',
                        onPressed: () =>
                            _showEditDialog(context, 'dateOfBirth'),
                      ),
                    ],
                  );
                }),
                const Divider(),
                const SizedBox(height: TSizes.spaceBtwItems),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _showChangePasswordDialog,
                        icon: const Icon(Icons.lock_outline),
                        label: const Text('Đổi mật khẩu'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
