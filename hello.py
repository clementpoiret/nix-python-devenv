import torch


def main():
    print("Hello from nix-python-devenv (with cuda support)!")
    print("Cuda is available:", torch.cuda.is_available())

    num_of_gpus = torch.cuda.device_count()
    print("Number of usable devices:", num_of_gpus)

    for i in range(num_of_gpus):
        properties = torch.cuda.get_device_properties(i)
        print(f"Device {i}: {properties.name}")
        print(f"  Total Memory: {properties.total_memory / (1024 ** 2):.2f} MB")
        print(f"  Multiprocessor Count: {properties.multi_processor_count}")


if __name__ == "__main__":
    main()
