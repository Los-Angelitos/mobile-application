import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sweetmanager/OrganizationalManagement/models/hotel.dart';
import 'package:sweetmanager/OrganizationalManagement/models/multimedia.dart';
import 'package:sweetmanager/OrganizationalManagement/services/hotel_service.dart';
import 'package:sweetmanager/OrganizationalManagement/views/hotel_detail.dart';
import 'package:sweetmanager/OrganizationalManagement/widgets/custom_app_bar.dart';
import 'package:sweetmanager/OrganizationalManagement/widgets/search_bar.dart';
import 'package:sweetmanager/OrganizationalManagement/widgets/category_tabs.dart';
import 'package:sweetmanager/OrganizationalManagement/widgets/hotel_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  HotelService hotelService = HotelService();

  int selectedCategoryIndex = 0;
  TextEditingController searchController = TextEditingController();
  List<Hotel> hotels = [];
  List<Hotel> filteredHotels = [];
  Map<int, Multimedia> multimediaList = {};
  Map<int, Multimedia> logoList = {};
  Map<int, List<Multimedia>> multimediaDetailList = {};


  final List<CategoryTab> categories = [
    CategoryTab(
      icon: SvgPicture.asset('assets/icons/trophy_icon.svg', width: 24, height: 24),
      label: 'Featured'
    ),
    CategoryTab(
      icon: SvgPicture.asset('assets/icons/lake_icon.svg', width: 24, height: 24),
      label: 'Near a lake'
    ),
    CategoryTab(
      icon: SvgPicture.asset('assets/icons/pool_icon.svg', width: 24, height: 24),
      label: 'With pool'
    ),
    CategoryTab(
      icon: SvgPicture.asset('assets/icons/beach_icon.svg', width: 24, height: 24),
      label: 'Near the beach'
    ),
    CategoryTab(
      icon: SvgPicture.asset('assets/icons/rural_icon.svg', width: 24, height: 24),
      label: 'Rural Hotel'
    ),
    CategoryTab(
      icon: SvgPicture.asset('assets/icons/bed_icon.svg', width: 24, height: 24),
      label: 'Master Bedroom'
    ),
  ];
  final List<String> categoryValues = [
    'FEATURED',
    'NEAR_THE_LAKE',
    'WITH_A_POOL',
    'NEAR_THE_BEACH',
    'RURAL_HOTEL',
    'SUITE'
  ];


  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    hotels = await hotelService.getHotels();
  
    for (var hotel in hotels) {
      Multimedia? multimediaMain = await hotelService.getMainHotelMultimedia(hotel.id);
      Multimedia? logo = await hotelService.getHotelLogoMultimedia(hotel.id);

      List<Multimedia> multimediaDetails = await hotelService.getHotelDetailMultimedia(hotel.id);

      if (multimediaMain != null) {
        multimediaList[hotel.id] = multimediaMain;
      }
      if (logo != null) {
        logoList[hotel.id] = logo;
      }

      if (multimediaDetails.isNotEmpty) {
        multimediaDetailList[hotel.id] = multimediaDetails;
      } else {
        multimediaDetailList[hotel.id] = [];
      } 
    }
    print('Loaded $hotels');

    filteredHotels = hotels;
    setState(() {});
  }

  void filterHotels(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredHotels = hotels;
      } else {
        filteredHotels = hotels.where((hotel) {
          return hotel.name.toLowerCase().contains(query.toLowerCase()) ||
                 hotel.address.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> onCategorySelected(int index) async {
  setState(() {
    selectedCategoryIndex = index;
  });

  if (index == 0) {
    // Featured: cargar todos los hoteles
    hotels = await hotelService.getHotels();
  } else {
    String selectedCategory = categoryValues[index];
    print('Selected category: $selectedCategory');
    hotels = await hotelService.getHotelByCategory(selectedCategory);
    print('Hotels in category $selectedCategory: $hotels');
  }

  // Limpia los datos previos
  multimediaList.clear();
  logoList.clear();
  multimediaDetailList.clear();

  for (var hotel in hotels) {
    Multimedia? multimediaMain = await hotelService.getMainHotelMultimedia(hotel.id);
    Multimedia? logo = await hotelService.getHotelLogoMultimedia(hotel.id);
    List<Multimedia> multimediaDetails = await hotelService.getHotelDetailMultimedia(hotel.id);

    if (multimediaMain != null) multimediaList[hotel.id] = multimediaMain;
    if (logo != null) logoList[hotel.id] = logo;
    multimediaDetailList[hotel.id] = multimediaDetails;
  }

  filteredHotels = hotels;
  setState(() {});
}

  void onHotelTap(Hotel hotel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HotelDetailScreen(hotel: hotel, 
          multimediaMain: multimediaList.isNotEmpty ? multimediaList[hotel.id] : null,
          multimediaLogo: logoList.isNotEmpty ? logoList[hotel.id] : null,
          multimediaDetails: multimediaDetailList.isNotEmpty ? multimediaDetailList[hotel.id] : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: 'Sweet Manager',
        onNotificationTap: () {
          // Handle notification tap
        },
        onMenuTap: () {
          // Handle menu tap
        },
      ),
      body: Column(
        children: [
          CustomSearchBar(
            hintText: 'What will be your next destination?',
            controller: searchController,
            onSearch: filterHotels,
          ),
          CategoryTabs(
            tabs: categories,
            selectedIndex: selectedCategoryIndex,
            onTabSelected: onCategorySelected,
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75, // Ajusta la proporción altura/ancho de las cards
              ),
              itemCount: filteredHotels.length,
              itemBuilder: (context, index) {
                return HotelCard(
                  hotel: filteredHotels[index],
                  multimedia: multimediaList.isNotEmpty && index < multimediaList.length
                      ? multimediaList[filteredHotels[index].id]
                      : null,
                  logo: logoList.isNotEmpty && index < logoList.length
                      ? logoList[filteredHotels[index].id]
                      : null,
                  
                  onTap: () => onHotelTap(filteredHotels[index]),
                );
              },
            ),
          ),

        ],
      ),
    );
  }
}
