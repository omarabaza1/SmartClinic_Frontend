/// Mock data for testing the app without a backend.
/// Used when [AppConfig.useMock] is true.
class MockData {
  MockData._();

  static List<Map<String, dynamic>> get todayAppointments => [
        {
          'id': 'apt-1',
          'doctor_name': 'Dr. Sarah',
          'doctor_image':
              'https://cdn-icons-png.flaticon.com/512/3774/3774299.png',
          'specialty': 'Dental Surgeon',
          'time': '10:00',
          'period': 'AM',
          'status': 'DELAYED',
          'status_text': 'Running ~20 min late',
          'location_info': 'Doctor Location:',
          'location_status': 'En Route',
          'is_delayed': true,
          'recommend_text': 'Recommended Arrival:',
          'recommend_time': '10:20 AM',
        },
        {
          'id': 'apt-2',
          'doctor_name': 'Dr. Alyson',
          'doctor_image':
              'https://cdn-icons-png.flaticon.com/512/3774/3774299.png',
          'specialty': 'Dermatologist',
          'time': '02:30',
          'period': 'PM',
          'status': 'ON TIME',
          'status_text': 'Schedule is clear',
          'location_info': 'Doctor is ',
          'location_status': 'At Clinic',
          'is_delayed': false,
        },
      ];

  static List<Map<String, dynamic>> get upcomingAppointments => [
        {
          'id': 'up-1',
          'month': 'Oct',
          'day': '24',
          'doctor_name': 'Dr. James',
          'details': 'Cardiologist • City Heart Center',
          'time': '09:00 AM',
          'type': 'Video Call',
        },
        {
          'id': 'up-2',
          'month': 'Nov',
          'day': '02',
          'doctor_name': 'Dr. Michael',
          'details': 'Neurologist • Neuro Care Clinic',
          'time': '11:30 AM',
          'type': 'In-Person',
        },
      ];

  static List<Map<String, dynamic>> get appointmentAlerts => [
        {
          'id': 'alert-1',
          'title': 'Update: Dr. Sarah is delayed',
          'message': 'Running approx. 15 mins late',
          'appointment_id': 'apt-1',
        },
      ];

  static List<Map<String, dynamic>> get featuredDoctors => [
        {
          'id': 'doc-1',
          'name': 'Dr. James',
          'specialty': 'Cardiologist',
          'rating': 4.9,
          'image_url':
              'https://lh3.googleusercontent.com/aida-public/AB6AXuBBQU7T6hKxC2hcykSq10KjcRPkZHwspJSoLU1W0v-UiCKVo_uYCmkeJRBdg1IS-01FhF2BdanbBDrhl-Wl2_FiU9KtlKvXjsmzmM8np5JD13uudoH4SGuJorJ7fezhWRRlYERJoyFxO06aO7puf3K3rM0eb7kfJMeV9x-oXY8xtdKE_btORHqI5ojtZxrC2DZg5iHWQdU7Eucf5FNIYpNs6aL2Yrme9ThW88DWVSO_024iokjewej7bSN4_aQPt43F4rt9-cvKw7lK',
        },
        {
          'id': 'doc-2',
          'name': 'Dr. Sarah',
          'specialty': 'Dentist',
          'rating': 4.8,
          'image_url':
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDvSE2-2HXtPvhj_kcCwOoGKvA4edYnfpZsAVFUxF4-VWXLDAlOXlsm5M4jWV0AAYEYGMGGPVd9CtkDBiHymUZr8VgtXFA7i0Az-tSL4KzvSGhlTTgf9Q325YvWYk4MEihppMrhoRbJ8EvepiZYb5BfESimova5EW0L7QszR9RqO_HkoBvsWjOX8Df33ryt4_eARDfnZv0BRlphYOOudYND-H6KnRUKyTH1hfW1neEo73zfmBVpl2aaQFj4RB1jsYleP3GAfPLz91qi',
        },
        {
          'id': 'doc-3',
          'name': 'Dr. Michael',
          'specialty': 'Neurologist',
          'rating': 4.7,
          'image_url':
              'https://lh3.googleusercontent.com/aida-public/AB6AXuAmUNXws7YrOlHnadPpwDkXMxH_Qttu9CLhaYoLg5uc0UPA_z7K0P8QISoqJl6R8z2hRz4bem-AI0wrlgPihXMmJQidrJwujCD6UOSjGGwjg4dzlB6IV4XpNIJCT5rf7i-XT_xyZyGGlVMgAKUD-djoHrSs2A554RD-A7TEO1ZVuHsIexJ9_66cYDXruDbjxlqpzElpwlony5fLRrN1m2lg3dyN4mCyB9A_ejbXDhsk8pyBxsbZAm8etfHIBBjNYOahJuUquWQRueGS',
        },
      ];

