import sys
import struct
import shutil

def replace_y_value(filename, old_y_value, new_y_value):
    old_y_bytes = struct.pack('<i', old_y_value)  # little-endian int32
    new_y_bytes = struct.pack('<i', new_y_value)

    # Create backup file
    backup_filename = filename + ".bak"
    shutil.copyfile(filename, backup_filename)
    print(f"Backup created: {backup_filename}")

    with open(filename, "rb") as f:
        data = f.read()

    prxy = b'\x50\x52\x58\x59'  # PRXY
    output = bytearray(data)
    length = len(data)
    i = 0
    replacements = 0

    while i < length - 11:
        if data[i:i+4] == prxy and data[i+8:i+12] == old_y_bytes:
            output[i+8:i+12] = new_y_bytes
            replacements += 1
            i += 12  # skip full pattern
        else:
            i += 1

    with open(filename, "wb") as f:
        f.write(output)

    print(f"Replaced {replacements} occurrence(s) of Y={old_y_value} with Y={new_y_value}.")

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: script.py <filename> <current_y_value> <new_y_value>")
    else:
        filename = sys.argv
        try:
            old_y = int(sys.argv)
            new_y = int(sys.argv)
        except ValueError:
            print("Error: Y values must be integers.")
            sys.exit(1)

        replace_y_value(filename, old_y, new_y)
