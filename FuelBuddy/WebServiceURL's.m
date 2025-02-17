//
//  WebServiceURL's.m
//  FuelBuddy
//
//  Created by Swapnil on 13/10/17.
//  Copyright © 2017 Oraganization. All rights reserved.
//

#import "WebServiceURL's.h"
///*
//New_8 changesDone
//Prod Env
NSString *const kVehDataScript = @"http://simplyauto.app/DatabaseScripts/veh_data_v2.php";
NSString *const kServiceDataScript = @"http://simplyauto.app/DatabaseScripts/service_data_v2.php";
NSString *const kLogDataScript = @"http://simplyauto.app/DatabaseScripts/log_data_v3.php";
NSString *const kDeleteCloudSyncTableScript = @"http://simplyauto.app/DatabaseScripts/del_from_sync_data.php";
NSString *const kLocationScript = @"http://simplyauto.app/DatabaseScripts/loc_data_v2.php";
NSString *const kPullDataScript = @"http://simplyauto.app/DatabaseScripts/pull_data_v4.php";
NSString *const kProfileScript = @"http://simplyauto.app/DatabaseScripts/profile_data_v4.php";
NSString *const kSettingsScript = @"http://simplyauto.app/DatabaseScripts/settings_data_v2.php";
NSString *const kFullUploadScript = @"http://simplyauto.app/DatabaseScripts/full_upload.php";
NSString *const kImageUploadScript = @"http://simplyauto.app/DatabaseScripts/image_upload_v2.php";
NSString *const kFullDownloadScript = @"http://simplyauto.app/DatabaseScripts/full_download_v2.php";
NSString *const kDeleteProfileScript = @"http://simplyauto.app/DatabaseScripts/delete_profile_v3.php";
NSString *const kSearchFriendScript = @"http://www.simplyauto.app/DatabaseScripts/search_friend_v3.php";
NSString *const kConfirmFriendRequestScript = @"http://www.simplyauto.app/DatabaseScripts/confirm_friend_request_v3.php";
NSString *const kFriendRequestScript = @"http://www.simplyauto.app/DatabaseScripts/friend_request_v3.php";
NSString *const kFriendDeleteScript = @"http://www.simplyauto.app/DatabaseScripts/delete_friend_v3.php";
NSString *const kFullSyncRequestScript = @"http://www.simplyauto.app/DatabaseScripts/full_sync.php";
NSString *const kFriendSyncDataScript = @"http://www.simplyauto.app/DatabaseScripts/sync_data_v2.php";
NSString *const kAppKillTimeStampCheckScript = @"http://www.simplyauto.app/DatabaseScripts/val_timestamp.php";
NSString *const kGoProScript = @"http://www.simplyauto.app/DatabaseScripts/go_pro.php";
NSString *const kSubscriptionScript = @"http://www.simplyauto.app/DatabaseScripts/user_ios_purchase.php";
NSString *const kReportCSVScript = @"https://www.simplyauto.app/DatabaseScripts/report_raw_csv.php";
NSString *const kReportPDFScript = @"https://www.simplyauto.app/DatabaseScripts/report_raw_pdf.php";
NSString *const kReportReceiptScript = @"https://www.simplyauto.app/DatabaseScripts/report.php";
NSString *const kReportBigGraphScript = @"https://www.simplyauto.app/DatabaseScripts/report_graph.php";
NSString *const kReportSmallGraphScript = @"https://www.simplyauto.app/DatabaseScripts/report_graph_sparkline.php";
NSString *const kReportEmailBodyScript = @"https://www.simplyauto.app/DatabaseScripts/report_email_body.php";
NSString *const kReportScheduleScript = @"https://www.simplyauto.app/DatabaseScripts/schedule_report.php";
NSString *const kFeedBackScript = @"https://www.simplyauto.app/DatabaseScripts/emailcomment.php";
NSString *const kSupportScript = @"https://www.simplyauto.app/DatabaseScripts/support.php";