  static List<Map<String, dynamic>> get doctorsBySpecialty => [
        {
          'id': 'doc-s1',
          'name': 'Dr. Sarah Johnson',
          'title': 'Dermatology & Laser Consultant',
          'rating': 4.8,
          'reviews': 120,
          'image':
              'https://cdn-icons-png.flaticon.com/512/3774/3774299.png',
          'description':
              'Dermatology specialized in Adult Dermatology, Pediatric Dermatology, Cosmetic Dermatology...',
          'location': 'Nasr City : Ali Ameen _Moustafa El Nahas',
          'fees': '500 EGP',
          'next_available': 'Tomorrow, 1:00 PM',
          'is_today': false,
          'is_online': true,
        },
        {
          'id': 'doc-s2',
          'name': 'Dr. Maher Mahmoud',
          'title': 'Specialist in dermatology, cosmetic...',
          'rating': 5.0,
          'reviews': 89,
          'image':
              'https://cdn-icons-png.flaticon.com/512/3774/3774299.png',
          'description':
              'Specialist in Adult Dermatology, Pediatric Dermatology, Laser Therapy...',
          'location': "Maadi: Road 9, Next to McDonald's",
          'fees': '450 EGP',
          'next_available': 'Today, 6:00 PM',
          'is_today': true,
          'is_online': true,
        },
      ];

  static Map<String, dynamic>? doctorProfile(String id) => {
        'id': id,
        'name': 'Dr. Sarah Johnson',
        'rating': 4.5,
        'rating_count': 158,
        'title': 'Consultant Dermatologist, Cosmetologist and Laser',
        'fees': '600 EGP',
        'waiting_time_min': 8,
        'location': 'El-Rehab: AlRehab gate 5',
        'location_note': 'Book and you will receive the address details',
        'image_url':
            'https://cdn-icons-png.flaticon.com/512/3774/3774299.png',
        'is_online': true,
      };

  static List<Map<String, dynamic>> get timeSlots => [
        {'day_label': 'Today', 'start': '12:30 PM', 'end': '9:30 PM'},
        {'day_label': 'Tomorrow', 'start': '1:00 PM', 'end': '9:30 PM'},
        {'day_label': 'Monday 5/1', 'start': '12:30 PM', 'end': '9:30 PM'},
      ];

  static List<Map<String, dynamic>> get mostPopularSpecialties => [
        {'id': 'derm', 'name': 'Dermatology', 'subtitle': 'Skin, Hair & Nails'},
        {'id': 'dent', 'name': 'Dentistry', 'subtitle': 'Teeth & Oral Health'},
        {'id': 'psych', 'name': 'Psychiatry', 'subtitle': 'Mental Health'},
        {'id': 'ped', 'name': 'Pediatrics', 'subtitle': 'Child & Infant Care'},
      ];

  static List<Map<String, dynamic>> get otherSpecialties => [
        {'id': 'gyn', 'name': 'Gynaecology', 'subtitle': "Women's Health"},
        {'id': 'ent', 'name': 'Ear, Nose & Throat', 'subtitle': 'ENT Specialist'},
        {'id': 'card', 'name': 'Cardiology', 'subtitle': 'Heart & Vascular'},
      ];

  static Map<String, dynamic>? get currentLocation => {
        'city': 'Cairo',
        'country': 'Egypt',
        'display': 'Cairo, Egypt',
      };

