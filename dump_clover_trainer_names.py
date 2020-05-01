# -*- coding: utf-8 -*-
import re

charmap = {0x00: " ", 0x01: "À", 0x02: "Á", 0x03: "Â", 0x04: "Ç", 0x05: "È", 0x06: "É", 0x07: "Ê", 0x08: "Ë", 0x09: "Ì", 0x0B: "Î", 0x0C: "Ï", 0x0D: "Ò", 0x0E: "Ó", 0x0F: "Ô", 0x10: "Œ", 0x11: "Ù", 0x12: "Ú", 0x13: "Û", 0x14: "Ñ", 0x15: "ß", 0x16: "à", 0x17: "á", 0x19: "ç", 0x1A: "è", 0x1B: "é", 0x1C: "ê", 0x1D: "ë", 0x1E: "ì", 0x20: "î", 0x21: "ï", 0x22: "ò", 0x23: "ó", 0x24: "ô", 0x25: "œ", 0x26: "ù", 0x27: "ú", 0x28: "û", 0x29: "ñ", 0x2A: "º", 0x2B: "ª", 0x2C: "{SUPER_ER}", 0x2D: "&", 0x2E: "+", 0x34: "{LV}", 0x35: "=", 0x51: "¿", 0x52: "¡", 0x53: "{PK}", 0x54: "{MN}", 0x5A: "Í", 0x5B: "%", 0x5C: "(", 0x5D: ")", 0x68: "â", 0x6F: "í", 0x79: "{UP_ARROW}", 0x7A: "{DOWN_ARROW}", 0x7B: "{LEFT_ARROW}", 0x7C: "{RIGHT_ARROW}", 0xA1: "0", 0xA2: "1", 0xA3: "2", 0xA4: "3", 0xA5: "4", 0xA6: "5", 0xA7: "6", 0xA8: "7", 0xA9: "8", 0xAA: "9", 0xAB: "!", 0xAC: "?", 0xAD: ".", 0xAE: "-", 0xB0: "…", 0xB1: "“", 0xB2: "”", 0xB3: "‘", 0xB4: "'", 0xB5: "♂", 0xB6: "♀", 0xB7: "¥", 0xB8: ",", 0xB9: "×", 0xBA: "/", 0xBB: "A", 0xBC: "B", 0xBD: "C", 0xBE: "D", 0xBF: "E", 0xC0: "F", 0xC1: "G", 0xC2: "H", 0xC3: "I", 0xC4: "J", 0xC5: "K", 0xC6: "L", 0xC7: "M", 0xC8: "N", 0xC9: "O", 0xCA: "P", 0xCB: "Q", 0xCC: "R", 0xCD: "S", 0xCE: "T", 0xCF: "U", 0xD0: "V", 0xD1: "W", 0xD2: "X", 0xD3: "Y", 0xD4: "Z", 0xD5: "a", 0xD6: "b", 0xD7: "c", 0xD8: "d", 0xD9: "e", 0xDA: "f", 0xDB: "g", 0xDC: "h", 0xDD: "i", 0xDE: "j", 0xDF: "k", 0xE0: "l", 0xE1: "m", 0xE2: "n", 0xE3: "o", 0xE4: "p", 0xE5: "q", 0xE6: "r", 0xE7: "s", 0xE8: "t", 0xE9: "u", 0xEA: "v", 0xEB: "w", 0xEC: "x", 0xED: "y", 0xEE: "z", 0xEF: "▶", 0xF0: ":", 0xF1: "Ä", 0xF2: "Ö", 0xF3: "Ü", 0xF4: "ä", 0xF5: "ö", 0xF6: "ü"}

trainer_regex = re.compile(r"^Trainer 0x([0-9a-f]+):")

def charmap_convert_bytes_to_string(input_bytes):
    output = ""
    for char in input_bytes:
        if char in charmap:
            output += charmap[char]
        elif char == 0xff:
            break
        else:
            output += f"\\x{char:02x}"
            print(f"Unknown char 0x{char:02x} found!")

    return output

def main():
    with open("Cloverv12.gba", "rb") as f:
        gTrainerClassNames = 0x23e558
        f.seek(gTrainerClassNames)
        trainer_class_names = []
        trainer_combined_names = []
        for i in range(107):
            trainer_class_name_as_bytes = f.read(13)
            cur_trainer_class_name = charmap_convert_bytes_to_string(trainer_class_name_as_bytes)
            trainer_class_names.append(cur_trainer_class_name)

        gTrainers = 0x23eac8

        for i in range(742):
            f.seek(gTrainers + i * 0x28 + 1)
            trainer_class = ord(f.read(1))
            f.seek(gTrainers + i * 0x28 + 4)
            trainer_name_as_bytes = f.read(12)
            cur_trainer_name = charmap_convert_bytes_to_string(trainer_name_as_bytes)
            trainer_combined_names.append(f"{trainer_class_names[trainer_class]} {cur_trainer_name}") 

    output = ""

    with open("trainer_sets.txt", "r") as f:
        for line in f:
            match_obj = trainer_regex.search(line)
            if match_obj is None:
                output += line
            else:
                trainer_num = int(match_obj.group(1), 16)
                output += f"{trainer_combined_names[trainer_num]} (id: 0x{match_obj.group(1)})\n"

    with open("trainer_sets_out.txt", "w+") as f:
        f.write(output)

if __name__ == "__main__":
    main()
