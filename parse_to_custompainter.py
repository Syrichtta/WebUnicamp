import json

def parse_geojson_to_flutter_points(geojson_path, canvas_width, canvas_height):
    """
    Parse GeoJSON and convert coordinates into Flutter CustomPainter points.
    
    Args:
        geojson_path (str): Path to the GeoJSON file.
        canvas_width (float): Target Flutter canvas width.
        canvas_height (float): Target Flutter canvas height.
        
    Returns:
        List[Dict]: List of buildings with Flutter-compatible points.
    """
    with open(geojson_path, 'r') as f:
        data = json.load(f)
    
    # Extract all building polygons
    buildings = []
    for feature in data['features']:
        if feature['geometry']['type'] in ['Polygon', 'MultiPolygon']:
            if feature['geometry']['type'] == 'Polygon':
                coordinates = feature['geometry']['coordinates']
            elif feature['geometry']['type'] == 'MultiPolygon':
                coordinates = [poly[0] for poly in feature['geometry']['coordinates']]
            
            buildings.append(coordinates)
    
    # Flatten all coordinates and calculate bounding box
    all_coords = [
        coord for building in buildings for polygon in building for coord in polygon
    ]
    lons, lats = zip(*all_coords)
    min_lon, max_lon = min(lons), max(lons)
    min_lat, max_lat = min(lats), max(lats)
    
    # Normalize and scale coordinates
    def transform_coordinates(lon, lat):
        x = (lon - min_lon) / (max_lon - min_lon) * canvas_width
        y = (lat - min_lat) / (max_lat - min_lat) * canvas_height
        return round(x, 2), round(canvas_height - y, 2)  # Flip Y for Flutter's coordinate system

    # Convert buildings to Flutter points
    flutter_buildings = []
    for building in buildings:
        flutter_building = []
        for polygon in building:
            flutter_polygon = [transform_coordinates(lon, lat) for lon, lat in polygon]
            flutter_building.append(flutter_polygon)
        flutter_buildings.append(flutter_building)
    
    return flutter_buildings

# Save the Flutter-compatible points to a Dart file
def save_to_dart(flutter_buildings, output_path):
    """
    Save the Flutter-compatible points to a Dart file.
    
    Args:
        flutter_buildings (List[Dict]): Parsed Flutter-compatible points.
        output_path (str): Path to save the Dart file.
    """
    with open(output_path, 'w') as f:
        f.write('final List<List<List<Offset>>> buildings = [\n')
        for building in flutter_buildings:
            f.write('  [\n')
            for polygon in building:
                f.write('    [\n')
                for x, y in polygon:
                    f.write(f'      Offset({x}, {y}),\n')
                f.write('    ],\n')
            f.write('  ],\n')
        f.write('];\n')

# Example usage
geojson_path = "export.geojson"  # Replace with your GeoJSON file
canvas_width = 500.0  # Canvas width in Flutter
canvas_height = 500.0  # Canvas height in Flutter
output_path = "building_points.dart"

# Parse and save
flutter_buildings = parse_geojson_to_flutter_points(geojson_path, canvas_width, canvas_height)
save_to_dart(flutter_buildings, output_path)

print(f"Building points saved to {output_path}")
