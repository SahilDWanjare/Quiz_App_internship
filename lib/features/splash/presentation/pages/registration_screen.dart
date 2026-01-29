import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../registration/presentation/bloc/RegistrationBloc.dart';
import '../../../registration/presentation/bloc/RegistrationEvent.dart';
import '../../../registration/presentation/bloc/RegistrationState.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import 'home_screen_full.dart';
import 'introduction_screen.dart';

// --- Professional Palette (Same as SignIn/SignUp) ---
class AppColors {
  static const Color primaryNavy = Color(0xFF0D1B2A);
  static const Color accentTeal = Color(0xFF1B9AAA);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color silverBorder = Color(0xFFDDE1E6);
  static const Color secondaryText = Color(0xFF6D7175);
  static const Color inputBackground = Color(0xFFF5F7FA);
  static const Color inputBorder = Color(0xFFE8EAED);
  static const Color inputText = Color(0xFF5A6169);
  static const Color labelText = Color(0xFF8A9099);
}

// Country Code Model
class CountryCode {
  final String name;
  final String code;
  final String dialCode;
  final String flag;

  const CountryCode({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flag,
  });
}

// List of Country Codes
const List<CountryCode> countryCodes = [
  CountryCode(name: 'India', code: 'IN', dialCode: '+91', flag: '🇮🇳'),
  CountryCode(name: 'United States', code: 'US', dialCode: '+1', flag: '🇺🇸'),
  CountryCode(name: 'United Kingdom', code: 'GB', dialCode: '+44', flag: '🇬🇧'),
  CountryCode(name: 'Canada', code: 'CA', dialCode: '+1', flag: '🇨🇦'),
  CountryCode(name: 'Australia', code: 'AU', dialCode: '+61', flag: '🇦🇺'),
  CountryCode(name: 'Germany', code: 'DE', dialCode: '+49', flag: '🇩🇪'),
  CountryCode(name: 'France', code: 'FR', dialCode: '+33', flag: '🇫🇷'),
  CountryCode(name: 'Japan', code: 'JP', dialCode: '+81', flag: '🇯🇵'),
  CountryCode(name: 'China', code: 'CN', dialCode: '+86', flag: '🇨🇳'),
  CountryCode(name: 'Singapore', code: 'SG', dialCode: '+65', flag: '🇸🇬'),
  CountryCode(name: 'UAE', code: 'AE', dialCode: '+971', flag: '🇦🇪'),
  CountryCode(name: 'Saudi Arabia', code: 'SA', dialCode: '+966', flag: '🇸🇦'),
  CountryCode(name: 'South Africa', code: 'ZA', dialCode: '+27', flag: '🇿🇦'),
  CountryCode(name: 'Brazil', code: 'BR', dialCode: '+55', flag: '🇧🇷'),
  CountryCode(name: 'Mexico', code: 'MX', dialCode: '+52', flag: '🇲🇽'),
  CountryCode(name: 'Netherlands', code: 'NL', dialCode: '+31', flag: '🇳🇱'),
  CountryCode(name: 'Switzerland', code: 'CH', dialCode: '+41', flag: '🇨🇭'),
  CountryCode(name: 'Italy', code: 'IT', dialCode: '+39', flag: '🇮🇹'),
  CountryCode(name: 'Spain', code: 'ES', dialCode: '+34', flag: '🇪🇸'),
  CountryCode(name: 'South Korea', code: 'KR', dialCode: '+82', flag: '🇰🇷'),
];

// Designation Model
class Designation {
  final String title;
  final String category;
  final IconData icon;

  const Designation({
    required this.title,
    required this.category,
    required this.icon,
  });
}