  static List<Map<String, dynamic>> get cartItems => [
        {
          'id': 'cart-1',
          'product_id': 'prod-1',
          'name': 'Cough Syrup',
          'description': '150ml • Mint Flavor',
          'price': 12.50,
          'quantity': 1,
        },
        {
          'id': 'cart-2',
          'product_id': 'prod-2',
          'name': 'Aspirin 81mg',
          'description': '30 Tablets • Bayer',
          'price': 8.90,
          'quantity': 2,
        },
        {
          'id': 'cart-3',
          'product_id': 'prod-3',
          'name': 'Digital Thermometer',
          'description': 'Infrared • Non-contact',
          'price': 35.00,
          'quantity': 1,
        },
      ];

  static Map<String, dynamic>? get orderSummary => {
        'subtotal': 65.30,
        'delivery_fee': 2.50,
        'total': 67.80,
        'currency': 'USD',
      };

  static List<Map<String, dynamic>> get pharmacyCategories => [
        {
          'id': 'cat-1',
          'name': 'Featured',
          'image':
              'https://images.unsplash.com/photo-1584308666744-24d5c474f26b?auto=format&fit=crop&q=80',
          'featured': true,
        },
        {
          'id': 'cat-2',
          'name': 'Korean Products',
          'image':
              'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?auto=format&fit=crop&q=80',
        },
        {
          'id': 'cat-3',
          'name': 'Prescription',
          'image':
              'https://images.unsplash.com/photo-1576091160550-217359f41f48?auto=format&fit=crop&q=80',
        },
        {
          'id': 'cat-4',
          'name': 'Vitamins',
          'image':
              'https://images.unsplash.com/photo-1550573105-75864e3bc247?auto=format&fit=crop&q=80',
        },
        {
          'id': 'cat-5',
          'name': 'Baby Care',
          'image':
              'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&q=80',
        },
        {
          'id': 'cat-6',
          'name': 'First Aid',
          'image':
              'https://images.unsplash.com/photo-1603398938378-e54eab446ddd?auto=format&fit=crop&q=80',
        },
      ];

  static List<Map<String, dynamic>> get pharmacyProducts => [
        {
          'id': 'vit-1',
          'name': 'Vitamin C 1000mg',
          'details': '60 Tablets • Immunity',
          'price': 12.50,
          'image_url':
              'https://cdn-icons-png.flaticon.com/512/5903/5903272.png',
          'tag': 'Best Seller',
          'tag_color': 'orange',
        },
        {
          'id': 'vit-2',
          'name': 'Calcium + D3',
          'details': '30 Tablets • Bone Health',
          'price': 8.90,
          'image_url':
              'https://cdn-icons-png.flaticon.com/512/3233/3233835.png',
        },
        {
          'id': 'vit-3',
          'name': 'Multivitamins Daily',
          'details': '90 Capsules • General',
          'price': 18.70,
          'image_url':
              'https://cdn-icons-png.flaticon.com/512/2965/2965152.png',
          'discount': '-15%',
        },
        {
          'id': 'vit-4',
          'name': 'Vitamin B12',
          'details': '60 Tablets • Energy',
          'price': 15.00,
          'image_url':
              'https://cdn-icons-png.flaticon.com/512/4601/4601556.png',
        },
      ];

  static List<Map<String, dynamic>> get nearbyPharmacies => [
        {
          'id': 'ph-1',
          'name': 'Bedir Sheraton',
          'rating': 4.5,
          'delivery_fee': 'EGP 20.00',
          'image_url':
              'https://cdn-icons-png.flaticon.com/512/3063/3063176.png',
          'order_summary': '2 Items — EGP 183.00',
        },
        {
          'id': 'ph-2',
          'name': 'Bedir El-Nozha',
          'rating': 4.5,
          'delivery_fee': 'EGP 10.00',
          'image_url':
              'https://cdn-icons-png.flaticon.com/512/3063/3063176.png',
          'order_summary': '1 Item — EGP 88.00',
        },
      ];

