import os
import math
import time
import struct
from pathlib import Path
from typing import List, Tuple
from dataclasses import dataclass
from PIL import Image

@dataclass
class AtlasInfo:
    total_area: int
    max_height: int
    min_size: int

class ImageAtlasCreator:
    def __init__(self, output_path: Path, base_directory: Path, subdirs: List[str] = None):
        self.output_path = Path(output_path)
        self.base_directory = Path(base_directory)
        self.subdirs = subdirs
        self.output_path.mkdir(parents=True, exist_ok=True)

    @staticmethod
    def next_power_of_2(n: int) -> int:
        return 2 ** math.ceil(math.log2(n))

    @staticmethod
    def get_image_size(file_path: Path) -> Tuple[int, int]:
        try:
            with open(file_path, 'rb') as f:
                f.seek(16)
                width, height = struct.unpack('>II', f.read(8))
            return (width, height)
        except Exception:
            print(f"Couldn't read image resolution: {file_path}")
            return None
        
    @staticmethod
    def format_atlas_order(items: List[str], newline_count: int = 4) -> str:
        formatted_items = [f"{item}={i}" for i, item in enumerate(items)]

        el_total = len(formatted_items)
        elements_per_line = -(-el_total // newline_count)

        result = ""
        for i, item in enumerate(formatted_items):
            if i > 0 and i % elements_per_line == 0:
                result += "\n\t"
            result += item
            if i < el_total - 1:
                result += ", "

        return f"{{\n\t{result}\n}}"
    
    def get_atlas_info(self, files: List[Path]) -> AtlasInfo:
        total_area = sum(self.get_image_size(f)[0] * self.get_image_size(f)[1] for f in files)
        max_height = max(self.get_image_size(f)[1] for f in files)

        return AtlasInfo(
            total_area = total_area,
            max_height = max_height,
            min_size = self.next_power_of_2(math.ceil(math.sqrt(total_area)))
        )

    def atlas_from_files(self, files: List[Path], info: AtlasInfo, max_size: int = 1024) -> Tuple[Image.Image, int, List[Path]]:
        """Creates an atlas with a `max_size`, if it is reached, then returns the remaining images"""
        atlas_size = min(info.min_size, max_size)
        atlas = Image.new('RGBA', (atlas_size, atlas_size))

        remaining_files = []
        x_offset = y_offset = row_height = 0
        for f in files:
            with Image.open(f) as img:
                if x_offset + info.max_height > atlas_size:
                    x_offset, y_offset = 0, y_offset + row_height
                    row_height = 0
                
                if y_offset + info.max_height > atlas_size:
                    remaining_files = files[files.index(f):]
                    break

                atlas.paste(img, (x_offset, y_offset))
                x_offset += info.max_height
                row_height = max(row_height, info.max_height)

        return atlas, atlas_size, remaining_files
    
    def atlases_from_files(self, files: List[Path]) -> List[Tuple[Image.Image, int]]:
        """Creates an atlas with a `max_size`, if it is reached, then remaining images overflow into new atlas"""
        atlases = []
        remaining_files = files
        while remaining_files:
            info = self.get_atlas_info(remaining_files)
            atlas, size, remaining_files = self.atlas_from_files(remaining_files, info)
            atlases.append((atlas, size))

        return atlases

    def get_images(self, img_dir: Path, target_size: int, glob_match: str, max_depth: int = 2) -> List[Path]:
        images = []
        for root, _, files in os.walk(img_dir):
            depth = root[len(str(img_dir)):].count(os.sep)
            if depth > max_depth:
                continue
            
            for file in files:
                if file.lower().endswith('.png'):
                    img_path = Path(root) / file
                    if glob_match and not img_path.match(glob_match):
                        continue

                    if self.get_image_size(img_path)[0] == target_size:
                        images.append(img_path)

        return images

    def get_theme_images_from_subdirs(self, theme: str, target_size: int, glob_match: str) -> List[Path]:
        images = []

        direct_theme_path = self.base_directory / theme
        if not self.subdirs and direct_theme_path.is_dir():
            images.extend(self.get_images(direct_theme_path, target_size, glob_match))
            return images

        dirs_to_search = [self.base_directory / subdir for subdir in self.subdirs] if self.subdirs else [d for d in self.base_directory.iterdir() if d.is_dir()]
        for subdir in dirs_to_search:
            subdir_path = self.base_directory / subdir if isinstance(subdir, str) else subdir
            if not subdir_path.is_dir():
                print(f"Skipping {subdir}: not a directory")
                continue

            theme_path = subdir_path / theme
            if not theme_path.is_dir():
                print(f"Skipping {subdir}: {theme} theme not found")
                continue
            
            images.extend(self.get_images(theme_path, target_size, glob_match))

        return images

    def atlas_from_categories(self, target_size: int, out_name: str = "New Atlas", glob_match: str = None, save_info: bool = False):
        print(f"------ {out_name} ------")

        start_time = time.perf_counter()

        dark_images = self.get_theme_images_from_subdirs("Dark", target_size, glob_match)
        light_images = self.get_theme_images_from_subdirs("Light", target_size, glob_match)

        print(f"Image retrieval took: {time.perf_counter() - start_time:.3f}s")

        if len(dark_images) != len(light_images):
            dark_set = set([f.stem for f in dark_images])
            light_set = set([f.stem for f in light_images])
            set_dif = dark_set - light_set if len(dark_images) > len(light_images) else light_set - dark_set
            raise ValueError(f"Number of Dark and Light images don't match,\nmismatched elements are: \n{list(set_dif)}")
        
        if len(dark_images) == 0:
            raise ValueError(f"No images found in path '{self.base_directory}'")
        
        dark_images.sort()
        light_images.sort()

        atlas_order = [img.stem.removesuffix('@2x').removesuffix('@3x') for img in dark_images]
        all_images = dark_images + light_images

        start_time = time.perf_counter()

        atlases = self.atlases_from_files(all_images)
        print(f"Creation took: {time.perf_counter() - start_time:.3f}s\n")

        has_multiple = len(atlases) > 1
        for i, (atlas, size) in enumerate(atlases):
            num_id = f"_{i+1}" if has_multiple else ""
            atlas_out = self.output_path / f"{out_name}{num_id}.png"

            atlas.save(atlas_out)
            print(f"Atlas {f"{i+1} " if has_multiple else ""}size: {size}x{size}")

        if save_info:
            atlas_info_out = self.output_path / f"{out_name} info.txt"
            atlas_info_out.write_text(self.format_atlas_order(atlas_order))

        return self



def main():
    out_path = Path("enter_your_export_path_here")
    texture_path = Path("latest_roblox_version_path_here/content/studio_svg_textures")

    if not out_path.is_dir():
        raise ValueError("Please enter the correct path for outputting the atlas")
    if not texture_path.is_dir():
        raise ValueError("Please enter the correct path for your Roblox Studio studio_svg_textures path")
    
    # Atlas order must contain only half of the true amount of images, because the other half is the other theme variant
    
    # Size variants may contain icons that do not exist elsewhere (Standard (16x16) / Medium (24x24) / Large (32x32))
    # They need to be handled seperately and require generating a new atlas order for each size

    # Scale on the other hand only effects the resolution of the image (2x, 3x), it doesn't make any other changes
    # That means, if we need to produce a higher resolution icon atlas, the atlas order does not need to be regenerated


    # Some images are too large to be rendered by Roblox with full resolution (currently anything higher than 1024)
    # When this limit is reached, multiple atlases are created to compensate, these can be linked together to form a bigger atlas
    # In the future 4k or 8k textures might get support, in which case the default value for `max_size` in function `atlas_from_files` can be increased to match these limits
    # However mobile support should still be taken into consideration if, for example, 4k textures do not come to mobile platforms

    (ImageAtlasCreator(out_path, texture_path / "Shared/InsertableObjects")
        .atlas_from_categories(16, "Classes [x16]", "**/Standard/*", True)
        .atlas_from_categories(48, "Classes [x48]", "**/Standard/*")
        .atlas_from_categories(64, "Classes [Large x64]", "**/Large/*", True))
    
    (ImageAtlasCreator(out_path, texture_path / "Shared", subdirs = [
            "Alerts",
            "Clipboard",
            "Debugger",
            "DraggerTools",
            "Modeling",
            "Navigation",
            "Notifications",
            "Placeholder",
            "Utility",
            "WidgetIcons"
        ])
        .atlas_from_categories(16, "Other [x16]", "**/Standard/*", True)
        .atlas_from_categories(48, "Other [x48]", "**/Standard/*")
        .atlas_from_categories(64, "Other [Large x64]", "**/Large/*", True))

if __name__ == "__main__":
    main()