// List of Professional Designations
const List<Designation> designations = [
  // C-Suite Executives
  Designation(title: 'CEO', category: 'C-Suite', icon: Icons.business_center),
  Designation(title: 'CFO', category: 'C-Suite', icon: Icons.account_balance),
  Designation(title: 'CTO', category: 'C-Suite', icon: Icons.computer),
  Designation(title: 'COO', category: 'C-Suite', icon: Icons.settings),
  Designation(title: 'CMO', category: 'C-Suite', icon: Icons.campaign),
  Designation(title: 'CHRO', category: 'C-Suite', icon: Icons.people),
  Designation(title: 'CIO', category: 'C-Suite', icon: Icons.storage),
  Designation(title: 'CLO', category: 'C-Suite', icon: Icons.gavel),

  // Vice Presidents
  Designation(title: 'VP of Sales', category: 'Vice President', icon: Icons.trending_up),
  Designation(title: 'VP of Marketing', category: 'Vice President', icon: Icons.campaign),
  Designation(title: 'VP of Engineering', category: 'Vice President', icon: Icons.engineering),
  Designation(title: 'VP of Finance', category: 'Vice President', icon: Icons.attach_money),
  Designation(title: 'VP of Operations', category: 'Vice President', icon: Icons.precision_manufacturing),
  Designation(title: 'VP of HR', category: 'Vice President', icon: Icons.groups),
  Designation(title: 'VP of Product', category: 'Vice President', icon: Icons.inventory_2),

  // Directors
  Designation(title: 'Director of Sales', category: 'Director', icon: Icons.point_of_sale),
  Designation(title: 'Director of Marketing', category: 'Director', icon: Icons.ads_click),
  Designation(title: 'Director of Engineering', category: 'Director', icon: Icons.code),
  Designation(title: 'Director of Finance', category: 'Director', icon: Icons.account_balance_wallet),
  Designation(title: 'Director of HR', category: 'Director', icon: Icons.badge),
  Designation(title: 'Director of IT', category: 'Director', icon: Icons.dns),
  Designation(title: 'Director of Operations', category: 'Director', icon: Icons.settings_applications),

  // Heads
  Designation(title: 'Head of Sales', category: 'Head', icon: Icons.store),
  Designation(title: 'Head of Marketing', category: 'Head', icon: Icons.mark_email_read),
  Designation(title: 'Head of Technology', category: 'Head', icon: Icons.memory),
  Designation(title: 'Head of Finance', category: 'Head', icon: Icons.payments),
  Designation(title: 'Head of HR', category: 'Head', icon: Icons.group_add),
  Designation(title: 'Head of Legal', category: 'Head', icon: Icons.policy),
  Designation(title: 'Head of Strategy', category: 'Head', icon: Icons.lightbulb),

  // Senior Management
  Designation(title: 'General Manager', category: 'Senior Management', icon: Icons.manage_accounts),
  Designation(title: 'Regional Manager', category: 'Senior Management', icon: Icons.public),
  Designation(title: 'Senior Manager', category: 'Senior Management', icon: Icons.supervisor_account),
  Designation(title: 'Program Manager', category: 'Senior Management', icon: Icons.assignment),
  Designation(title: 'Project Manager', category: 'Senior Management', icon: Icons.task_alt),
  Designation(title: 'Product Manager', category: 'Senior Management', icon: Icons.category),

  // Partners & Consultants
  Designation(title: 'Managing Partner', category: 'Partner', icon: Icons.handshake),
  Designation(title: 'Senior Partner', category: 'Partner', icon: Icons.diversity_3),
  Designation(title: 'Principal Consultant', category: 'Consultant', icon: Icons.psychology),
  Designation(title: 'Senior Consultant', category: 'Consultant', icon: Icons.support_agent),
  Designation(title: 'Management Consultant', category: 'Consultant', icon: Icons.analytics),

  // Other Senior Roles
  Designation(title: 'Founder', category: 'Entrepreneur', icon: Icons.rocket_launch),
  Designation(title: 'Co-Founder', category: 'Entrepreneur', icon: Icons.group_work),
  Designation(title: 'Board Member', category: 'Board', icon: Icons.corporate_fare),
  Designation(title: 'Advisor', category: 'Advisory', icon: Icons.tips_and_updates),
  Designation(title: 'Other', category: 'Other', icon: Icons.more_horiz),
];

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _companyController = TextEditingController();

  String _selectedGender = 'MALE';
  Designation? _selectedDesignation;
  CountryCode _selectedCountryCode = countryCodes.first; // Default to India

  // Country and City selection (replacing address)
  String? _selectedCountry;
  String? _selectedCity;

  // City data based on country
  final Map<String, List<String>> countryCities = {
    'India': [
      'Mumbai',
      'Delhi',
      'Bangalore',
      'Chennai',
      'Hyderabad',
      'Kolkata',
      'Pune',
      'Ahmedabad',
      'Jaipur',
      'Surat',
      'Lucknow',
      'Kanpur',
      'Nagpur',
      'Indore',
      'Thane',
      'Bhopal',
      'Visakhapatnam',
      'Patna',
      'Vadodara',
      'Ghaziabad',
    ],
    'United States': [
      'New York',
      'Los Angeles',
      'Chicago',
      'Houston',
      'Phoenix',
      'San Francisco',
      'Seattle',
      'Boston',
      'Miami',
      'Denver',
      'Atlanta',
      'Dallas',
      'San Diego',
      'Austin',
      'Washington D.C.',
      'Las Vegas',
      'Portland',
      'Philadelphia',
      'San Jose',
      'Detroit',
    ],
    'United Kingdom': [
      'London',
      'Manchester',
      'Birmingham',
      'Leeds',
      'Glasgow',
      'Liverpool',
      'Edinburgh',
      'Bristol',
      'Sheffield',
      'Newcastle',
      'Nottingham',
      'Leicester',
      'Cardiff',
      'Belfast',
      'Brighton',
      'Oxford',
      'Cambridge',
      'Southampton',
      'Portsmouth',
      'Reading',
    ],
    'Canada': [
      'Toronto',
      'Vancouver',
      'Montreal',
      'Calgary',
      'Ottawa',
      'Edmonton',
      'Winnipeg',
      'Quebec City',
      'Hamilton',
      'Victoria',
      'Halifax',
      'Saskatoon',
      'Regina',
      'St. John\'s',
      'Kelowna',
      'Barrie',
      'Windsor',
      'Kitchener',
      'London',
      'Oshawa',
    ],
    'Australia': [
      'Sydney',
      'Melbourne',
      'Brisbane',
      'Perth',
      'Adelaide',
      'Gold Coast',
      'Canberra',
      'Newcastle',
      'Hobart',
      'Darwin',
      'Wollongong',
      'Geelong',
      'Cairns',
      'Townsville',
      'Toowoomba',
      'Ballarat',
      'Bendigo',
      'Launceston',
      'Mackay',
      'Rockhampton',
    ],
    'Germany': [
      'Berlin',
      'Munich',
      'Frankfurt',
      'Hamburg',
      'Cologne',
      'Stuttgart',
      'Düsseldorf',
      'Leipzig',
      'Dortmund',
      'Essen',
      'Bremen',
      'Dresden',
      'Hanover',
      'Nuremberg',
      'Duisburg',
      'Bochum',
      'Wuppertal',
      'Bielefeld',
      'Bonn',
      'Münster',
    ],
    'France': [
      'Paris',
      'Marseille',
      'Lyon',
      'Toulouse',
      'Nice',
      'Nantes',
      'Strasbourg',
      'Bordeaux',
      'Montpellier',
      'Lille',
      'Rennes',
      'Reims',
      'Le Havre',
      'Toulon',
      'Grenoble',
      'Dijon',
      'Angers',
      'Nîmes',
      'Villeurbanne',
      'Clermont-Ferrand',
    ],
    'Japan': [
      'Tokyo',
      'Osaka',
      'Kyoto',
      'Yokohama',
      'Nagoya',
      'Sapporo',
      'Fukuoka',
      'Kobe',
      'Kawasaki',
      'Sendai',
      'Hiroshima',
      'Kitakyushu',
      'Chiba',
      'Sakai',
      'Niigata',
      'Hamamatsu',
      'Shizuoka',
      'Okayama',
      'Kumamoto',
      'Kagoshima',
    ],
    'China': [
      'Beijing',
      'Shanghai',
      'Shenzhen',
      'Guangzhou',
      'Chengdu',
      'Hangzhou',
      'Wuhan',
      'Xi\'an',
      'Nanjing',
      'Tianjin',
      'Suzhou',
      'Chongqing',
      'Qingdao',
      'Dalian',
      'Shenyang',
      'Zhengzhou',
      'Changsha',
      'Harbin',
      'Jinan',
      'Kunming',
    ],
    'Singapore': [
      'Singapore',
    ],
    'UAE': [
      'Dubai',
      'Abu Dhabi',
      'Sharjah',
      'Ajman',
      'Ras Al Khaimah',
      'Fujairah',
      'Umm Al Quwain',
      'Al Ain',
      'Khor Fakkan',
      'Kalba',
    ],
    'Saudi Arabia': [
      'Riyadh',
      'Jeddah',
      'Mecca',
      'Medina',
      'Dammam',
      'Khobar',
      'Tabuk',
      'Taif',
      'Buraidah',
      'Khamis Mushait',
      'Abha',
      'Najran',
      'Jubail',
      'Yanbu',
      'Hofuf',
    ],
    'South Africa': [
      'Johannesburg',
      'Cape Town',
      'Durban',
      'Pretoria',
      'Port Elizabeth',
      'Bloemfontein',
      'East London',
      'Nelspruit',
      'Kimberley',
      'Polokwane',
      'Rustenburg',
      'Pietermaritzburg',
      'George',
      'Stellenbosch',
      'Sandton',
    ],
    'Brazil': [
      'São Paulo',
      'Rio de Janeiro',
      'Brasília',
      'Salvador',
      'Fortaleza',
      'Belo Horizonte',
      'Manaus',
      'Curitiba',
      'Recife',
      'Porto Alegre',
      'Belém',
      'Goiânia',
      'Guarulhos',
      'Campinas',
      'São Luís',
    ],
    'Mexico': [
      'Mexico City',
      'Guadalajara',
      'Monterrey',
      'Puebla',
      'Tijuana',
      'León',
      'Cancún',
      'Juárez',
      'Zapopan',
      'Mérida',
      'San Luis Potosí',
      'Aguascalientes',
      'Hermosillo',
      'Saltillo',
      'Mexicali',
    ],
    'Netherlands': [
      'Amsterdam',
      'Rotterdam',
      'The Hague',
      'Utrecht',
      'Eindhoven',
      'Tilburg',
      'Groningen',
      'Almere',
      'Breda',
      'Nijmegen',
    ],
    'Switzerland': [
      'Zurich',
      'Geneva',
      'Basel',
      'Lausanne',
      'Bern',
      'Winterthur',
      'Lucerne',
      'St. Gallen',
      'Lugano',
      'Biel',
    ],
    'Italy': [
      'Rome',
      'Milan',
      'Naples',
      'Turin',
      'Palermo',
      'Genoa',
      'Bologna',
      'Florence',
      'Bari',
      'Catania',
      'Venice',
      'Verona',
      'Messina',
      'Padua',
      'Trieste',
    ],
    'Spain': [
      'Madrid',
      'Barcelona',
      'Valencia',
      'Seville',
      'Zaragoza',
      'Málaga',
      'Murcia',
      'Palma',
      'Las Palmas',
      'Bilbao',
      'Alicante',
      'Córdoba',
      'Valladolid',
      'Vigo',
      'Gijón',
    ],
    'South Korea': [
      'Seoul',
      'Busan',
      'Incheon',
      'Daegu',
      'Daejeon',
      'Gwangju',
      'Suwon',
      'Ulsan',
      'Changwon',
      'Seongnam',
      'Goyang',
      'Yongin',
      'Bucheon',
      'Ansan',
      'Cheongju',
    ],
  };

  List<String> get availableCountries => countryCities.keys.toList();

  List<String> get availableCities =>
      _selectedCountry != null ? countryCities[_selectedCountry] ?? [] : [];

  // Animation
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Track if name was auto-filled
  bool _isNameAutoFilled = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _fetchUserName();
  }

  void _setupAnimations() {
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animController.forward();
  }

  // Fetch user name from AuthBloc (from signup)
  void _fetchUserName() {
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthAuthenticated) {
      // Get the user's name from the authenticated state
      final userName = authState.displayName ?? authState.displayName ?? '';

      if (userName.isNotEmpty) {
        setState(() {
          _nameController.text = userName;
          _isNameAutoFilled = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _mobileController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  void _handleProceed() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDesignation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.info_outline, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text('Please select your designation'),
              ],
            ),
            backgroundColor: Colors.orange.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        return;
      }

      if (_selectedCountry == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.info_outline, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text('Please select your country'),
              ],
            ),
            backgroundColor: Colors.orange.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        return;
      }

      if (_selectedCity == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.info_outline, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text('Please select your city'),
              ],
            ),
            backgroundColor: Colors.orange.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        return;
      }

      final authState = context.read<AuthBloc>().state;

      if (authState is AuthAuthenticated) {
        // Combine country code with mobile number
        final fullMobileNo =
            '${_selectedCountryCode.dialCode} ${_mobileController.text.trim()}';

        context.read<RegistrationBloc>().add(
          SubmitRegistrationEvent(
            userId: authState.userId,
            name: _nameController.text.trim(),
            mobileNo: fullMobileNo,
            companyName: _companyController.text.trim(),
            designation: _selectedDesignation!.title,
            address: '$_selectedCity, $_selectedCountry',
            gender: _selectedGender,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text('User not authenticated. Please sign in again.'),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _showDesignationPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DesignationPickerSheet(
        selectedDesignation: _selectedDesignation,
        onSelected: (designation) {
          setState(() {
            _selectedDesignation = designation;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showCountryCodePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CountryCodePickerSheet(
        selectedCode: _selectedCountryCode,
        onSelected: (code) {
          setState(() {
            _selectedCountryCode = code;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showSelectionBottomSheet({
    required String title,
    required List<String> items,
    required String? selectedValue,
    required Function(String?) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _LocationPickerSheet(
        title: title,
        items: items,
        selectedValue: selectedValue,
        onSelected: (value) {
          onSelected(value);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<RegistrationBloc, RegistrationState>(
        listener: (context, state) {
          if (state is RegistrationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: Colors.red.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
          } else if (state is RegistrationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: const [
                    Icon(Icons.check_circle_outline,
                        color: Colors.white, size: 20),
                    SizedBox(width: 12),
                    Text('Registration completed successfully!'),
                  ],
                ),
                backgroundColor: Colors.green.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const IntroductionScreen(),
              ),
            );
          }
        },
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      // Header
                      const Text(
                        'Complete Your Profile',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryNavy,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.secondaryText,
                          ),
                          children: [
                            const TextSpan(text: 'Enter your '),
                            TextSpan(
                              text: 'professional details',
                              style: TextStyle(
                                color: AppColors.accentTeal,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(text: ' to continue'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Name Field (Auto-filled from signup)
                      _buildNameField(),
                      const SizedBox(height: 18),

                      // Mobile Number with Country Code
                      _buildMobileField(),
                      const SizedBox(height: 18),

                      // Company Name
                      _buildTextField(
                        controller: _companyController,
                        label: 'COMPANY NAME',
                        hint: 'Enter your company name',
                        prefixIcon: Icons.business_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your company name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      // Designation Selector
                      _buildDesignationSelector(),
                      const SizedBox(height: 18),

                      // Country & City Dropdowns (replacing Address)
                      _buildLocationSelectors(),
                      const SizedBox(height: 18),

                      // Gender Selector
                      _buildGenderSelector(),
                      const SizedBox(height: 32),

                      // Proceed Button
                      BlocBuilder<RegistrationBloc, RegistrationState>(
                        builder: (context, state) {
                          final isLoading = state is RegistrationLoading;
                          return _buildProceedButton(
                            isLoading: isLoading,
                            onPressed: isLoading ? null : _handleProceed,
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Name field with auto-fill indicator
  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'FULL NAME',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.labelText,
                letterSpacing: 1.2,
              ),
            ),
            if (_isNameAutoFilled) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accentTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 12,
                      color: AppColors.accentTeal,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Auto-filled',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentTeal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.inputText,
            fontWeight: FontWeight.w500,
          ),
          cursorColor: AppColors.accentTeal,
          decoration: InputDecoration(
            hintText: 'Enter your full name',
            hintStyle: TextStyle(
              color: AppColors.labelText.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(
              Icons.person_outline_rounded,
              color: _isNameAutoFilled
                  ? AppColors.accentTeal
                  : AppColors.labelText,
              size: 20,
            ),
            suffixIcon: _isNameAutoFilled
                ? Icon(
              Icons.verified_rounded,
              color: AppColors.accentTeal,
              size: 20,
            )
                : null,
            filled: true,
            fillColor: _isNameAutoFilled
                ? AppColors.accentTeal.withOpacity(0.05)
                : AppColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: _isNameAutoFilled
                    ? AppColors.accentTeal.withOpacity(0.3)
                    : AppColors.inputBorder,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: _isNameAutoFilled
                    ? AppColors.accentTeal.withOpacity(0.3)
                    : AppColors.inputBorder,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.accentTeal,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.red.shade400,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.red.shade400,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            errorStyle: TextStyle(
              color: Colors.red.shade600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.labelText,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.inputText,
            fontWeight: FontWeight.w500,
          ),
          cursorColor: AppColors.accentTeal,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.labelText.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: AppColors.labelText,
              size: 20,
            ),
            filled: true,
            fillColor: AppColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.inputBorder,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.inputBorder,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.accentTeal,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.red.shade400,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.red.shade400,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            errorStyle: TextStyle(
              color: Colors.red.shade600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MOBILE NUMBER',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.labelText,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Country Code Selector
            GestureDetector(
              onTap: _showCountryCodePicker,
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.inputBorder,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedCountryCode.flag,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _selectedCountryCode.dialCode,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.inputText,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.labelText,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Mobile Number Input
            Expanded(
              child: TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter mobile number';
                  }
                  if (value.length < 10) {
                    return 'Enter valid mobile number';
                  }
                  return null;
                },
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.inputText,
                  fontWeight: FontWeight.w500,
                ),
                cursorColor: AppColors.accentTeal,
                decoration: InputDecoration(
                  hintText: 'Enter mobile number',
                  hintStyle: TextStyle(
                    color: AppColors.labelText.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: const Icon(
                    Icons.phone_outlined,
                    color: AppColors.labelText,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: AppColors.inputBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.inputBorder,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.inputBorder,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.accentTeal,
                      width: 1.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.red.shade400,
                      width: 1,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.red.shade400,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  errorStyle: TextStyle(
                    color: Colors.red.shade600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesignationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DESIGNATION',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.labelText,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _showDesignationPicker,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _selectedDesignation != null
                    ? AppColors.accentTeal.withOpacity(0.5)
                    : AppColors.inputBorder,
                width: _selectedDesignation != null ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _selectedDesignation?.icon ?? Icons.work_outline,
                  color: _selectedDesignation != null
                      ? AppColors.accentTeal
                      : AppColors.labelText,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedDesignation?.title ?? 'Select your designation',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: _selectedDesignation != null
                          ? FontWeight.w500
                          : FontWeight.w400,
                      color: _selectedDesignation != null
                          ? AppColors.inputText
                          : AppColors.labelText.withOpacity(0.7),
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.labelText,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        if (_selectedDesignation != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _selectedDesignation!.category,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.accentTeal,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // Country & City Location Selectors
  Widget _buildLocationSelectors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Country Dropdown
        const Text(
          'COUNTRY',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.labelText,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        _buildDropdownSelector(
          value: _selectedCountry,
          hint: 'Select your country',
          icon: Icons.public_outlined,
          items: availableCountries,
          onChanged: (value) {
            setState(() {
              _selectedCountry = value;
              _selectedCity = null; // Reset city when country changes
            });
          },
        ),
        const SizedBox(height: 18),

        // City Dropdown
        const Text(
          'CITY',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.labelText,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        _buildDropdownSelector(
          value: _selectedCity,
          hint: _selectedCountry == null
              ? 'Select country first'
              : 'Select your city',
          icon: Icons.location_city_outlined,
          items: availableCities,
          enabled: _selectedCountry != null,
          onChanged: (value) {
            setState(() {
              _selectedCity = value;
            });
          },
        ),

        // Show selected location summary
        if (_selectedCountry != null && _selectedCity != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.accentTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.accentTeal.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  color: AppColors.accentTeal,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$_selectedCity, $_selectedCountry',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentTeal,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCountry = null;
                      _selectedCity = null;
                    });
                  },
                  child: Icon(
                    Icons.close_rounded,
                    color: AppColors.accentTeal,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDropdownSelector({
    required String? value,
    required String hint,
    required IconData icon,
    required List<String> items,
    required Function(String?) onChanged,
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled && items.isNotEmpty
          ? () => _showSelectionBottomSheet(
        title: hint.contains('country') ? 'Select Country' : 'Select City',
        items: items,
        selectedValue: value,
        onSelected: onChanged,
      )
          : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.inputBackground
              : AppColors.inputBackground.withOpacity(0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: value != null
                ? AppColors.accentTeal.withOpacity(0.5)
                : AppColors.inputBorder,
            width: value != null ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: enabled
                  ? (value != null ? AppColors.accentTeal : AppColors.labelText)
                  : AppColors.labelText.withOpacity(0.5),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value ?? hint,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: value != null ? FontWeight.w500 : FontWeight.w400,
                  color: enabled
                      ? (value != null
                      ? AppColors.inputText
                      : AppColors.labelText.withOpacity(0.7))
                      : AppColors.labelText.withOpacity(0.5),
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: enabled
                  ? AppColors.labelText
                  : AppColors.labelText.withOpacity(0.5),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'GENDER',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.labelText,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildGenderOption('MALE', Icons.male_rounded),
            const SizedBox(width: 12),
            _buildGenderOption('FEMALE', Icons.female_rounded),
            const SizedBox(width: 12),
            _buildGenderOption('OTHER', Icons.transgender_rounded),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(String gender, IconData icon) {
    final isSelected = _selectedGender == gender;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedGender = gender;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.accentTeal.withOpacity(0.1)
                : AppColors.inputBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.accentTeal : AppColors.inputBorder,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.accentTeal : AppColors.labelText,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                gender,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color:
                  isSelected ? AppColors.accentTeal : AppColors.labelText,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProceedButton({
    required bool isLoading,
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentTeal,
          foregroundColor: Colors.white,
          elevation: isLoading ? 0 : 4,
          shadowColor: AppColors.accentTeal.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onPressed,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isLoading
              ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.white,
            ),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'COMPLETE REGISTRATION',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: 0.8,
                ),
              ),
              SizedBox(width: 10),
              Icon(Icons.arrow_forward_rounded, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Designation Picker Bottom Sheet
// ============================================================================
class _DesignationPickerSheet extends StatefulWidget {
  final Designation? selectedDesignation;
  final Function(Designation) onSelected;

  const _DesignationPickerSheet({
    required this.selectedDesignation,
    required this.onSelected,
  });

  @override
  State<_DesignationPickerSheet> createState() =>
      _DesignationPickerSheetState();
}

class _DesignationPickerSheetState extends State<_DesignationPickerSheet> {
  String _searchQuery = '';
  String? _selectedCategory;

  List<String> get categories {
    return designations.map((d) => d.category).toSet().toList();
  }

  List<Designation> get filteredDesignations {
    return designations.where((d) {
      final matchesSearch =
      d.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == null || d.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
          children: [
      // Handle bar
      Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.silverBorder,
        borderRadius: BorderRadius.circular(2),
      ),
    ),

    // Header
    Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    const Text(
    'Select Designation',
    style: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryNavy,
    ),
    ),
    GestureDetector(
    onTap: () => Navigator.pop(context),
    child: Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
    color: AppColors.lightGray,
    borderRadius: BorderRadius.circular(10),
    ),
    child: const Icon(
    Icons.close_rounded,
    color: AppColors.secondaryText,
    size: 20,
    ),
    ),
    ),
    ],
    ),
    const SizedBox(height: 16),

    // Search bar
    TextField(
    onChanged: (value) {
    setState(() {
    _searchQuery = value;
    });
    },
    style: const TextStyle(
    fontSize: 15,
    color: AppColors.inputText,
    ),
    cursorColor: AppColors.accentTeal,
    decoration: InputDecoration(
    hintText: 'Search designations...',
    hintStyle: TextStyle(
    color: AppColors.labelText.withOpacity(0.7),
    fontSize: 14,
    ),
    prefixIcon: const Icon(
    Icons.search_rounded,
    color: AppColors.labelText,
    size: 20,
    ),
    filled: true,
    fillColor: AppColors.inputBackground,
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 14,
    ),
    ),
    ),
    const SizedBox(height: 12),

    // Category chips
    SizedBox(
    height: 36,
    child: ListView(
    scrollDirection: Axis.horizontal,
    children: [
    _buildCategoryChip(null, 'All'),
    ...categories.map((cat) => _buildCategoryChip(cat, cat)),
    ],
    ),
    ),
    ],
    ),
    ),

            // Designation list
            Expanded(
              child:  ListView. builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: filteredDesignations.length,
                itemBuilder: (context, index) {
                  final designation = filteredDesignations[index];
                  final isSelected =
                      widget. selectedDesignation?. title == designation.title;

                  return GestureDetector(
                    onTap: () => widget.onSelected(designation),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color:  isSelected
                            ? AppColors.accentTeal.withOpacity(0.1)
                            : AppColors.lightGray,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:  isSelected
                              ? AppColors.accentTeal
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child:  Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color:  isSelected
                                  ? AppColors.accentTeal.withOpacity(0.2)
                                  :  Colors.white,
                              borderRadius: BorderRadius. circular(10),
                            ),
                            child: Icon(
                              designation.icon,
                              color: isSelected
                                  ? AppColors. accentTeal
                                  : AppColors.secondaryText,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  designation. title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? AppColors.accentTeal
                                        :  AppColors.primaryNavy,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  designation.category,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color:  AppColors.accentTeal,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child:  const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
      ),
    );
  }

  Widget _buildCategoryChip(String? category, String label) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets. symmetric(horizontal: 14, vertical: 8),
        decoration:  BoxDecoration(
          color: isSelected ? AppColors.accentTeal : AppColors.lightGray,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.accentTeal : AppColors.silverBorder,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.secondaryText,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Country Code Picker Bottom Sheet
// ============================================================================
class _CountryCodePickerSheet extends StatefulWidget {
  final CountryCode selectedCode;
  final Function(CountryCode) onSelected;

  const _CountryCodePickerSheet({
    required this. selectedCode,
    required this.onSelected,
  });

  @override
  State<_CountryCodePickerSheet> createState() =>
      _CountryCodePickerSheetState();
}

class _CountryCodePickerSheetState extends State<_CountryCodePickerSheet> {
  String _searchQuery = '';

  List<CountryCode> get filteredCodes {
    if (_searchQuery.isEmpty) return countryCodes;
    return countryCodes. where((c) {
      return c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.dialCode.contains(_searchQuery) ||
          c. code.toLowerCase().contains(_searchQuery. toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height:  MediaQuery.of(context).size.height * 0.7,
      decoration:  const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight:  Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height:  4,
            decoration: BoxDecoration(
              color:  AppColors.silverBorder,
              borderRadius: BorderRadius. circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment. spaceBetween,
                  children:  [
                    const Text(
                      'Select Country',
                      style:  TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight. bold,
                        color: AppColors. primaryNavy,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child:  Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:  AppColors.lightGray,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: AppColors.secondaryText,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Search bar
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.inputText,
                  ),
                  cursorColor: AppColors.accentTeal,
                  decoration: InputDecoration(
                    hintText: 'Search country.. .',
                    hintStyle: TextStyle(
                      color: AppColors.labelText.withOpacity(0.7),
                      fontSize:  14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.labelText,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: AppColors. inputBackground,
                    border: OutlineInputBorder(
                      borderRadius:  BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Country list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filteredCodes.length,
              itemBuilder: (context, index) {
                final code = filteredCodes[index];
                final isSelected = widget. selectedCode. code == code.code;

                return GestureDetector(
                  onTap: () => widget.onSelected(code),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color:  isSelected
                          ? AppColors.accentTeal.withOpacity(0.1)
                          : AppColors.lightGray,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:  isSelected
                            ? AppColors.accentTeal
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          code.flag,
                          style: const TextStyle(fontSize: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment. start,
                            children: [
                              Text(
                                code.name,
                                style:  TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color:  isSelected
                                      ? AppColors.accentTeal
                                      : AppColors.primaryNavy,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                code.code,
                                style: TextStyle(
                                  fontSize:  12,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          code.dialCode,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight. w700,
                            color: isSelected
                                ? AppColors. accentTeal
                                : AppColors.inputText,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration:  BoxDecoration(
                              color: AppColors.accentTeal,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size:  16,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
// ============================================================================
// Location Picker Bottom Sheet
// ============================================================================
class _LocationPickerSheet extends StatefulWidget {
  final String title;
  final List<String> items;
  final String? selectedValue;
  final Function(String) onSelected;

  const _LocationPickerSheet({
    required this.title,
    required this.items,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  State<_LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<_LocationPickerSheet> {
  String _searchQuery = '';

  List<String> get filteredItems {
    if (_searchQuery.isEmpty) return widget.items;
    return widget.items
        .where((item) => item.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.silverBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.lightGray,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: AppColors.secondaryText,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Search bar
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.inputText,
                  ),
                  cursorColor: AppColors.accentTeal,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: TextStyle(
                      color: AppColors.labelText.withOpacity(0.7),
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.labelText,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: AppColors.inputBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Items list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                final isSelected = widget.selectedValue == item;

                return GestureDetector(
                  onTap: () => widget.onSelected(item),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.accentTeal.withOpacity(0.1)
                          : AppColors.lightGray,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.accentTeal
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          widget.title.contains('Country')
                              ? Icons.public_rounded
                              : Icons.location_city_rounded,
                          color: isSelected
                              ? AppColors.accentTeal
                              : AppColors.secondaryText,
                          size: 22,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.accentTeal
                                  : AppColors.primaryNavy,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.accentTeal,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}