NSString *const kSubscriptionValidationScript = @"https://www.simplyauto.app/DatabaseScripts/user_ios_purchase_check.php";
NSString *const kServiceRatingScript = @"https://www.simplyauto.app/DatabaseScripts/scr_rating.php";
/*/
//Test Env
NSString *const kVehDataScript = @"http://simplyauto.app/DatabaseScriptsTemp/veh_data_v2.php";
NSString *const kServiceDataScript = @"http://simplyauto.app/DatabaseScriptsTemp/service_data_v2.php";
NSString *const kLogDataScript = @"http://simplyauto.app/DatabaseScriptsTemp/log_data_v3.php";
NSString *const kDeleteCloudSyncTableScript = @"http://simplyauto.app/DatabaseScriptsTemp/del_from_sync_data_v2.php";
NSString *const kLocationScript = @"http://simplyauto.app/DatabaseScriptsTemp/loc_data_v2.php";
NSString *const kPullDataScript = @"http://simplyauto.app/DatabaseScriptsTemp/pull_data_v4.php";
NSString *const kProfileScript = @"http://simplyauto.app/DatabaseScriptsTemp/profile_data_v4.php";
NSString *const kSettingsScript = @"http://simplyauto.app/DatabaseScriptsTemp/settings_data_v2.php";
NSString *const kFullUploadScript = @"http://simplyauto.app/DatabaseScriptsTemp/full_upload.php";
NSString *const kImageUploadScript = @"http://simplyauto.app/DatabaseScriptsTemp/image_upload_v2.php";
NSString *const kFullDownloadScript = @"http://simplyauto.app/DatabaseScriptsTemp/full_download_v2.php";
NSString *const kDeleteProfileScript = @"http://simplyauto.app/DatabaseScriptsTemp/delete_profile_v3.php";
NSString *const kSearchFriendScript = @"http://www.simplyauto.app/DatabaseScriptsTemp/search_friend_v3.php";
NSString *const kConfirmFriendRequestScript = @"http://www.simplyauto.app/DatabaseScriptsTemp/confirm_friend_request_v3.php";
NSString *const kFriendRequestScript = @"http://www.simplyauto.app/DatabaseScriptsTemp/friend_request_v3.php";
NSString *const kFriendDeleteScript = @"http://www.simplyauto.app/DatabaseScriptsTemp/delete_friend_v3.php";
NSString *const kFullSyncRequestScript = @"http://www.simplyauto.app/DatabaseScriptsTemp/full_sync.php";
NSString *const kFriendSyncDataScript = @"http://www.simplyauto.app/DatabaseScriptsTemp/sync_data_v2.php";
NSString *const kAppKillTimeStampCheckScript = @"http://www.simplyauto.app/DatabaseScriptsTemp/val_timestamp.php";
NSString *const kGoProScript = @"http://www.simplyauto.app/DatabaseScriptsTemp/go_pro.php";
NSString *const kSubscriptionScript = @"http://www.simplyauto.app/DatabaseScriptsTemp/user_ios_purchase.php";
NSString *const kReportCSVScript = @"https://www.simplyauto.app/DatabaseScriptsTemp/report_raw_csv.php";
NSString *const kReportPDFScript = @"https://www.simplyauto.app/DatabaseScriptsTemp/report_raw_pdf.php";
NSString *const kReportReceiptScript = @"https://www.simplyauto.app/DatabaseScriptsTemp/report.php";
NSString *const kReportBigGraphScript = @"https://www.simplyauto.app/DatabaseScriptsTemp/report_graph.php";
NSString *const kReportSmallGraphScript = @"https://www.simplyauto.app/DatabaseScriptsTemp/report_graph_sparkline.php";
NSString *const kReportEmailBodyScript = @"https://www.simplyauto.app/DatabaseScriptsTemp/report_email_body.php";
NSString *const kReportScheduleScript = @"https://www.simplyauto.app/DatabaseScriptsTemp/schedule_report.php";
NSString *const kFeedBackScript = @"https://www.simplyauto.app/DatabaseScriptsTemp/emailcomment.php";
NSString *const kSupportScript = @"https://www.simplyauto.app/DatabaseScriptsTemp/support.php";

NSString *const kSubscriptionValidationScript = @"https://www.simplyauto.app/DatabaseScriptsTemp/user_ios_purchase_check.php";
NSString *const kServiceRatingScript = @"https://www.simplyauto.app/DatabaseScriptsTemp/scr_rating.php";
//*/

@implementation WebServiceURL_s

@end
