import os
import json


def datasets_check_image_exists_on_disk(data_path, image_folder):
    """llava-1.5 665k dataset sometimes has missing images. 
        Use this function to figure out which file is missing. 
        
        ```
        from utils import datasets_check_image_exists_on_disk
        for data_path in [
                './data/liuhaotian/LLaVA-Instruct-150K/llava_v1_5_mix665k.json',
            ]:
            L = datasets_check_image_exists_on_disk(data_path, image_folder='./data')
            assert(len(L) == 0)
        ```
    """
    
    list_data_dict = json.load(open(data_path, "r"))
    print(f'#examples: {len(list_data_dict)}')

    def file_missing(example):
        if 'image' in example:
            image_file = example['image']
            image_path = os.path.join(image_folder, image_file)
            return not os.path.isfile(image_path)
        else:
            # text-only example, assume file is not missing.
            return False

    list_data_dict_file_missing = list(filter(file_missing, list_data_dict))

    if len(list_data_dict_file_missing) != 0:
        print(f'#missing images: {len(list_data_dict_file_missing)}')

    return list_data_dict_file_missing
