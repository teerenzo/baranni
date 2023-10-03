import 'dart:ui';
// //Images EndPoint
// const String kImgEndPoint = 'https://bcclic.com/powr/';

// //Responsive constants
const TextDirection kTextDirection = TextDirection.rtl;
const kHorizontalPadding = 15.0;
// //Responsive constants

//Colors
const Color kScaffoldColor = Color(0xFF02020F);
const Color darkScaffoldBG = Color(0xff262729);
const Color kPrimarySwatch = Color(0xFF02020F);
const Color kPrimaryColor = Color(0xFF242529);
const Color kSecondaryColor = Color(0xFF313134);
const Color kColor1 = Color(0xFFFFFFFF);
const Color kColor1P = Color(0xFFE0E4EB);
const Color kColor2 = Color(0xFF939393);
const kSuccessColor = Color(0xFF7ED321);
const Color kAlertColor = Color(0xFFCE181E);
const Color kYellowColor = Color(0xFFFFC20E);
const Color kHintTextColor = Color(0xFF5D5D5D);
const Color kTransparent = Color(0xFF000000);
const Color kBluColor = Color(0xFF3978de);
// //Colors

// spacing
const double sp4 = 4.0;
const double sp5 = 5.0;
const double sp6 = 6.0;
const double sp7 = 7.0;
const double sp8 = 8.0;
const double sp9 = 9.0;
const double sp10 = 10.0;
const double sp12 = 12.0;
const double sp14 = 14.0;
const double sp15 = 15.0;
const double sp16 = 16.0;
const double sp18 = 18.0;
const double sp20 = 20.0;
const double sp22 = 22.0;
const double sp24 = 24.0;
const double sp25 = 25.0;
const double sp26 = 26.0;
const double sp200 = 200.0;

// flex spacing
const int columnSp = 12;
const double flxSpacing = 24;

// alignment
const TextAlign textAlignment = TextAlign.right;
const String rowAlign = "reversed";

// //Fonts
const String kArFontFamily = 'Almarai';
const String kEnFontFamily = 'Montserrat';
const String aFontFamily = kArFontFamily;
const FontWeight kArRegularFontWeight = FontWeight.w400;
const FontWeight kArBoldFontWeight = FontWeight.w700;
const FontWeight kEnBoldFontWeight = FontWeight.w600;
// //Fonts

// //LineHeight
const double kH5LH = 1.75;

// //font size
const double kSize60 = 32.5;
const double kSize40 = 21.5;
const double kSize32 = 16.2;
const double kSize30 = 15.8;
const double kSize30P = 13.8;
const double kSize23 = 13.5;
const double kSize21 = 12.0;
const double kSize19 = 11;
const double kSize17 = 10;
// //font size

// //User
// String? uid;
// //User

// //topBar
// const kIconTopBarSize = 22;
// const kMarginAmongIcons = 20;
// const double kAppBarOpacity = 0.97;
// const double kAppBarHeight = 80.0;
// const double kLogoHeight = 29;

// //BottomBar sizes
// const kIconBottomBarSize = 22;
// const kIconBottomBarHM = 16;
// const kIconBottomBarTM = 12;
// const kIconBottomBarBM = 12;

const String profileImageUrl = '';

// //Margins
const double kMg90 = 50.0;
const double kMg90P = 45.0;
const double kMg40 = 18.0;
const double kMg32 = 20;
const double kHorizontalMgPlus = 4;
const double kMgBottomScreen = 40;
const double kMgVipBadge = 7;
// //Margin

// //Padding
const double kPd8 = 4.4;
// //Padding

// //Radius
const double kRd22 = 12.1;
const double kRd20 = 11.0;
const double kRd16 = 8.8;
const double kRd14 = 7.7;
const double kRd10 = 5.5;
const double kRd8 = 5.0;
// //Radius

// //user Img Size
const double kUserLeaderboardImg = 46.0;
const double kUserFeedImg = 42.0;
const double kUserInteractionImg = 22.0;

// //Names
const String kClassic = 'CLASSIC';
const String kVip = 'VIP';

// //Button icon size
const double kButtonIconSize = 19.0;
const double kSmallButtonWidth = 132.0;
const double kSmallButtonHeight = 45.0;
const double kProfileIconSize = 18;

// //Divers
// const String kCurrency = 'ر.س';

// //Border
const double kBorderOpacity = 0.85;
const double kBorderSize8 = 4.0;
const double kBorderSize5 = 2.5;
const double kBorderSize3 = 2;

//input
const kDefaultFormError = '* مطلوب';
const kSmallTextFieldCountSize = 44;
const kBigTextFieldCountSize = 500;
const kTopMgFormInput = 15;
const kTopMgFormButton = 23;

const double kBigCircleButton = 70.0;
const double kBigCircleIconSize = 20.0;

//topBar
const kDefaultIconAppBarSize = 22.0;
const kMarginAmongIcons = 20;
const double kAppBarOpacity = 0.97;
const double kAppBarHeight = 80.0;
const double kLogoHeight = 29;
const double kAppBarIconSize = 14.5;

class FireBaseCollections {
  final String appointments = 'appointments';
  final String chatMessages = 'chatMessages';
  final String invitations = 'invitations';
  final String notifications = 'notifications';
  final String userInvitations = 'userInvitations';
  final String users = 'users';
  final String zones = 'zones';
  final String project = 'project';
  final String products = 'products';
  final String categories = 'categories';
  final String groups = 'groups';
}

FireBaseCollections fireBaseCollections = FireBaseCollections();
