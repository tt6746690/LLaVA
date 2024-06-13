from transformers import AutoConfig


def auto_upgrade(config):
    cfg = AutoConfig.from_pretrained(config)
    if 'llava' in config and 'llava' not in cfg.model_type:
        assert cfg.model_type == 'llama'
        print("You are using newer LLaVA code base, while the checkpoint of v0 is from older code base.")
        print("You must upgrade the checkpoint to the new code base (this can be done automatically).")
        confirm = input("Please confirm that you want to upgrade the checkpoint. [Y/N]")
        if confirm.lower() in ["y", "yes"]:
            print("Upgrading checkpoint...")
            assert len(cfg.architectures) == 1
            setattr(cfg.__class__, "model_type", "llava")
            cfg.architectures[0] = 'LlavaLlamaForCausalLM'
            cfg.save_pretrained(config)
            print("Checkpoint upgraded.")
        else:
            print("Checkpoint upgrade aborted.")
            exit(1)

# wpq: https://github.com/Efficient-Large-Model/VILA/blob/44a4cca98ac0f81b0891eb2341e9826b5553b6e8/llava/model/utils.py#L56
def is_mm_model(model_path):
    """
    Check if the model at the given path is a visual language model.

    Args:
        model_path (str): The path to the model.

    Returns:
        bool: True if the model is an MM model, False otherwise.
    """
    config = AutoConfig.from_pretrained(model_path)
    architectures = config.architectures
    for architecture in architectures:
        if "llava" in architecture.lower():
            return True
    return False