  static List<Map<String, dynamic>> get conversations => [
        {
          'id': 'conv-1',
          'name': 'Dr. Sarah Johnson',
          'last_message': 'Hello! How can I help you today?',
          'time': '10:30 AM',
        },
        {
          'id': 'conv-2',
          'name': 'Dr. Maher Mahmoud',
          'last_message': 'Your appointment is confirmed.',
          'time': 'Yesterday',
        },
        {
          'id': 'conv-3',
          'name': 'Dr. Ali Ahmed',
          'last_message': 'Please send me the lab results.',
          'time': 'Monday',
        },
        {
          'id': 'conv-4',
          'name': 'Stitch Pharmacy',
          'last_message': 'Your order #1234 is ready.',
          'time': '2 days ago',
        },
        {
          'id': 'conv-5',
          'name': 'Dr. Emily Chen',
          'last_message': 'See you tomorrow at 10 AM.',
          'time': '1 week ago',
        },
      ];

  static List<Map<String, dynamic>> get appointmentHistory => [
        {
          'id': 'hist-1',
          'doctor_name': 'Dr. Sarah',
          'specialty': 'Dermatologist',
          'date': '2024-03-05',
          'time': '10:00 AM',
          'status': 'booked',
        },
        {
          'id': 'hist-2',
          'doctor_name': 'Dr. James',
          'specialty': 'Cardiologist',
          'date': '2024-03-01',
          'time': '09:00 AM',
          'status': 'completed',
        },
        {
          'id': 'hist-3',
          'doctor_name': 'Dr. Alyson',
          'specialty': 'Dermatologist',
          'date': '2024-02-28',
          'time': '02:30 PM',
          'status': 'completed',
        },
        {
          'id': 'hist-4',
          'doctor_name': 'Dr. Michael',
          'specialty': 'Neurologist',
          'date': '2024-02-20',
          'time': '11:00 AM',
          'status': 'cancelled',
        },
        {
          'id': 'hist-5',
          'doctor_name': 'Dr. Emily Chen',
          'specialty': 'Dentistry',
          'date': '2024-02-15',
          'time': '03:00 PM',
          'status': 'completed',
        },
        {
          'id': 'hist-6',
          'doctor_name': 'Dr. Nora Fathy',
          'specialty': 'Gynaecology',
          'date': '2024-02-01',
          'time': '10:30 AM',
          'status': 'cancelled',
        },
      ];

  static List<Map<String, dynamic>> get paymentHistory => [
        {
          'id': 'pay-1',
          'amount': 600,
          'currency': 'EGP',
          'description': 'Consultation - Dr. Sarah',
          'date': '2024-02-15',
        },
        {
          'id': 'pay-2',
          'amount': 67.80,
          'currency': 'USD',
          'description': 'Pharmacy order #1234',
          'date': '2024-02-10',
        },
      ];

  static List<Map<String, dynamic>> get aiConditions => [
        {
          'id': 'heart',
          'title': 'Heart Health',
          'subtitle': 'Arrhythmia & pulse check',
          'icon': 'favorite',
        },
        {
          'id': 'diabetes',
          'title': 'Diabetes Risk',
          'subtitle': 'Glucose level inputs',
          'icon': 'water_drop',
        },
        {
          'id': 'fever',
          'title': 'Fever',
          'subtitle': 'Temperature & symptoms',
          'icon': 'thermostat',
        },
        {
          'id': 'hypertension',
          'title': 'Hypertension',
          'subtitle': 'BP monitor log',
          'icon': 'speed',
        },
        {
          'id': 'consciousness',
          'title': 'Consciousness',
          'subtitle': 'Mental state & awareness check',
          'icon': 'psychology',
        },
      ];

  static Map<String, dynamic>? get assessmentResult => {
        'id': 'assess-1',
        'status': 'completed',
        'summary': 'General assessment completed. No critical issues detected.',
        'recommendations': ['Stay hydrated.', 'Follow up if symptoms persist.'],
        'created_at': DateTime.now().toIso8601String(),
      };
}
