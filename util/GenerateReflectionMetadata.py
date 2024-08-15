import xml.etree.ElementTree as ET
import json

from pathlib import Path

def metadeta_json(xml_file: Path, json_file: Path):
    tree = ET.parse(xml_file)
    root = tree.getroot()

    res_json = {}

    for class_meta in root.findall(".//*[@class='ReflectionMetadataClass']"):
        name = None
        properties = {}
        
        for prop in class_meta.find('Properties'):
            prop_name = prop.attrib['name']

            if prop_name == 'Name':
                name = prop.text
            elif prop_name == 'ExplorerOrder':
                properties[prop_name] = int(prop.text)
            elif prop_name in ['ClassCategory', 'ExplorerOrder', 'PreferredParent']:
                properties[prop_name] = prop.text

        if name and properties:
            res_json[name] = properties

    # Write to JSON file
    with open(json_file, 'w') as f:
        json.dump(res_json, f, indent=2)

def main():
    reflection_metadata_path = Path("latest_roblox_version_path_here/ReflectionMetadata.xml")
    out_path = Path("./src/PluginProxy/Services/ReflectionService/metadata.json").resolve()

    if not reflection_metadata_path.exists():
        raise ValueError("Please enter the correct path for ReflectionMetadata.xml")

    metadeta_json(reflection_metadata_path, out_path)

if __name__ == "__main__":
    main()