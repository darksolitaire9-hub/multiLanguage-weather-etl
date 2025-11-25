# helpers/csv_path_writer.py

import os

def save_exported_csv_path_if_missing(path_to_write, csv_path):
    """
    Writes the csv_path string to the file at path_to_write ONLY if the file does not already exist.
    Does nothing if the file is already present.
    
    Args:
        path_to_write (str): The file path where the CSV path should be written.
        csv_path (str): The actual CSV path to record.
    
    Returns:
        bool: True if the file was written, False if file already existed.
    """
    os.makedirs(os.path.dirname(path_to_write), exist_ok=True)
    if os.path.exists(path_to_write):
        print(f"ℹ️  {path_to_write} already exists. Skipping write.")
        return False
    with open(path_to_write, "w") as f:
        f.write(csv_path)
    print(f"✅ CSV export path written to {path_to_write}")
    return True
