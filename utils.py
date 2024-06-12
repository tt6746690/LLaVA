import os
import json



def copy_answers_for_upload(result_dir='./results', upload_dir='./playground/data/answers_upload', pattern='mmbench_dev_*.xlsx'):
    """Copy answers for task such as MMBench to a folder so that it's easier for rsync/upload.
    
        ```
        from utils import copy_answers_for_upload
        copy_answers_for_upload(
            result_dir='./results/',
            upload_dir='./playground/data/answers_upload',
            pattern='mmbench_dev_*.xlsx',
        )
        ```
    """

    import fnmatch
    import shutil

    os.makedirs(upload_dir, exist_ok=True)

    matches = []
    for root, dirs, files in os.walk(result_dir):
        for filename in fnmatch.filter(files, pattern):
            relative_path = os.path.relpath(os.path.join(root, filename), result_dir)
            relative_path_split = relative_path.split('/')
            name = '#'.join(relative_path_split[:-3] + relative_path_split[-1:])
            relative_path = os.path.join(result_dir, relative_path)
            if '/mmbench/' in relative_path:
                task_name = 'mmbench'
            else:
                raise ValueError(f"{relative_path} not sure what task it is.")
            matches.append((name, task_name, relative_path))

    for name, task_name, src in matches:
        task_dir = os.path.join(upload_dir, task_name)
        os.makedirs(task_dir, exist_ok=True)
        dst = os.path.join(task_dir, name)
        shutil.copy(src, dst)
        print(f"Copy {src}\n\t->{dst}")





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
