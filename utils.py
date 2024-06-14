import os
import json
import re
import pandas as pd



class TaskResult:

    def __init__(self, save_dir, task_name=None):
        self.save_dir = save_dir
        self.task_name = os.path.basename(save_dir) if task_name is None else task_name

    def read_file(self, filename):
        path = os.path.join(self.save_dir, filename)
        if not os.path.isfile(path):
            return None
        if filename.endswith('csv'):
            return pd.read_csv(path)
        else:
            with open(path, 'r') as f:
                s = f.read()
            if filename.endswith('.json'):
                return json.loads(s)
            else:
                return s

    def get_metrics(self):
        method_name = f'get_metrics_{self.task_name}'
        if not getattr(self, method_name):
            raise ValueError(f'{method_name} not supported.')
        return getattr(self, method_name)()
        
    def get_metrics_gqa(self):
        metrics = {'accuracy': None}
        s = self.read_file('bash_script_log.txt')
        if s is None: return metrics
        match = re.search(r"Accuracy: (\d+\.\d+)%", s)
        if not match: return metrics
        metrics['accuracy'] = float(match.group(1))
        return metrics

    def get_metrics_scienceqa(self):
        metrics = {'accuracy': None, 'accuracy(image)': None}
        s = self.read_file('bash_script_log.txt')
        if s is None: return metrics
        match1 = re.search(r" Accuracy: (\d+\.\d+)%", s)
        match2 = re.search(r" IMG-Accuracy: (\d+\.\d+)%", s)
        if not (match1 and match2): return metrics
        metrics['accuracy'] = float(match1.group(1))
        metrics['accuracy(image)'] = float(match2.group(1))
        return metrics

    def get_metrics_textvqa(self):
        metrics = {'accuracy': None}
        s = self.read_file('bash_script_log.txt')
        if s is None: return metrics
        match = re.search(r"Accuracy: (\d+\.\d+)%", s)
        if not match: return metrics
        metrics['accuracy'] = float(match.group(1))
        return metrics

    def get_metrics_vqav2(self):
        metrics = {"number": None, "other": None, "overall": None, "yes/no": None}
        s = self.read_file('eval_server_result.json')
        if s is None: return metrics
        metrics = s[0]['test-dev']
        return metrics

    def get_metrics_vizwiz(self):
        metrics = {"number": None, "other": None, "overall": None, "unanswerable": None, "yes/no": None}
        s = self.read_file('eval_server_result.json')
        if s is None: return metrics
        metrics = s[0]['test-dev']
        metrics = dict(sorted(metrics.items()))
        return metrics

    def get_metrics_pope(self):
        metrics = {'popular': {'F1 score': None},
                   'adversarial': {'F1 score': None},
                   'random': {'F1 score': None},}
        s = self.read_file('bash_script_log.txt')
        if s is None: return metrics
        for category in s.split("===================================="):
            if "Category:" in category:
                lines = category.strip().split("\n")
                category_name = re.search(r"Category: (\w+)", lines[0]).group(1)
                samples = int(re.search(r"# samples: (\d+)", lines[0]).group(1))
                tp, fp, tn, fn = map(int, lines[2].split())
                metrics[category_name] = {
                    "samples": samples,
                    "TP": tp,
                    "FP": fp,
                    "TN": tn,
                    "FN": fn,
                    "Accuracy": float(re.search(r"Accuracy: ([\d\.]+)", category).group(1)),
                    "Precision": float(re.search(r"Precision: ([\d\.]+)", category).group(1)),
                    "Recall": float(re.search(r"Recall: ([\d\.]+)", category).group(1)),
                    "F1 score": float(re.search(r"F1 score: ([\d\.]+)", category).group(1)),
                    "Yes ratio": float(re.search(r"Yes ratio: ([\d\.]+)", category).group(1))
                }
        return metrics

    def get_metrics_mme(self):
        metrics = {'perception': {'total_score': None}, 'cognition': {'total_score': None}}
        s = self.read_file('bash_script_log.txt') 
        if s is None: return metrics
        l = s.split('===========')
        pattern = r"(\w+(?:\s+\w+)*)\s+score:\s+(\d+\.\d+)"
        for i, category in [(2, 'perception'), (4, 'cognition')]:
            s = l[i]
            matches = re.findall(pattern, s)
            metrics[category] = {f"{match[0].replace(' ', '_').lower()}_score": float(match[1]) 
                                 for match in matches}
        return metrics

    def get_metrics_mmbench(self):
        metrics = {"overall": None}
        d = self.read_file('eval_server_result.json') 
        if d is None: return metrics
        return d

    def get_metrics_seed(self):
        metrics = {'overall': None}
        return metrics


    def get_metrics_llavabench(self):        
        metrics = {"all": {"score_model/score_ref": None, "score_ref": None, "score_model": None},
                   "llava_bench_complex": {"score_model/score_ref": None, "score_ref": None, "score_model": None},
                   "llava_bench_conv": {"score_model/score_ref": None, "score_ref": None, "score_model": None},
                   "llava_bench_detail": {"score_model/score_ref": None, "score_ref": None, "score_model": None},}
        s = self.read_file('bash_script_log.txt') 
        if s is None: return metrics
        lines = [line for line in s.split('\n') if line.strip() and not line.startswith('=')]
        lines = lines[1:]
        metrics = {}
        for line in lines:
            parts = line.split()
            key = parts[0]
            metrics[key] = {
                'score_model/score_ref': float(parts[1]),
                'score_ref': float(parts[2]),
                'score_model': float(parts[3]),
            }
        return metrics

    def get_metrics_mmvet(self):
        metrics = {'rec': None, 'ocr': None, 'know': None, 'gen': None, 'spat': None, 'math': None, 'total': None}
        df = self.read_file('results_gpt-4-0613-cap-score-1runs.csv')
        metrics = df[['rec', 'ocr', 'know', 'gen', 'spat', 'math', 'total']].to_dict(orient='records')[0]
        return metrics





def download_eval_server_results(eval_server_info_file='eval_server_results.csv', verbose=False):
    """Go to eval submission site to get the urls for the result and put into `eval_server_info_file`
        then this function will write the result to the eval folder of the runs.
    """
    import pandas as pd
    import urllib.request

    df = pd.read_csv(eval_server_info_file)

    for i in range(len(df)):
        d = dict(df.iloc[i])
        eval_dir = os.path.join(d['save_dir'], 'eval', d['task_name'])
        if not os.path.isdir(eval_dir):
            raise ValueError(f"{eval_dir} does not exists.")
        try:
            response = urllib.request.urlopen(d['url'])
            with open(os.path.join(eval_dir, 'eval_server_result.json'), 'w') as f:
                json.dump(json.loads(response.read()), f)
        except Exception as e:
            print(e)
        print(f'Downloed {d["url"]}\n\t->{eval_dir}')


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
