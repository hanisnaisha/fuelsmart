import 'package:flutter/material.dart';

class FuelCostScreen extends StatefulWidget {
  const FuelCostScreen({super.key});

  @override
  State<FuelCostScreen> createState() => FuelCostScreenState();
}

enum VehicleType { car, van, lorry }

class VehicleInfo {
  final String name;
  final String fuelType;
  final double efficiency; // km/L

  VehicleInfo({
    required this.name,
    required this.fuelType,
    required this.efficiency,
  });
}

class FuelCostScreenState extends State<FuelCostScreen> {
  final TextEditingController distanceController = TextEditingController();
  final TextEditingController efficiencyController = TextEditingController();

  // State variables
  VehicleType selectedVehicle = VehicleType.car;
  String fuelType = 'RON95'; 
  double selectedPrice = 2.60;
  String result = '';
  String errorMessage = '';

  // Fuel prices (RM/L)
  final Map<String, double> fuelPrices = {
    'RON95': 2.60,
    'RON97': 3.14,
    'Diesel': 2.89,
  };

  // Vehicle information
  final Map<VehicleType, VehicleInfo> vehicleInfo = {
    VehicleType.car: VehicleInfo(
      name: 'Car',
      fuelType: 'Petrol',
      efficiency: 0.0, 
    ),
    VehicleType.van: VehicleInfo(
      name: 'Van',
      fuelType: 'Diesel',
      efficiency: 0.0, 
    ),
    VehicleType.lorry: VehicleInfo(
      name: 'Lorry',
      fuelType: 'Diesel',
      efficiency: 0.0, 
    ),
  };

  @override
  void initState() {
    super.initState();
    updateVehicleSettings();
  }

  void updateVehicleSettings() {
    final vehicle = vehicleInfo[selectedVehicle]!;
    setState(() {
      // Update fuel type based on vehicle
      if (vehicle.fuelType == 'Petrol') {
        fuelType = 'RON95'; // Default to RON95 for petrol
        selectedPrice = fuelPrices['RON95']!;
      } else {
        fuelType = 'Diesel';
        selectedPrice = fuelPrices['Diesel']!;
      }
    });
  }

  @override
  void dispose() {
    distanceController.dispose();
    efficiencyController.dispose();
    super.dispose();
  }

  /// Calculate fuel cost using the formula: (Distance / Efficiency) * Price
  void calculateFuelCost() {
    setState(() {
      errorMessage = '';
      result = '';

      // Get input value
      final distanceText = distanceController.text.trim();
      final efficiencyOverrideText = efficiencyController.text.trim();

      // Validate distance input
      if (distanceText.isEmpty) {
        errorMessage = 'Please enter the distance';
        return;
      }

      final distance = double.tryParse(distanceText);

      if (distance == null) {
        errorMessage = 'Please enter a valid distance number';
        return;
      }

      if (distance <= 0) {
        errorMessage = 'Distance must be greater than zero';
        return;
      }

      // Validate efficiency input
      if (efficiencyOverrideText.isEmpty) {
        errorMessage = 'Please enter fuel efficiency';
        return;
      }

      final efficiencyValue = double.tryParse(efficiencyOverrideText);
      if (efficiencyValue == null) {
        errorMessage = 'Please enter a valid efficiency (km/L)';
        return;
      }

      if (efficiencyValue <= 0) {
        errorMessage = 'Efficiency must be greater than zero';
        return;
      }

      double effectiveEfficiency = efficiencyValue;

      final fuelCost = (distance / effectiveEfficiency) * selectedPrice;

      result = 'RM${fuelCost.toStringAsFixed(2)}';

      // Clear any previous error
      errorMessage = '';
    });
  }
  
  void clearInputs() {
    setState(() {
      distanceController.clear();
      efficiencyController.clear();
      result = '';
      errorMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = vehicleInfo[selectedVehicle]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Fuel Cost Estimator'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with Logo
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.black, width: 3.0),
              ),
              child: Image.asset(
                'assets/images/logo.png',
                height: 150,
                width: 150,
              ),
            ),
            const SizedBox(height: 30),

            // Vehicle Type dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.directions_car_filled,
                        color: Color(0xFF8B0000),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Vehicle Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  DropdownButton<VehicleType>(
                    value: selectedVehicle,
                    underline: Container(),
                    items: VehicleType.values.map((type) {
                      final info = vehicleInfo[type]!;
                      return DropdownMenuItem(
                        value: type,
                        child: Row(
                          children: [
                            Text(
                              info.name,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '(${info.fuelType})',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedVehicle = value!;
                        updateVehicleSettings();
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Distance input
            buildInputField(
              label: 'Distance (km)',
              controller: distanceController,
              icon: Icons.route,
            ),
            const SizedBox(height: 20),

            // Fuel efficiency input
            buildInputField(
              label: 'Fuel Efficiency (km/L) *',
              controller: efficiencyController,
              icon: Icons.speed,
            ),
            const SizedBox(height: 20),

            // Fuel Type & Price dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.local_gas_station,
                        color: Color(0xFF8B0000),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Fuel Price',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  DropdownButton<String>(
                    value: fuelType,
                    underline: Container(),
                    items:
                        (vehicle.fuelType == 'Petrol'
                                ? ['RON95', 'RON97']
                                : ['Diesel'])
                            .map((fuel) {
                              return DropdownMenuItem(
                                value: fuel,
                                child: Text(
                                  '$fuel (RM${fuelPrices[fuel]!.toStringAsFixed(2)}/litre)',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              );
                            })
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        fuelType = value!;
                        selectedPrice = fuelPrices[fuelType]!;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Error message (if any)
            if (errorMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),

            // Calculate button
            ElevatedButton(
              onPressed: calculateFuelCost,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B0000), 
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calculate),
                  SizedBox(width: 10),
                  Text(
                    'Calculate',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),

            // Result display
            if (result.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Estimated Fuel Cost',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      result,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Clear button
            OutlinedButton(
              onPressed: clearInputs,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.clear),
                  SizedBox(width: 10),
                  Text('Clear All', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Helper method to build input text fields
  Widget buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF8B0000)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: label,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
